import type { QueryResolvers } from "@/schema";

// @ts-ignore
export const entity: NonNullable<QueryResolvers["entity"]> = async (
  _,
  args,
  __,
) => {
  return {
    entity: args.id,
  };
};
