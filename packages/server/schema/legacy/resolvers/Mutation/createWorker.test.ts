import { describe, expect, test } from "bun:test";
import { randomUUID } from "node:crypto";
import { schema } from "@/schema/final";
import { execute } from "@/test/prelude";
import { TestCreateWorkerDocument } from "./createWorker.test.generated";

describe.skip("createWorker", () => {
  test("creates worker without conflict", async () => {
    const result = await execute(schema, TestCreateWorkerDocument, {
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
    expect(result).toMatchSnapshot();
  });

  test("duplicate_scan_code", async () => {
    const scanCode = randomUUID();

    await execute(schema, TestCreateWorkerDocument, {
      input: {
        active: true,
        languageId: "7ebd10ee-5018-4e11-9525-80ab5c6aebee",
        orgId:
          "b3JnYW5pemF0aW9uOmN1c3RvbWVyXzQyY2I5NGVlLWVjMDctNGQzMy04OGVkLTlkNDk2NTllNjhi\nZQ==",
        roleId: "1d8c3097-23f5-4cac-a4c5-ad0a75a181e4",
        firstName: "User",
        lastName: "1337",
        scanCode,
      },
    });

    const result = await execute(schema, TestCreateWorkerDocument, {
      input: {
        active: true,
        languageId: "7ebd10ee-5018-4e11-9525-80ab5c6aebee",
        orgId:
          "b3JnYW5pemF0aW9uOmN1c3RvbWVyXzQyY2I5NGVlLWVjMDctNGQzMy04OGVkLTlkNDk2NTllNjhi\nZQ==",
        roleId: "1d8c3097-23f5-4cac-a4c5-ad0a75a181e4",
        firstName: "User",
        lastName: "1337",
        scanCode,
      },
    });

    expect(result.errors?.at(0)).toMatchObject({
      extensions: {
        code: "duplicate_scan_code",
      },
    });
  });

  test("worker_already_exists", async () => {
    const result = await execute(schema, TestCreateWorkerDocument, {
      input: {
        active: true,
        languageId: "7ebd10ee-5018-4e11-9525-80ab5c6aebee",
        orgId:
          "b3JnYW5pemF0aW9uOmN1c3RvbWVyXzQyY2I5NGVlLWVjMDctNGQzMy04OGVkLTlkNDk2NTllNjhi\nZQ==",
        roleId: "1d8c3097-23f5-4cac-a4c5-ad0a75a181e4",
        userId:
          "dXNlcjp3b3JrZXJfNjlkNGMwNzUtMzlkMC00NDM3LWE5Y2MtN2I5MTJjN2JhMDQ5",
        firstName: "User",
        lastName: "1337",
      },
    });

    expect(result.errors?.at(0)).toMatchObject({
      extensions: {
        code: "worker_already_exists",
      },
    });
  });
});
