import type { QueryResolver } from "@/schema/resolvers";

export const customer: NonNullable<QueryResolvers["customer"]> = async (
  _,
  { id },
  { orm },
) => {
  return await orm.customer.load(id);
};
