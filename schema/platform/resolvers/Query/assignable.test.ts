import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { execute } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestAssignableDocument } from "./assignable.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

process.env.X_TENDREL_USER = "user_2iADtxE5UonU4KO5lphsG59bkR9";

const CHECKLIST =
  "d29ya2luc3RhbmNlOndvcmstaW5zdGFuY2VfMDA4NWE3Y2YtMmI5ZC00MDU2LTlhYzUtYTBiNTgxYTliNmZh";
const RUGG =
  "d29ya2VyOndvcmtlci1pbnN0YW5jZV9jYmNiNTYwNy0zNzNhLTQ1ZGYtYWFlMC0wMWJkZGRjNzQ0ZTQ=";
const NOT_ASSIGNABLE =
  "b3JnYW5pemF0aW9uOmN1c3RvbWVyXzFiMmQ2YzYwLTg2NzgtNDVhZC1iMzBkLWExMDMyM2MyYzQ0MQ==";

describe.skipIf(!!process.env.CI)("assignable", () => {
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
