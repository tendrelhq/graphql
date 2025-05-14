import { describe, expect, test } from "bun:test";
import { schema } from "@/schema/final";
import { createTestContext, execute } from "@/test/prelude";
import { TestLanguagesQueryDocument } from "./languages.test.generated";

const ctx = await createTestContext();

describe("languages", () => {
  test("works", async () => {
    const result = await execute(ctx, schema, TestLanguagesQueryDocument);
    expect(result.data?.languages.slice(0, 10)).toMatchSnapshot();
  });
});
