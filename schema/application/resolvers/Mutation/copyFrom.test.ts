import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { encodeGlobalId } from "@/schema/system";
import { execute } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestCopyFromDocument } from "./copyFrom.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

describe.skipIf(!!process.env.CI)("copyFrom", () => {
  test("when entity is a template", async () => {
    const result = await execute(schema, TestCopyFromDocument, {
      entity: encodeGlobalId({
        type: "worktemplate",
        id: "work-template_77a55567-6b2b-4506-9d2b-f375e0c29e3f",
      }),
      options: {
        withStatus: "open",
      },
    });

    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("when entity is an instance", async () => {
    const result = await execute(schema, TestCopyFromDocument, {
      entity: encodeGlobalId({
        type: "workinstance",
        id: "work-instance_14162314-3e50-41f9-9902-74a0c186b922",
      }),
      options: {
        withStatus: "open",
      },
    });

    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });
});
