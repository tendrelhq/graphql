import { afterAll, describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { execute, testGlobalId } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestAssignDocument } from "./assign.test.generated";
import { TestUnassignDocument } from "./unassign.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

process.env.X_TENDREL_USER = "user_2iADtxE5UonU4KO5lphsG59bkR9";

const CHECKLIST =
  "d29ya2luc3RhbmNlOndvcmstaW5zdGFuY2VfNWYxNmFkYzQtM2IyZS00Y2ZkLThlOTEtZDU2OGRjYmJmZjE4";
const RUGG =
  "d29ya2VyOndvcmtlci1pbnN0YW5jZV9jYmNiNTYwNy0zNzNhLTQ1ZGYtYWFlMC0wMWJkZGRjNzQ0ZTQ=";
const MIKE =
  "d29ya2VyOndvcmtlci1pbnN0YW5jZV83NWJmMjgwOC1hNDk2LTQxOGItOTg1Zi03OTIzZmJjMjVkMzE=";

describe.skipIf(!!process.env.CI)("assign, assign again, unassign", () => {
  test("assign", async () => {
    const result = await execute(schema, TestAssignDocument, {
      entity: CHECKLIST,
      to: RUGG,
    });
    expect(result).toMatchSnapshot();
  });

  test("assign again", async () => {
    const result = await execute(schema, TestAssignDocument, {
      entity: CHECKLIST,
      to: MIKE,
    });
    expect(result.errors?.at(0)).toMatchObject({
      message: "Entity already assigned",
      extensions: {
        code: "E_ASSIGN_CONFLICT",
      },
    });
  });

  test("unassign", async () => {
    const result = await execute(schema, TestUnassignDocument, {
      entity: CHECKLIST,
      from: RUGG,
    });
    expect(result).toMatchSnapshot();
  });

  afterAll(async () => {
    await execute(schema, TestUnassignDocument, {
      entity: CHECKLIST,
      from: RUGG,
    });
  });
});

describe.skipIf(!!process.env.CI)("not assignable", () => {
  test("entity", async () => {
    const result = await execute(schema, TestAssignDocument, {
      entity: testGlobalId(),
      to: RUGG,
    });
    expect(result.errors?.at(0)).toMatchObject({
      message: "Entity cannot be assigned",
      extensions: {
        code: "E_NOT_ASSIGNABLE",
      },
    });
  });

  test("to", async () => {
    const result = await execute(schema, TestAssignDocument, {
      entity: CHECKLIST,
      to: testGlobalId(),
    });
    expect(result.errors?.at(0)).toMatchObject({
      message: "Entity cannot be assigned",
      extensions: {
        code: "E_NOT_ASSIGNABLE",
      },
    });
  });
});

describe("itempotency", () => {
  test("operation is idempotent", async () => {
    const r0 = await execute(schema, TestAssignDocument, {
      entity: CHECKLIST,
      to: RUGG,
    });
    const r1 = await execute(schema, TestAssignDocument, {
      entity: CHECKLIST,
      to: RUGG,
    });
    expect(r0).toEqual(r1);
  });

  afterAll(async () => {
    await execute(schema, TestUnassignDocument, {
      entity: CHECKLIST,
      from: RUGG,
    });
  });
});
