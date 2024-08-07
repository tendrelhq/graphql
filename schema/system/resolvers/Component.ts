import type { ComponentResolvers } from "@/schema";
import { GraphQLError } from "graphql";
import { decodeGlobalId } from "..";

export const Component: ComponentResolvers = {
  __resolveType(parent, _ctx, _info) {
    const { type } = decodeGlobalId(parent.id);
    switch (type) {
      case "workinstance":
        return "Checklist";
    }
    throw new GraphQLError("Unknown component type", {
      extensions: {
        code: "BAD_REQUEST",
      },
    });
  },
};
