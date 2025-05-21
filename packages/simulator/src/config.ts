import z from "zod";
import { faker } from "./rng";

const e = process.env;

const b = () => z.boolean({ coerce: true }).default(false);
const unsigned = () => z.number({ coerce: true }).gte(0);

//============================================================================//
//                                                                            //
// Configuration options related to Rex.                                      //
//                                                                            //
//============================================================================//

/**
 * The minimum amount of *physical* time, in milliseconds, that each *logical*
 * tick will consume.
 */
export const ms_per_tick = unsigned()
  .min(100)
  .default(250)
  .parse(e.MS_PER_TICK);

/** Create a number that must fall within the range (0.0, 1.0) */
function probability() {
  return unsigned().lte(1).default(0.5);
}

function makeProbability(name: string) {
  const value = probability().parse(process.env[name]);
  const rng = () => faker.datatype.boolean(value);
  rng.value = value;
  return rng;
}

//============================================================================//
//                                                                            //
// Configuration options related to the simulator.                            //
//                                                                            //
//============================================================================//

/**
 * Auto select an existing customer by name or id.
 * If it no such customer is found, an error will be thrown.
 * If you intend to select by name, keep in mind that the *first* matching owner
 * will be the one chosen when/if multiple of the same name exist.
 */
export const auto_select_owner = z
  .string()
  .optional()
  .parse(e.AUTO_SELECT_OWNER);

/**
 * Skip the owner prompt.
 * This will cause a new customer to be generated every time you run the cli!
 */
export const skip_owner_prompt = b().default(false).parse(e.SKIP_OWNER_PROMPT);

/**
 * Auto select a template by name or id.
 * If it no such template is found, an error will be thrown.
 * If you intend to select by name, keep in mind that the *first* matching
 * template will be the one chosen when/if multiple of the same name exist.
 */
export const auto_select_template = z
  .string()
  .optional()
  .parse(e.AUTO_SELECT_TEMPLATE);

/**
 * How many instances of the simulation should be started.
 * Currently this manifests as an additional location, worker, and task
 * instance which then undergo the normal task chain simulation.
 */
export const multiplicity = unsigned().default(3).parse(e.MULTIPLICITY);

/**
 * The probability (0.0,1.0) that the active task will be chosen.
 */
export const active_probability = makeProbability("ACTIVE_PROBABILITY");

/**
 * The probability (0.0,1.0) that the root task will be chosen.
 * This applies only when the root is active and the active task was already
 * chosen (i.e. it passed `active_probability`).
 */
export const root_probability = makeProbability("ROOT_PROBABILITY");

/**
 * How many Worker entities to spin up initially.
 */
export const worker_count = unsigned().default(1).parse(e.WORKER_COUNT);

//============================================================================//
//                                                                            //
// Configuration options related to how TaskChain visualizes chain data.      //
//                                                                            //
//============================================================================//

/**
 * When showing a lagged chain view, only the show CHAIN_LAG_N most recent
 * events.
 *
 * @see {@link show_full_chain}
 */
export const chain_lag_n = unsigned().default(10).parse(e.CHAIN_LAG_N);

/**
 * Whether to display full chains, or use a lagged view that only shows a subset
 * of the most recent events.
 *
 * @see {@link chain_lag_n}
 */
export const show_full_chain = b().parse(e.SHOW_FULL_CHAIN);

export default {
  // Rex
  ms_per_tick,
  // simulation internals
  auto_select_owner,
  skip_owner_prompt,
  auto_select_template,
  multiplicity,
  active_probability,
  root_probability,
  worker_count,
  // TaskChain.tsx
  chain_lag_n,
  show_full_chain,
};
