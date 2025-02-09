import { describe, expect, test } from "bun:test";
import { encodeGlobalId } from "@/schema/system";
import { testGlobalId } from "@/test/prelude";
import { makeRequirementLoader } from "./requirement";

// biome-ignore lint/suspicious/noExplicitAny:
const makeLoader = () => makeRequirementLoader({} as any);

describe.skip("requirement loader", () => {
  test("workinstance", async () => {
    const data = await makeLoader().load(
      encodeGlobalId({
        type: "workinstance",
        id: "work-instance_37b5c0b5-0b48-492a-98f7-6690b0328095",
      }),
    );
    expect(data).toMatchSnapshot();
  });

  test("worktemplate", async () => {
    const data = await makeLoader().load(
      encodeGlobalId({
        type: "worktemplate",
        id: "1462a4b5-0cc9-424f-9856-7b845d86080c",
      }),
    );
    expect(data).toMatchSnapshot();
  });

  test("workresult", async () => {
    const data = await makeLoader().load(
      encodeGlobalId({
        type: "workresult",
        id: "8d505d8f-5958-4762-aa22-bb57129f1589",
      }),
    );
    expect(data).toMatchSnapshot();
  });

  test("workresultinstance", async () => {
    const data = await makeLoader().load(
      encodeGlobalId({
        type: "workresultinstance",
        id: "work-instance_cdb4d9b2-3016-4fcb-9104-3298d1999a5d", // workinstance.id
        suffix: "8d505d8f-5958-4762-aa22-bb57129f1589", // workresult.id
      }),
    );
    expect(data).toMatchSnapshot();
  });

  test("not found", async () => {
    const data = await makeLoader().load(testGlobalId());
    expect(data).toBeUndefined();
  });
});
