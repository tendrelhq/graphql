import { describe, expect, test } from "bun:test";
import { schema } from "@/schema/final";
import { encodeGlobalId } from "@/schema/system";
import { execute } from "@/test/prelude";
import { TestSetValueDocument } from "./setValue.test.generated";

process.env.X_TENDREL_USER = "user_2iADtxE5UonU4KO5lphsG59bkR9";

describe.skip("setValue", () => {
  test("no delta", async () => {
    const result = await execute(schema, TestSetValueDocument, {
      parent:
        "d29ya2luc3RhbmNlOndvcmstaW5zdGFuY2VfZDZjNTljM2EtOWQ1MS00MDc0LTllNjItZTkzZTgxOWIxZWFh",
      entity: encodeGlobalId({
        type: "workresultinstance",
        id: "work-instance_d6c59c3a-9d51-4074-9e62-e93e819b1eaa",
        suffix: "work-result_f8759c77-58c0-4ecf-b3c0-6cf76c4e22b4",
      }),
      input: {
        number: {
          // To test with delta:
          // 1. run as is; will pass
          // 2. increment to 43, run again; will fail with delta AND value diff
          // 3. decrement to 42, run again; will fail with delta diff
          // 4. run again; will pass
          value: 42,
        },
      },
    });
    expect(result).toMatchSnapshot();
  });

  test("entity is not mutable", async () => {
    const result = await execute(schema, TestSetValueDocument, {
      parent:
        "d29ya2luc3RhbmNlOndvcmstaW5zdGFuY2VfZDZjNTljM2EtOWQ1MS00MDc0LTllNjItZTkzZTgxOWIxZWFh",
      entity: encodeGlobalId({
        type: "foo",
        id: "foo",
      }),
      input: {
        string: {
          value: "hello world",
        },
      },
    });
    expect(result).toMatchSnapshot();
  });

  test("global id invariant", async () => {
    const result = await execute(schema, TestSetValueDocument, {
      parent:
        "d29ya2luc3RhbmNlOndvcmstaW5zdGFuY2VfZDZjNTljM2EtOWQ1MS00MDc0LTllNjItZTkzZTgxOWIxZWFh",
      entity: encodeGlobalId({
        type: "workresultinstance",
        id: "foo",
      }),
      input: {
        string: {
          value: "hello world",
        },
      },
    });
    expect(result).toMatchSnapshot();
  });
});
