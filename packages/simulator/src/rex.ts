import assert from "node:assert/strict";
import {
  type CacheConfig,
  type ConcreteRequest,
  type Environment,
  type FetchQueryFetchPolicy,
  Observable,
  type OperationDescriptor,
  createOperationDescriptor,
  fetchQuery,
} from "relay-runtime";
import config from "./config";
import { seed } from "./rng";

export type TimeOptions = {
  /**
   * The "current time" from the perspective of our simulation.
   */
  now?: number;
  /**
   * How long, in usr time, each tick should take.
   * This controls the rate at which the simulation runs.
   */
  ms_per_tick?: number;
  /**
   * The "reference date" for our simulation. This factors into how simulations
   * appear from user land and allows for the simulation to (appear to) consume
   * the same amount of usr time while "running" at different speeds.
   */
  ref?: Date;
};

interface ReadonlyTime {
  now: number;
}

function debug_run_for_ms(...args: unknown[]) {
  console.debug("time:run_for_ms", ...args);
}

class Time implements ReadonlyTime {
  #now: number;
  #ms_per_tick: number;
  readonly #ref: Date;

  constructor({
    now = 0,
    ms_per_tick = config.ms_per_tick,
    ref = new Date(),
  }: TimeOptions) {
    this.#ms_per_tick = ms_per_tick;
    this.#now = now;
    this.#ref = ref;
  }

  static default() {
    return new Time({});
  }

  get now() {
    return this.#now;
  }

  async advance(fn: (signal: AbortSignal) => Promise<void>) {
    this.#now += 1;
    await this.run_for_ms(this.#ms_per_tick, fn);
  }

  async run_for_ms(
    milliseconds: number,
    fn: (signal: AbortSignal) => Promise<void>,
  ) {
    let timer: NodeJS.Timeout;
    const timeout = new Promise(resolve => {
      timer = setTimeout(resolve, milliseconds);
    });
    const ctl = new AbortController();
    await Promise.allSettled([
      timeout.then(() => ctl.abort()),
      fn(ctl.signal).catch(debug_run_for_ms),
    ]);
  }
}

type Completion = () => Promise<unknown>;

interface Query<R, V> {
  response: R;
  variables: V;
}

// biome-ignore lint/suspicious/noExplicitAny:
type AnyQuery = Query<any, any>;

type SystemThis = {
  rex: Rex;
  remove(): void;
};

export type System<Q extends AnyQuery> = (
  this: SystemThis,
  query: Q["response"],
) => Completion[];

// biome-ignore lint/suspicious/noExplicitAny:
type AnySystem = System<any>;

interface ReadonlyRex {
  environment: Environment;
  time: ReadonlyTime;
}

let REX_ID = 0;

type Operation = [OperationDescriptor, FetchQueryFetchPolicy];

export class Rex implements ReadonlyRex {
  // #completions = new Completions();
  #queries: Map<string, Operation> = new Map();
  /**
   * Keys are system hashes, values are `[AnySystem, query hash]` tuples.
   */
  #systems: Map<string, [AnySystem, string]> = new Map();
  #time: Time;
  #rexId = REX_ID++;

  constructor(
    public environment: Environment,
    timeOptions?: TimeOptions,
  ) {
    this.#time = timeOptions ? new Time(timeOptions) : Time.default();
    this.debug(`connected, seed: ${seed}`);
  }

  debug(...args: unknown[]) {
    console.debug(`rex[${this.#rexId}] t=${this.#time.now}`, ...args);
  }
  trace(...args: unknown[]) {
    console.trace(`rex[${this.#rexId}] t=${this.#time.now}`, ...args);
  }

  /**
   * Add a system to the fray (on the next tick).
   */
  public addSystem<Q extends AnyQuery>(
    system: System<Q>,
    query: {
      request: ConcreteRequest;
      variables: Q["variables"];
      cacheConfig?: CacheConfig;
      fetchPolicy?: FetchQueryFetchPolicy;
    },
  ) {
    const op = createOperationDescriptor(
      query.request,
      query.variables,
      query.cacheConfig,
    );

    const queryHash = op.request.identifier;
    if (!this.#queries.has(queryHash)) {
      this.#queries.set(queryHash, [op, query.fetchPolicy ?? "network-only"]);
    }

    const systemHash = `${system.name}:${queryHash}`;
    if (!this.#systems.has(systemHash)) {
      this.#systems.set(systemHash, [
        system.bind({
          rex: this,
          remove: () => this.removeSystem(systemHash),
        }),
        queryHash,
      ]);
    }

    this.printStats();

    return () => this.removeSystem(systemHash);
  }

  // TODO: It would be nice to enforce that systems can only be removed via
  // Completions? Then we wouldn't have to implement any sort of "pending
  // remove" queue. For now we will just assume that we are playing by the
  // rules. The key requirement is that we want system removal (and insertion)
  // to only happen at the *beginning of the next tick*.
  public removeSystem(hash: string) {
    if (!this.#systems.delete(hash)) {
      // console.warn(`did not remove ${hash}`);
      // console.debug(JSON.stringify([...this.#systems.entries()], null, 2));
    }
    this.printStats();
  }

  public start() {
    assert(this.#time.now === 0);
    setTimeout(() => this.update(), 0);
  }

  private printStats() {
    this.debug(`queries=${this.#queries.size}, systems=${this.#systems.size}`);
    if (this.#systems.size) {
      this.debug(
        " ",
        [...this.#systems.values()].map(s => s[0].name).join(","),
      );
    }
  }

  public get time(): ReadonlyTime {
    return this.#time;
  }

  /**
   * update() is called every tick. It is the mechanism that drives progression
   * of the overall system. For each call to update(), the following happens:
   *
   * 1. An Observable is created for the underlying query associated with the
   *    system(s). It is, of course, responsible for making the network call to
   *    (re)fetch the data associated with the query (eventually).
   * 2. The relevant system(s) are subscribed to the Observable such that they
   *    will be triggered upon completion of the underlying query.
   * 3. Systems are just functions that received the result of the query and are
   *    free to do whatever they like
   */
  async update() {
    const pendingCompletions: Observable<Completion[]>[] = [];
    for (const [system, queryHash] of this.#systems.values()) {
      const query = this.#queries.get(queryHash);
      if (query) {
        pendingCompletions.push(
          fetchQuery(
            this.environment,
            query[0].request.node,
            query[0].request.variables,
            {
              fetchPolicy: query[1],
              networkCacheConfig: query[0].request.cacheConfig,
            },
          ).map(system),
        );
      }
    }

    // TODO: We should keep track of our completions, in case we can't get
    // through them all.
    const batch = pendingCompletions.reduce(
      (acc, val) => acc.concat(val),
      Observable.from([]),
    );

    await this.#time.advance(async signal => {
      let i = 0;
      const completions: Completion[] = [];
      await new Promise<void>((resolve, reject) => {
        batch.subscribe({
          next: value => completions.push(...value),
          complete: resolve,
          error: reject,
        });
      });
      while (completions?.length && !signal.aborted) {
        i += 1;
        // const tag = `completion[${i}]`;
        // console.time(tag);
        await completions.pop()?.();
        // console.timeEnd(tag);
      }
      if (signal.aborted && completions?.length) {
        this.debug(`abort drops ${completions.length} completions`);
      }
    });

    setTimeout(() => this.update(), 0);
  }
}
