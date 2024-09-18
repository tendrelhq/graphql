import type { QueryResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";

/*
 * Generic "refetch" entrypoint. Useful for ensuring a client has the latest
 * state for a particular "node" (really a query), rather than saying "give me
 * everything that's changed since <some timestamp> though that will be a
 * useful synchronization entrypoint as well.
 */
export const node: NonNullable<QueryResolvers["node"]> = async (
  _,
  args,
  ctx,
) => {
  const { type, id } = decodeGlobalId(args.id);
  switch (type) {
    case "name":
      return {
        __typename: "Name",
        ...(await ctx.orm.name.load(id)),
      };
    case "organization":
      return {
        __typename: "Organization",
        ...(await ctx.orm.organization.load(id)),
      };
    case "user":
      return {
        __typename: "User",
        ...(await ctx.orm.user.byId.load(id)),
      };
    default:
      throw new GraphQLError("Unknown node type", {
        extensions: {
          code: "BAD_REQUEST",
        },
      });
  }
};
