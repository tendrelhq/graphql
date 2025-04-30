import { describe, expect, test } from "bun:test";
import { schema } from "@/schema/final";
import { execute } from "@/test/prelude";
import { TestAssignableDocument } from "./assignable.test.generated";

const CHECKLIST =
  "d29ya2luc3RhbmNlOndvcmstaW5zdGFuY2VfODkzMGFkMTItNDcxZi00MDZhLWE0YjYtMGYwZjI3ZTgwMzk2";
const RUGG =
  "d29ya2VyOndvcmtlci1pbnN0YW5jZV9jYmNiNTYwNy0zNzNhLTQ1ZGYtYWFlMC0wMWJkZGRjNzQ0ZTQ=";
const NOT_ASSIGNABLE =
  "b3JnYW5pemF0aW9uOmN1c3RvbWVyXzFiMmQ2YzYwLTg2NzgtNDVhZC1iMzBkLWExMDMyM2MyYzQ0MQ==";

describe.skip("assignable", () => {
  test("workers", async () => {
    const result = await execute(schema, TestAssignableDocument, {
      entity: CHECKLIST,
    });
    expect(result).toMatchSnapshot();
  });

  describe("not assignable", () => {
    test("entity", async () => {
      const result = await execute(schema, TestAssignableDocument, {
        entity: NOT_ASSIGNABLE,
        to: RUGG,
      });
      expect(result).toMatchSnapshot();
    });
  });
});
