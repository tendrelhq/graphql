import { describe, expect, it } from "bun:test";
import { graphqlSync } from "graphql";
import { Schema as schema } from "./schema";

describe("user", () => {
  it("fetches the current user", () => {
    const source = `
      query {
        user {
          id
          name
        }
      }
    `;

    expect(graphqlSync({ schema, source })).toEqual({
      data: {
        user: {
          id: "VXNlcjox",
          name: "Jerry Garcia",
        },
      },
    });
  });

  it("fetches the current user by id", () => {
    const source = `
      query {
        node(id: "VXNlcjox") {
          id
          ... on User {
            name
          }
        }
      }
    `;

    expect(graphqlSync({ schema, source })).toEqual({
      data: {
        node: {
          id: "VXNlcjox",
          name: "Jerry Garcia",
        },
      },
    });
  });

  describe("connections", () => {
    it("fetches the first organization of the current user", () => {
      const source = `
        query {
          user {
            name
            organizations(first: 1) {
              edges {
                node {
                  name
                }
              }
            }
          }
        }
      `;

      expect(graphqlSync({ schema, source })).toEqual({
        data: {
          user: {
            name: "Jerry Garcia",
            organizations: {
              edges: [
                {
                  node: { name: "Grateful Dead" },
                },
              ],
            },
          },
        },
      });
    });

    it("fetches the first two organizations of the current user with a cursor", () => {
      const source = `
        query {
          user {
            name
            organizations(first: 2) {
              edges {
                cursor
                node {
                  name
                }
              }
            }
          }
        }
      `;

      expect(graphqlSync({ schema, source })).toEqual({
        data: {
          user: {
            name: "Jerry Garcia",
            organizations: {
              edges: [
                {
                  cursor: "YXJyYXljb25uZWN0aW9uOjA=",
                  node: {
                    name: "Grateful Dead",
                  },
                },
                {
                  cursor: "YXJyYXljb25uZWN0aW9uOjE=",
                  node: {
                    name: "Bourne 2 Run",
                  },
                },
              ],
            },
          },
        },
      });
    });

    it("fetches the next two organizations of the current user with a cursor", () => {
      const source = `
        query {
          user {
            name
            organizations(first: 2, after: "YXJyYXljb25uZWN0aW9uOjA=") {
              edges {
                cursor
                node {
                  name
                }
              }
            }
          }
        }
      `;

      expect(graphqlSync({ schema, source })).toEqual({
        data: {
          user: {
            name: "Jerry Garcia",
            organizations: {
              edges: [
                {
                  cursor: "YXJyYXljb25uZWN0aW9uOjE=",
                  node: {
                    name: "Bourne 2 Run",
                  },
                },
                {
                  cursor: "YXJyYXljb25uZWN0aW9uOjI=",
                  node: {
                    name: "Shire, co.",
                  },
                },
              ],
            },
          },
        },
      });
    });

    it("fetches no organizations of the current user at the end of the connection", () => {
      const source = `
        query {
          user {
            name
            organizations(first: 2, after: "YXJyYXljb25uZWN0aW9uOjI=") {
              edges {
                cursor
                node {
                  name
                }
              }
            }
          }
        }
      `;

      expect(graphqlSync({ schema, source })).toEqual({
        data: {
          user: {
            name: "Jerry Garcia",
            organizations: {
              edges: [],
            },
          },
        },
      });
    });

    it("identifies the end of the list", () => {
      const source = `
        query {
          user {
            name
            firstPage: organizations(first: 2) {
              edges {
                node {
                  name
                }
              }
              pageInfo {
                hasNextPage
              }
            }
            secondPage: organizations(first: 3, after: "YXJyYXljb25uZWN0aW9uOjE=") {
              edges {
                node {
                  name
                }
              }
              pageInfo {
                hasNextPage
              }
            }
          }
        }
      `;

      expect(graphqlSync({ schema, source })).toEqual({
        data: {
          user: {
            name: "Jerry Garcia",
            firstPage: {
              edges: [
                {
                  node: { name: "Grateful Dead" },
                },
                {
                  node: { name: "Bourne 2 Run" },
                },
              ],
              pageInfo: { hasNextPage: true },
            },
            secondPage: {
              edges: [
                {
                  node: { name: "Shire, co." },
                },
              ],
              pageInfo: { hasNextPage: false },
            },
          },
        },
      });
    });

    it("fetches all templates for a user's organization", () => {
      const source = `
        query {
          user {
            name
            organizations(first: 1) {
              edges {
                node {
                  name
                  templates {
                    edges {
                      node {
                        name
                      }
                    }
                  }
                }
              }
            }
          }
        }
      `;

      expect(graphqlSync({ schema, source })).toEqual({
        data: {
          user: {
            name: "Jerry Garcia",
            organizations: {
              edges: [
                {
                  node: {
                    name: "Grateful Dead",
                    templates: {
                      edges: [
                        {
                          node: {
                            name: "A",
                          },
                        },
                        {
                          node: {
                            name: "B",
                          },
                        },
                      ],
                    },
                  },
                },
              ],
            },
          },
        },
      });
    });

    it("fetches just the first template", () => {
      const source = `
        query {
          user {
            name
            organizations(first: 1) {
              edges {
                node {
                  name
                  templates(first: 1) {
                    edges {
                      node {
                        name
                      }
                    }
                  }
                }
              }
            }
          }
        }
      `;

      expect(graphqlSync({ schema, source })).toEqual({
        data: {
          user: {
            name: "Jerry Garcia",
            organizations: {
              edges: [
                {
                  node: {
                    name: "Grateful Dead",
                    templates: {
                      edges: [
                        {
                          node: {
                            name: "A",
                          },
                        },
                      ],
                    },
                  },
                },
              ],
            },
          },
        },
      });
    });
  });
});
