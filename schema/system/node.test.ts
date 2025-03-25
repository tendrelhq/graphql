import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { Task } from "@/schema/system/component/task";
import {
  cleanup,
  createTestContext,
  findAndEncode,
  setup,
} from "@/test/prelude";
import { map } from "@/util";
import { deleteNode } from "./node";

const ctx = await createTestContext();

describe("node", () => {
  // See beforeAll for initialization of these variables.
  let CUSTOMER: string;
  let TEMPLATE: Task;

  test("delete", async () => {
    const result = await deleteNode(TEMPLATE.id);
    expect([TEMPLATE.id]).toEqual(result);
  });

  beforeAll(async () => {
    const logs = await setup(ctx);
    CUSTOMER = findAndEncode("customer", "organization", logs);
    TEMPLATE = map(
      findAndEncode("task", "worktemplate", logs),
      id => new Task({ id }),
    );
  });

  afterAll(async () => {
    await cleanup(CUSTOMER);
  });
});
