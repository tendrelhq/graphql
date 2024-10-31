import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { encodeGlobalId } from "@/schema/system";
import { execute, testGlobalId } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestSetStatusDocument } from "./setStatus.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

describe.skipIf(!!process.env.CI)("setStatus", () => {
  test("workinstance", async () => {
    const result = await execute(schema, TestSetStatusDocument, {
      entity: encodeGlobalId({
        type: "workinstance",
        id: "work-instance_93c61cb5-e5ec-43e1-8777-d9f6e930e6b0",
      }),
      input: {
        open: {
          at: {
            instant: Date.now().toString(),
          },
        },
      },
    });

    expect(result).toMatchSnapshot();
  });

  test("workresultinstance", async () => {
    const result = await execute(schema, TestSetStatusDocument, {
      parent: encodeGlobalId({
        type: "workinstance",
        id: "work-instance_93c61cb5-e5ec-43e1-8777-d9f6e930e6b0",
      }),
      entity: encodeGlobalId({
        type: "workresultinstance",
        id: "work-instance_93c61cb5-e5ec-43e1-8777-d9f6e930e6b0",
        suffix: "work-result_fa536e61-2e9f-480c-b815-5cb1ec0a0f79",
      }),
      input: {
        closed: {
          at: {
            instant: Date.now().toString(),
          },
        },
      },
    });

    expect(result).toMatchSnapshot();
  });

  test("invalid status change", async () => {
    const result = await execute(schema, TestSetStatusDocument, {
      parent: encodeGlobalId({
        type: "workinstance",
        id: "work-instance_93c61cb5-e5ec-43e1-8777-d9f6e930e6b0",
      }),
      entity: encodeGlobalId({
        type: "workresultinstance",
        id: "work-instance_93c61cb5-e5ec-43e1-8777-d9f6e930e6b0",
        suffix: "work-result_fa536e61-2e9f-480c-b815-5cb1ec0a0f79",
      }),
      input: {
        inProgress: {
          at: {
            instant: Date.now().toString(),
          },
        },
      },
    });

    expect(result).toMatchSnapshot();
  });

  test("entity cannot have its status changed", async () => {
    const result = await execute(schema, TestSetStatusDocument, {
      entity: testGlobalId(),
      input: {
        open: {
          at: {
            instant: Date.now().toString(),
          },
        },
      },
    });
    expect(result).toMatchSnapshot();
  });
});
