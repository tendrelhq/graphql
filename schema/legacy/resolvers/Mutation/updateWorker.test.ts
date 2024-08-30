import { describe, expect, test } from "bun:test";
import { randomUUID } from "node:crypto";
import { resolvers, typeDefs } from "@/schema";
import { encodeGlobalId } from "@/schema/system";
import { execute } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { SetupTestUpdateWorkerDocument } from "./updateWorker.setup.test.generated";
import { TestUpdateWorkerDocument } from "./updateWorker.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

describe("updateWorker", () => {
  test("updates worker without conflict", async () => {
    const { data } = await execute(schema, SetupTestUpdateWorkerDocument, {
      input: {
        active: true,
        languageId: "7ebd10ee-5018-4e11-9525-80ab5c6aebee",
        orgId:
          "b3JnYW5pemF0aW9uOmN1c3RvbWVyXzQyY2I5NGVlLWVjMDctNGQzMy04OGVkLTlkNDk2NTllNjhi\nZQ==",
        roleId: "1d8c3097-23f5-4cac-a4c5-ad0a75a181e4",
        firstName: "User",
        lastName: "1337",
      },
    });

    if (!data) throw "failed to setup test";

    const result = await execute(schema, TestUpdateWorkerDocument, {
      input: {
        id: data.createWorker.node.id,
        languageId: "c3f18dd6-bfc5-4ba5-b3c1-bb09e2a749a9",
        roleId: "a804d5b8-23ef-4592-9486-14857efb1a0a",
        firstName: "1337",
        lastName: "User",
        displayName: "1337 User",
      },
    });

    expect(result.data?.updateWorker.node).toMatchSnapshot();
  });

  test("worker_not_found", async () => {
    const result = await execute(schema, TestUpdateWorkerDocument, {
      input: {
        id: encodeGlobalId({
          type: "workerinstance", // doesn't matter for this test
          id: randomUUID(),
        }),
      },
    });

    expect(result.errors?.at(0)).toMatchObject({
      message: "entity_not_found",
      extensions: {
        type: "worker",
      },
    });
  });

  test("duplicate_scan_code", async () => {
    const { data } = await execute(schema, SetupTestUpdateWorkerDocument, {
      input: {
        active: true,
        languageId: "7ebd10ee-5018-4e11-9525-80ab5c6aebee",
        orgId:
          "b3JnYW5pemF0aW9uOmN1c3RvbWVyXzQyY2I5NGVlLWVjMDctNGQzMy04OGVkLTlkNDk2NTllNjhi\nZQ==",
        roleId: "1d8c3097-23f5-4cac-a4c5-ad0a75a181e4",
        firstName: "User",
        lastName: "1337",
      },
    });

    if (!data) throw "failed to setup test";

    const result = await execute(schema, TestUpdateWorkerDocument, {
      input: {
        id: data.createWorker.node.id,
        scanCode: "rugg", // taken by yours truly :D
      },
    });

    expect(result.errors?.at(0)).toMatchObject({
      extensions: {
        code: "duplicate_scan_code",
      },
    });
  });
});
