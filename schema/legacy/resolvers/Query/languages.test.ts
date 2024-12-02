import { describe, expect, test } from "bun:test";
import { schema } from "@/schema/final";
import { execute } from "@/test/prelude";
import { TestLanguagesQueryDocument } from "./languages.test.generated";

describe.skipIf(!!process.env.CI)("languages", () => {
  test("works", async () => {
    const result = await execute(schema, TestLanguagesQueryDocument);
    expect(result).toMatchSnapshot();
  });
});
