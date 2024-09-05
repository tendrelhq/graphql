import type { ZonedDateTimeResolvers } from "@/schema";
import { Temporal } from "@js-temporal/polyfill";

export const ZonedDateTime: ZonedDateTimeResolvers = {
  toString(root, { options }) {
    return Temporal.Instant.fromEpochMilliseconds(
      Number(root.epochMilliseconds),
    )
      .toZonedDateTimeISO(root.timeZone)
      .toString({
        // @ts-ignore-error
        fractionalSecondDigits: options?.fractionalSecondDigits,
        roundingMode: options?.roundingMode,
        smallestUnit: options?.smallestUnit,
        calendarName: options?.calendarName,
        timeZoneName: options?.timeZoneName,
        offset: options?.offset,
      });
  },
};
