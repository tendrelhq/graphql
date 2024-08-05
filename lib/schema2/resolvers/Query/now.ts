import type { Instant, QueryResolvers, ZonedDateTime } from "@/schema2";
import { Temporal } from "@js-temporal/polyfill";

// @ts-expect-error
export const now: NonNullable<QueryResolvers["now"]> = async (_, __, ___) => {
  const now = Temporal.Instant.fromEpochMilliseconds(Date.now());
  if (Math.random() * 100 > 50) {
    return {
      __typename: "Instant",
      epochMilliseconds: now.epochMilliseconds.toString(),
    } satisfies Omit<Instant, "toString" | "toZonedDateTime">;
  }

  const tz = "America/Los_Angeles";
  const zdt = now.toZonedDateTimeISO(tz);
  return {
    __typename: "ZonedDateTime",
    epochMilliseconds: now.epochMilliseconds.toString(),
    //
    year: zdt.year,
    month: zdt.month,
    day: zdt.day,
    hour: zdt.hour,
    minute: zdt.minute,
    second: zdt.second,
    millisecond: zdt.millisecond,
    timeZone: tz,
  } satisfies Omit<ZonedDateTime, "toString">;
};
