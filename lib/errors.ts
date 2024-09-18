import { GraphQLError } from "graphql";

export class EntityNotFound extends GraphQLError {
  constructor(what: string) {
    super("entity_not_found", {
      extensions: {
        code: "BAD_REQUEST",
        type: what,
      },
    });
  }
}
