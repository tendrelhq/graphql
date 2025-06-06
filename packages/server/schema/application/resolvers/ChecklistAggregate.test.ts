import { describe, expect, test } from "bun:test";
import { schema } from "@/schema/final";
import { encodeGlobalId } from "@/schema/system";
import { createTestContext, execute } from "@/test/prelude";
import { TestChecklistAggDocument } from "./ChecklistAggregate.test.generated";

const ASSIGNEE = encodeGlobalId({
  type: "worker",
  id: "worker-instance_cbcb5607-373a-45df-aae0-01bdddc744e4",
});
const CUSTOMER = encodeGlobalId({
  type: "organization",
  id: "customer_1b2d6c60-8678-45ad-b30d-a10323c2c441",
});
const TEMPLATE = encodeGlobalId({
  type: "worktemplate",
  id: "a2b2004d-49a6-4fa2-b8e5-d86df0041fdd",
});
const DUE_ON_BEFORE = "1733251472196"; // Date.now() circa Tue Dec 03 2024 10:45

const ctx = await createTestContext();

describe.skip("ChecklistAggregate", () => {
  test("when parent is customer", async () => {
    const result = await execute(ctx, schema, TestChecklistAggDocument, {
      parent: CUSTOMER,
      assignedTo: [ASSIGNEE],
      dueOnInput: {
        before: {
          instant: DUE_ON_BEFORE,
        },
      },
    });
    expect(result.errors).toBeFalsy();
    expect(result).toMatchSnapshot();
  });

  test("when parent is template", async () => {
    const result = await execute(ctx, schema, TestChecklistAggDocument, {
      parent: TEMPLATE,
      assignedTo: [ASSIGNEE],
      dueOnInput: {
        before: {
          instant: DUE_ON_BEFORE,
        },
      },
    });
    expect(result.errors).toBeFalsy();
    expect(result).toMatchSnapshot();
  });
});
