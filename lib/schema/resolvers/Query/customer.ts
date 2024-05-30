import type { QueryResolvers } from "@/schema";

export const customer: NonNullable<QueryResolvers['customer']> = async (
  _,
  { id },
  { orm },
) => {
  return await orm.organization.load(id);
};
