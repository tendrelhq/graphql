import assert from "node:assert";
import { Temporal } from "@js-temporal/polyfill";
import parse from "parse-duration";

/**
 * Parse a human-readable duration string (e.g. 5m, 1hr) into a {@link Temporal.Duration} object.
 *
 * This uses {@link https://www.npmjs.com/package/parse-duration} under the hood,
 * so whatever syntax is accepted by that library will be accepted here.
 */
export function parseDuration(s: string): Temporal.Duration {
  const ms = parse(s);
  assert(ms, `invalid duration string: ${s}`);
  return Temporal.Duration.from({ milliseconds: ms });
}
