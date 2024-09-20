import type { ChecklistClosedResolvers } from "@/schema";
import { NOW } from "@/test/prelude";

export const ChecklistClosed: ChecklistClosedResolvers = {
  closedAt() {
    return {
      __typename: "Instant",
      epochMilliseconds: NOW.valueOf().toString(),
    };
  },
};
