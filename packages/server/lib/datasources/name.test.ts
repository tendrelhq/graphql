import { describe, expect, test } from "bun:test";
import { encodeGlobalId } from "@/schema/system";
import { testGlobalId } from "@/test/prelude";
import { makeDisplayNameLoader } from "./name";

// biome-ignore lint/suspicious/noExplicitAny:
const makeLoader = () => makeDisplayNameLoader({} as any);

describe.skip("status loader", () => {
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
        id: "a08f4b6a-166e-4e0e-a770-834b89732102",
      }),
    );
    expect(data).toMatchSnapshot();
  });

  test("workresultinstance", async () => {
    const data = await makeLoader().load(
      encodeGlobalId({
        type: "workresultinstance",
        id: "work-instance_37b5c0b5-0b48-492a-98f7-6690b0328095", // workinstance.id
        suffix: "fb9b811a-ec70-4421-a931-6e654a0fa864", // workresult.id
      }),
    );
    expect(data).toMatchSnapshot();
  });

  test("not found", async () => {
    const data = makeLoader().load(testGlobalId());
    expect(data).rejects.toThrow(/No DisplayName/);
  });
});
