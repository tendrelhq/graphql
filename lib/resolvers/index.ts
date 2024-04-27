import { randomUUID } from "node:crypto";
import type { Resolvers } from "@/schema/schema";

import { customers, locations } from "@/data";
import { GraphQLError } from "graphql";

export const resolvers: Resolvers = {
  Query: {
    customers(_, __, context) {
      return customers;
    },
    locations(_, args, context) {
      return locations.filter(
        ({ customerId, parentId }) => customerId === args.customerId, // && parentId === args.parentId,
      );
    },
    sites(_, args, context) {
      return locations.filter(
        ({ customerId, parentId }) =>
          customerId === args.customerId && !parentId,
      );
    },
  },
  Mutation: {
    createCustomer(_, args, context) {
      if (customers.find(({ id }) => id === args.input.id)) {
        throw new GraphQLError("Customer already exists", {
          extensions: {
            code: "BAD_REQUEST",
          },
        });
      }

      const id = randomUUID();
      customers.push({ ...args.input, id });
      return id;
    },
    deleteCustomer(_, args, context) {
      const i = customers.findIndex(({ id }) => id === args.id);
      if (i === -1) {
        throw new GraphQLError("Customer does not exist", {
          extensions: {
            code: "BAD_REQUEST",
          },
        });
      }

      const [c] = customers.splice(i, 1);

      return c.id;
    },
    updateCustomer(_, args, context) {
      const i = customers.findIndex(({ id }) => id === args.input.id);
      if (i === -1) {
        throw new GraphQLError("Customer does not exist", {
          extensions: {
            code: "BAD_REQUEST",
          },
        });
      }

      const c = customers[i];
      customers[i] = {
        id: c.id,
        name: args.input.name ?? c.name,
        defaultLanguage: args.input.defaultLanguage ?? c.defaultLanguage,
      };

      return c.id;
    },
  },
};
