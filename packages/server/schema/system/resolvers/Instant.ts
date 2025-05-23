import type { InstantResolvers, ZonedDateTime } from "@/schema";
import { Temporal } from "@js-temporal/polyfill";

export const Instant: InstantResolvers = {
  // toString(root, { options }) {
  //   return Temporal.Instant.fromEpochMilliseconds(
  //     Number(root.epochMilliseconds),
  //   ).toString({
  //     // @ts-ignore-error Type ... is not assignable to ...
  //     fractionalSecondDigits: options?.fractionalSecondDigits,
  //     roundingMode: options?.roundingMode,
  //     smallestUnit: options?.smallestUnit,
  //     timeZone: options?.timeZone,
  //   });
  // },
  // @ts-ignore-error Types of property 'toString' are incompatible
  toZonedDateTime(root, { timeZone }) {
    const zdt = Temporal.Instant.fromEpochMilliseconds(
      Number(root.epochMilliseconds),
    ).toZonedDateTimeISO(timeZone);
    return {
      year: zdt.year,
      month: zdt.month,
      day: zdt.day,
      hour: zdt.hour,
      minute: zdt.minute,
      second: zdt.second,
      millisecond: zdt.millisecond,
      timeZone,
      epochMilliseconds: root.epochMilliseconds,
    } satisfies Omit<ZonedDateTime, "toString">; // implemented elsewhere
  },
};
