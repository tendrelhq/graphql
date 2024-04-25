import data from "./data.ts";
import type { Resolvers } from "./schema/__generated__/resolvers-types.ts";

export const resolvers: Resolvers = {
  Query: {
    pupils(_, __, context) {
      if (context.authScope) {
        console.log(`User (${context.authScope}) is authenticated!`);
      } else {
        console.warn("User is not authenticated!");
      }
      return data.pupils;
    },
  },
};
