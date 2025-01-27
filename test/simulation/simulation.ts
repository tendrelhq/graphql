import { assert } from "@/util";

type Options = {
  /** Probability that concurrent operations conflict. Default: 0.0 */
  conflict_probability?: number;
  /** Number of concurrent operations. Default: 0 */
  max_concurrent_ops?: number;
  /** Number of in-flight operations. Default: 100 */
  max_in_flight_ops?: number;
  /** Number of iterations. Default: 1000 */
  max_iterations?: number;
  /** Number of distinct peers. Default: 10 */
  peer_count?: number;
  /** Probability that an operation is stale. Default: 0.0 */
  staleness_probability?: number;
};

export class Simulation {
  public readonly conflict_probability: number;
  public readonly max_concurrent_ops: number;
  public readonly max_in_flight_ops: number;
  public readonly max_iterations: number;
  public readonly peer_count: number;
  public readonly staleness_probability: number;

  constructor(opts: Options) {
    this.conflict_probability = opts.conflict_probability ?? 0.0;
    assert(
      this.conflict_probability >= 0.0 && this.conflict_probability <= 1.0,
      "0.0 <= conflict_probability <= 1.0",
    );
    this.max_concurrent_ops = opts.max_concurrent_ops ?? 0;
    assert(this.max_concurrent_ops >= 0, "max_concurrent_ops >= 0");
    this.max_in_flight_ops = opts.max_in_flight_ops ?? 100;
    assert(this.max_in_flight_ops > 0, "max_in_flight_ops > 0");
    this.max_iterations = opts.max_iterations ?? 1000;
    assert(this.max_iterations > 0, "max_iterations > 0");
    this.staleness_probability = opts.staleness_probability ?? 0.0;
    assert(
      this.staleness_probability >= 0.0 && this.staleness_probability <= 1.0,
      "0.0 <= staleness_probability <= 1.0",
    );

    // TODO
    this.peer_count = opts.peer_count ?? 10;
    assert(this.peer_count > 0, "peer_count > 0");

    console.debug(`
===== Simulation options =====
  conflict probability: ${this.conflict_probability.toPrecision(3)}
  max concurrent operations: ${this.max_concurrent_ops}
  max in-flight operations: ${this.max_in_flight_ops}
  max iterations: ${this.max_iterations}
  peer count: ${this.peer_count}
  staleness probability: ${this.staleness_probability.toPrecision(3)}
==============================
    `);
  }

  async run() {
    const cluster = new Cluster(this);

    console.debug("Simulation starting... ");
    for (let i = 0; i < this.max_iterations; i++) {
      // This is the main simulation "event loop".
      // First, we ask all (active) peers to prepare their next batch of
      // operations.
      await cluster.tick();

      // Then we determine which of these operations will actually be allowed
      // through. This is where we might decide to postpone or otherwise reorder
      // this batch of operations (according to configuration).
      const batches: unknown[][] = [];

      // Next we push those operations into the system. Each batch represents a
      // set of operations that should "go together", i.e. concurrently. Batches
      // are executed sequentially.
      for (const batch of batches) {
        await Promise.allSettled(batch);
      }
    }
    console.debug("Simulation complete.");
  }
}

type ClusterOptions = {
  peer_count: number;
};

class Cluster {
  public readonly peers: Set<Peer>;

  constructor(opts: ClusterOptions) {
    this.peers = new Set();
    for (let i = 0; i < opts.peer_count; i++) {
      this.peers.add(
        new Peer({
          peer_index: i,
        }),
      );
    }
  }

  async tick() {
    // TODO: this is where we use concurrency, max in-flight, etc.
    const ps = [];
    for (const p of this.peers) {
      ps.push(p.tick());
    }
    await Promise.allSettled(ps);
  }
}

type PeerOptions = {
  peer_index: number;
};

class Peer {
  public readonly index: number;

  constructor(opts: PeerOptions) {
    this.index = opts.peer_index;
    assert(this.index >= 0, "peer_index >= 0");
  }

  sayHello() {
    console.log(`Hello from Peer ${this.index}`);
  }

  async tick() {
    await Bun.sleep(this.index > 0 ? 1000 / this.index : 0);
    this.sayHello();
  }
}
