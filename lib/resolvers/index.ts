import { customers, locations } from "@/data";
import type { Resolvers } from "@/schema/types";
import { GraphQLError } from "graphql";
import { match } from "ts-pattern";

export const resolvers: Resolvers = {
  Query: {
    customers(_, __, context) {
      return customers;
    },
    locations(_, args, context) {
      return locations.filter(({ customerId, parentId, ...location }) => {
        return (
          customerId === args.customerId &&
          match(args.parentId)
            // Not including parentId in the request implies you don't care
            // about parent, i.e. give me all locations for this customer.
            .with(undefined, () => true)
            // When specified, parentId can either be null (indicating a
            // top-level location) or a valid ID (indicating a parent).
            .with(null, () => !parentId)
            .otherwise(p => p === parentId)
        );
      });
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

      customers.push(args.input);
      return args.input.id;
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
    createLocation(_, args, context) {
      if (locations.find(({ id }) => id === args.input.id)) {
        throw new GraphQLError("Location already exists", {
          extensions: {
            code: "BAD_REQUEST",
          },
        });
      }

      locations.push(args.input);
      return args.input.id;
    },
  },
};
