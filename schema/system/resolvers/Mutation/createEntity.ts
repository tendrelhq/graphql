import { randomUUID } from "node:crypto";
import type { MutationResolvers } from "@/schema";
import { encodeGlobalId } from "../..";

/**
 * Create an Entity (i.e. global ID) from the given input type/id/suffix.
 */
export const createEntity: NonNullable<
  MutationResolvers["createEntity"]
> = async (_, args) => {
  return encodeGlobalId({
    type: args.type,
    id: args.id ?? randomUUID(),
    suffix: args.suffix,
  });
};
