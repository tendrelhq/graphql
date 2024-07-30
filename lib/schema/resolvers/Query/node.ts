import type { QueryResolvers } from "@/schema";
import { decodeGlobalId } from "@/util";
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
    case "location":
      return {
        __typename: "Location",
        ...(await ctx.orm.location.load(id)),
      };
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
    case "worker":
      return {
        __typename: "Worker",
        ...(await ctx.orm.worker.load(id)),
      };
    default:
      throw new GraphQLError("Unknown node type", {
        extensions: {
          code: "BAD_REQUEST",
        },
      });
  }
};
