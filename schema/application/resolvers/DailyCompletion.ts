import type { DailyCompletionResolvers } from "./../../__generated__/types.generated";
export const DailyCompletion: DailyCompletionResolvers = {
  date: parent => parent.date,
  count: parent => parent.count,
};
