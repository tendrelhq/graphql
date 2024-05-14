import type { QueryResolver } from "@/schema/resolvers";

export const customer: QueryResolver<"customer"> = async (
  _,
  { id },
  { orm },
) => {
  return await orm.customer.load(id);
};
