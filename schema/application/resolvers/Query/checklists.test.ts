import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { execute, testGlobalId } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestDocument } from "./checklists.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

const LIMIT = 10;
const SKIP_IN_CI = !!process.env.CI;

// Customer 0
const PARENT =
  "b3JnYW5pemF0aW9uOmN1c3RvbWVyXzQyY2I5NGVlLWVjMDctNGQzMy04OGVkLTlkNDk2NTllNjhiZQ==";

describe("checklists", () => {
  test.skipIf(SKIP_IN_CI)("AST entrypoint by default", async () => {
    const result = await execute(schema, TestDocument, {
      parent: PARENT,
      limit: LIMIT,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data?.checklists.edges.length).toBe(2);
    expect(result).toMatchSnapshot();
  });

  describe.skipIf(SKIP_IN_CI)("filters", () => {
    test("withName", async () => {
      const result = await execute(schema, TestDocument, {
        parent: PARENT,
        limit: LIMIT,
        withName: "please",
      });
      expect(result.errors).toBeFalsy();
      expect(result.data?.checklists.edges.length).toBe(1);
      expect(result).toMatchSnapshot();
    });

    test("withStatus", async () => {
      const result = await execute(schema, TestDocument, {
        parent: PARENT,
        limit: LIMIT,
        withStatus: ["open"],
      });
      expect(result.errors).toBeFalsy();
      expect(result.data?.checklists.edges.length).toBe(2);
      expect(result).toMatchSnapshot();
    });

    test("withName & withStatus", async () => {
      const result = await execute(schema, TestDocument, {
        parent: PARENT,
        limit: LIMIT,
        withName: "please",
        withStatus: ["open"],
      });
      expect(result.errors).toBeFalsy();
      expect(result.data?.checklists.edges.length).toBe(1);
      expect(result).toMatchSnapshot();
    });
  });

  describe.skipIf(SKIP_IN_CI)("pagination", () => {
    test("forward", async () => {
      const r0 = await execute(schema, TestDocument, {
        parent: PARENT,
        limit: 1,
      });
      expect(r0.errors).toBeFalsy();
      expect(r0.data?.checklists).toMatchObject({
        pageInfo: {
          hasNextPage: true,
          hasPreviousPage: false,
        },
      });
      expect(r0.data?.checklists.edges.length).toBe(1);

      const r1 = await execute(schema, TestDocument, {
        parent: PARENT,
        cursor: r0.data?.checklists.pageInfo.endCursor ?? undefined,
        limit: 5,
      });
      expect(r1.errors).toBeFalsy();
      expect(r1.data?.checklists).toMatchObject({
        totalCount: r0.data?.checklists.totalCount, // should not change
        pageInfo: {
          hasNextPage: false,
          hasPreviousPage: false,
        },
      });
      expect(r1.data?.checklists.edges.length).toBe(1);

      const s0 = new Set(r0.data?.checklists.edges.map(e => e.node.id) ?? []);
      const s1 = new Set(r1.data?.checklists.edges.map(e => e.node.id) ?? []);
      expect(r0.data?.checklists.edges.length).toBe(s0.size);
      expect(r1.data?.checklists.edges.length).toBe(s1.size);
      expect(s0.isDisjointFrom(s1)).toBeTrue();
    });
  });

  describe("invalid parent", async () => {
    test("ast (i.e. worktemplate)", async () => {
      const result = await execute(schema, TestDocument, {
        parent: testGlobalId(),
        limit: LIMIT,
        // <-- no filters mean we'll start in the AST
      });
      expect(result.errors?.at(0)).toMatchObject({
        message:
          "Type '__test__' is an invalid parent type for type 'Checklist'",
        extensions: {
          code: "TYPE_ERROR",
        },
      });
    });

    test("ecs (i.e. workinstance)", async () => {
      const result = await execute(schema, TestDocument, {
        parent: testGlobalId(),
        limit: LIMIT,
        withStatus: ["open"], // <-- this means we'll start in the ECS
      });
      expect(result.errors?.at(0)).toMatchObject({
        message:
          "Type '__test__' is an invalid parent type for type 'Checklist'",
        extensions: {
          code: "TYPE_ERROR",
        },
      });
    });
  });

  describe.skipIf(SKIP_IN_CI)("pagination", () => {
    test("invalid (ast) cursor", async () => {
      const result = await execute(schema, TestDocument, {
        parent: PARENT,
        cursor: testGlobalId(),
        limit: LIMIT,
      });
      expect(result.errors?.at(0)).toMatchObject({
        message:
          "Type '__test__' is an invalid cursor type for type 'Checklist'",
        extensions: {
          code: "TYPE_ERROR",
        },
      });
    });

    test("invalid (ecs) cursor", async () => {
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
