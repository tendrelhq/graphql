import { describe, expect, test } from "bun:test";
import { graphqlSync } from "graphql";
import { Schema as schema } from "./schema";

// https://relay.dev/graphql/connections.htm
describe("graphql cursor connections specification", () => {
  // https://relay.dev/graphql/connections.htm#sec-Connection-Types.Introspection
  test("connection types", () => {
    const source = `
      {
        __type(name: "OrganizationConnection") {
          fields {
            name
            type {
              name
              kind
              ofType {
                name
                kind
              }
            }
          }
        }
      }
    `;

    expect(graphqlSync({ schema, source })).toEqual({
      data: {
        __type: {
          fields: [
            {
              name: "pageInfo",
              type: {
                kind: "NON_NULL",
                name: null,
                ofType: {
                  kind: "OBJECT",
                  name: "PageInfo",
                },
              },
            },
            {
              name: "edges",
              type: {
                kind: "LIST",
                name: null,
                ofType: {
                  kind: "OBJECT",
                  name: "OrganizationEdge",
                },
              },
            },
          ],
        },
      },
    });
  });

  // https://relay.dev/graphql/connections.htm#sec-Edge-Types.Introspection
  test("edge types", () => {
    const source = `
      {
        __type(name: "OrganizationEdge") {
          fields {
            name
            type {
              name
              kind
              ofType {
                name
                kind
              }
            }
          }
        }
      }
    `;

    expect(graphqlSync({ schema, source })).toEqual({
      data: {
        __type: {
          fields: [
            {
              name: "node",
              type: {
                name: "Organization",
                kind: "OBJECT",
                ofType: null,
              },
            },
            {
              name: "cursor",
              type: {
                name: null,
                kind: "NON_NULL",
                ofType: {
                  name: "String",
                  kind: "SCALAR",
                },
              },
            },
          ],
        },
      },
    });
  });

  // https://relay.dev/graphql/connections.htm#sec-undefined.PageInfo.Introspection
  test("page info", () => {
    const source = `
      {
        __type(name: "PageInfo") {
          fields {
            name
            type {
              name
              kind
              ofType {
                name
                kind
              }
            }
          }
        }
      }
    `;

    expect(graphqlSync({ schema, source })).toEqual({
      data: {
        __type: {
          fields: [
            {
              name: "hasNextPage",
              type: {
                name: null,
                kind: "NON_NULL",
                ofType: {
                  name: "Boolean",
                  kind: "SCALAR",
                },
              },
            },
            {
              name: "hasPreviousPage",
              type: {
                name: null,
                kind: "NON_NULL",
                ofType: {
                  name: "Boolean",
                  kind: "SCALAR",
                },
              },
            },
            {
              name: "startCursor",
              type: {
                name: "String",
                kind: "SCALAR",
                ofType: null,
              },
            },
            {
              name: "endCursor",
              type: {
                name: "String",
                kind: "SCALAR",
                ofType: null,
              },
            },
          ],
        },
      },
    });
  });
});
