import type { QueryResolvers } from "@/schema";

export const organization: NonNullable<QueryResolvers["organization"]> = async (
  _,
  { id },
  { orm },
) => {
  return await orm.organization.load(id);
};
