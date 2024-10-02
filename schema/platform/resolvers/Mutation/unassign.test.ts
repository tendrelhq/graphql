import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { execute } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestAssignDocument } from "./assign.test.generated";
import { TestUnassignDocument } from "./unassign.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

process.env.X_TENDREL_USER = "user_2iADtxE5UonU4KO5lphsG59bkR9";

const CHECKLIST =
  "d29ya2luc3RhbmNlOndvcmstaW5zdGFuY2VfMDA4NWE3Y2YtMmI5ZC00MDU2LTlhYzUtYTBiNTgxYTliNmZh";
const RUGG =
  "d29ya2VyOndvcmtlci1pbnN0YW5jZV9jYmNiNTYwNy0zNzNhLTQ1ZGYtYWFlMC0wMWJkZGRjNzQ0ZTQ=";
const MIKE =
  "d29ya2VyOndvcmtlci1pbnN0YW5jZV83NWJmMjgwOC1hNDk2LTQxOGItOTg1Zi03OTIzZmJjMjVkMzE=";
const NOT_ASSIGNABLE =
  "b3JnYW5pemF0aW9uOmN1c3RvbWVyXzFiMmQ2YzYwLTg2NzgtNDVhZC1iMzBkLWExMDMyM2MyYzQ0MQ==";

describe.skipIf(!!process.env.CI)("unassign", () => {
  test("operation", async () => {
    await execute(schema, TestAssignDocument, {
      entity: CHECKLIST,
      to: RUGG,
    });

    const result = await execute(schema, TestUnassignDocument, {
      entity: CHECKLIST,
      from: RUGG,
    });
    expect(result).toMatchSnapshot();
  });

  test("conflict", async () => {
    await execute(schema, TestAssignDocument, {
      entity: CHECKLIST,
      to: RUGG,
    });

    const result = await execute(schema, TestUnassignDocument, {
      entity: CHECKLIST,
      from: MIKE,
    });
    expect(result).toMatchSnapshot();
  });

  describe("not assignable", () => {
    test("entity", async () => {
      const result = await execute(schema, TestUnassignDocument, {
        entity: NOT_ASSIGNABLE,
        from: RUGG,
      });
      expect(result).toMatchSnapshot();
    });

    test("from", async () => {
      const result = await execute(schema, TestUnassignDocument, {
        entity: CHECKLIST,
        from: NOT_ASSIGNABLE,
      });
      expect(result).toMatchSnapshot();
    });
  });

  test("idempotent", async () => {
    await execute(schema, TestAssignDocument, {
      entity: CHECKLIST,
      to: RUGG,
    });

    await execute(schema, TestUnassignDocument, {
      entity: CHECKLIST,
      from: RUGG,
    });

    const result = await execute(schema, TestUnassignDocument, {
      entity: CHECKLIST,
      from: RUGG,
    });
    expect(result).toMatchSnapshot();
  });
});
