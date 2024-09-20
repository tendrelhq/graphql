import type { ChecklistInProgressResolvers } from "@/schema";
import { NOW } from "@/test/prelude";

export const ChecklistInProgress: ChecklistInProgressResolvers = {
  inProgressAt() {
    return {
      __typename: "Instant",
      epochMilliseconds: NOW.valueOf().toString(),
    };
  },
};
