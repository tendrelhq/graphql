import { describe, expect, test } from "bun:test";
import { schema } from "@/schema/final";
import { encodeGlobalId } from "@/schema/system";
import { execute } from "@/test/prelude";
import { TestChecklistResultDocument } from "./ChecklistResult.test.generated";

describe.skip("ChecklistResult", () => {
  test("ast", async () => {
    const entity = encodeGlobalId({
      type: "workresult",
      id: "work-result_5b325ee3-68ef-4d42-8475-bc5e91e50a85",
    });
    const result = await execute(schema, TestChecklistResultDocument, {
      entity,
    });
    expect(result.errors).toBeFalsy();
    expect(result).toMatchSnapshot();
  });

  test("ecs", async () => {
    const entity = encodeGlobalId({
      type: "workresultinstance",
      id: "work-instance_7fc17a8c-73f9-4ea7-9f64-90a11c1f4e54",
      suffix: "work-result_5b325ee3-68ef-4d42-8475-bc5e91e50a85",
    });
    const result = await execute(schema, TestChecklistResultDocument, {
      entity,
    });
    expect(result.errors).toBeFalsy();
    expect(result).toMatchSnapshot();
  });
});
