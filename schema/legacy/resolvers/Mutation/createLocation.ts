import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const createLocation: NonNullable<
  MutationResolvers["createLocation"]
> = async (_, { input }, ctx) => {
  throw new Error("not implemented");
};
