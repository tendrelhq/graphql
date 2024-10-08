import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { execute, testGlobalId } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestDocument } from "./checklists.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

const LIMIT = 10;
const LOCAL_ONLY = !process.env.DATABASE_URL;

// RCL
const PARENT =
  "b3JnYW5pemF0aW9uOmN1c3RvbWVyXzFiMmQ2YzYwLTg2NzgtNDVhZC1iMzBkLWExMDMyM2MyYzQ0MQ==";

describe("checklists", () => {
  test.skipIf(LOCAL_ONLY)("default only lists worktemplates", async () => {
    const result = await execute(schema, TestDocument, {
      parent: PARENT,
      limit: LIMIT,
    });
    expect(result).toMatchSnapshot();
    expect(result.data?.checklists.edges.length).toBe(LIMIT);
    expect(result.errors).toBeFalsy();
  });

  describe.skipIf(LOCAL_ONLY)("filters", () => {
    test("withName", async () => {
      const result = await execute(schema, TestDocument, {
        parent: PARENT,
        limit: LIMIT,
        withName: "shallow",
      });
      expect(result).toMatchSnapshot();
      expect(result.errors).toBeFalsy();
    });

    test("withStatus", async () => {
      const result = await execute(schema, TestDocument, {
        parent: PARENT,
        limit: LIMIT,
        withStatus: ["open"],
      });
      expect(result).toMatchSnapshot();
      expect(result.errors).toBeFalsy();
    });

    test("withName & withStatus", async () => {
      const result = await execute(schema, TestDocument, {
        parent: PARENT,
        limit: LIMIT,
        withName: "eck",
        withStatus: ["open"],
      });
      expect(result).toMatchSnapshot();
      expect(result.errors).toBeFalsy();
    });
  });

  describe.skipIf(LOCAL_ONLY)("pagination", () => {
    test("forward", async () => {
      const r0 = await execute(schema, TestDocument, {
        parent: PARENT,
        limit: LIMIT,
      });
      expect(r0.errors).toBeFalsy();
      expect(r0.data?.checklists).toMatchObject({
        pageInfo: {
          // startCursor: expect.any(String),
          // endCursor: expect.any(String),
          hasNextPage: true,
          hasPreviousPage: false,
        },
      });
      expect(r0.data?.checklists.edges.length).toBe(LIMIT);

      const r1 = await execute(schema, TestDocument, {
        parent: PARENT,
        cursor: r0.data?.checklists.pageInfo.endCursor ?? undefined,
        limit: LIMIT,
      });
      expect(r1.errors).toBeFalsy();
      expect(r1.data?.checklists).toMatchObject({
        totalCount: r0.data?.checklists.totalCount, // should not change
        pageInfo: {
          hasNextPage: false,
          hasPreviousPage: false,
        },
      });
      // FIXME: all of these tests are hardcoded right now :P
      expect(r1.data?.checklists.edges.length).toBe(2);

      const s0 = new Set(r0.data?.checklists.edges.map(e => e.node.id) ?? []);
      const s1 = new Set(r1.data?.checklists.edges.map(e => e.node.id) ?? []);
      expect(r0.data?.checklists.edges.length).toBe(s0.size);
      expect(r1.data?.checklists.edges.length).toBe(s1.size);
      expect(s0.isDisjointFrom(s1)).toBeTrue();
    });
  });

  test("invalid parent", async () => {
    const result = await execute(schema, TestDocument, {
      parent: testGlobalId(),
      limit: LIMIT,
    });
    expect(result.errors?.at(0)).toMatchObject({
      message: "Type '__test__' is an invalid parent type for type 'Checklist'",
      extensions: {
        code: "TYPE_ERROR",
      },
    });
  });

  describe("pagination", () => {
    test("invalid cursor", async () => {
      const result = await execute(schema, TestDocument, {
        parent: PARENT,
        cursor: testGlobalId(),
        limit: LIMIT,
        withStatus: ["open"],
      });
      expect(result.errors?.at(0)).toMatchObject({
        message:
          "Type '__test__' is an invalid cursor type for type 'Checklist'",
        extensions: {
          code: "TYPE_ERROR",
        },
      });
    });
  });
});
