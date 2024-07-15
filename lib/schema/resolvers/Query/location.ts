import type { QueryResolvers } from "@/schema";

export const location: NonNullable<QueryResolvers['location']> = async (
  _,
  { id },
  { orm },
) => {
  return await orm.location.load(id);
};
