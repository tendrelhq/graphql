import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { encodeGlobalId } from "@/schema/system";
import { execute, testGlobalId } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestSetStatusDocument } from "./setStatus.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

process.env.X_TENDREL_USER = "user_2iADtxE5UonU4KO5lphsG59bkR9";

describe.skipIf(!!process.env.CI)("setStatus", () => {
  test("workinstance", async () => {
    const result = await execute(schema, TestSetStatusDocument, {
      entity: encodeGlobalId({
        type: "workinstance",
        id: "work-instance_35774847-ba19-4f23-b71e-e4cb7760e415",
      }),
      input: {
        // To test with delta:
        // 1. run as is; will pass
        // 2. change to inProgress, run again; will fail with delta AND status diff
        // 3. change back to open, run again; will fail with delta diff
        // 4. run again; will pass
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
        id: "work-instance_35774847-ba19-4f23-b71e-e4cb7760e415",
      }),
      entity: encodeGlobalId({
        type: "workresultinstance",
        id: "work-instance_35774847-ba19-4f23-b71e-e4cb7760e415",
        suffix: "work-result_a3f48541-bf6c-4739-94ee-985ab629e1e3",
      }),
      input: {
        // Follow the same procedure described above to test with delta.
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
