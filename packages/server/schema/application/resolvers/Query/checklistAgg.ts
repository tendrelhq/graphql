import type { QueryResolvers } from "@/schema";

export const checklistAgg: NonNullable<
  QueryResolvers["checklistAgg"]
> = () => ({}); // defer to ChecklistAggregate resolver
