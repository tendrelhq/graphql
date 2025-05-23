import type { ZonedDateTimeResolvers } from "@/schema";
import { Temporal } from "@js-temporal/polyfill";

export const ZonedDateTime: ZonedDateTimeResolvers = {
  year(parent) {
    return Temporal.Instant.fromEpochMilliseconds(
      Number(parent.epochMilliseconds),
    ).toZonedDateTimeISO(parent.timeZone).year;
  },
  month(parent) {
    return Temporal.Instant.fromEpochMilliseconds(
      Number(parent.epochMilliseconds),
    ).toZonedDateTimeISO(parent.timeZone).month;
  },
  day(parent) {
    return Temporal.Instant.fromEpochMilliseconds(
      Number(parent.epochMilliseconds),
    ).toZonedDateTimeISO(parent.timeZone).day;
  },
  hour(parent) {
    return Temporal.Instant.fromEpochMilliseconds(
      Number(parent.epochMilliseconds),
    ).toZonedDateTimeISO(parent.timeZone).hour;
  },
  minute(parent) {
    return Temporal.Instant.fromEpochMilliseconds(
      Number(parent.epochMilliseconds),
    ).toZonedDateTimeISO(parent.timeZone).minute;
  },
  second(parent) {
    return Temporal.Instant.fromEpochMilliseconds(
      Number(parent.epochMilliseconds),
    ).toZonedDateTimeISO(parent.timeZone).second;
  },
  millisecond(parent) {
    return Temporal.Instant.fromEpochMilliseconds(
      Number(parent.epochMilliseconds),
    ).toZonedDateTimeISO(parent.timeZone).millisecond;
  },
  toString(parent, { options }) {
    return Temporal.Instant.fromEpochMilliseconds(
      Number(parent.epochMilliseconds),
    )
      .toZonedDateTimeISO(parent.timeZone)
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
