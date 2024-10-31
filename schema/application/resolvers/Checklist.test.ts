import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { encodeGlobalId } from "@/schema/system";
import { execute } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestChecklistDocument } from "./Checklist.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

describe.skipIf(!!process.env.CI)("Checklist", () => {
  test("ast", async () => {
    const entity = encodeGlobalId({
      type: "worktemplate",
      id: "work-template_77a55567-6b2b-4506-9d2b-f375e0c29e3f",
    });
    const result = await execute(schema, TestChecklistDocument, {
      entity,
    });
    expect(result.errors).toBeFalsy();
    expect(result).toMatchSnapshot();
  });

  test("ecs", async () => {
    const entity = encodeGlobalId({
      type: "workinstance",
      id: "work-instance_0bf7fc40-4e0a-4714-8b81-a4d7bc696158",
    });
    const result = await execute(schema, TestChecklistDocument, {
      entity,
    });
    expect(result.errors).toBeFalsy();
    expect(result).toMatchSnapshot();
  });
});
