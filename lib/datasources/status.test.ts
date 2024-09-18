import { describe, expect, test } from "bun:test";
import { makeStatusLoader } from "./status";
import { encodeGlobalId } from "@/schema/system";

// biome-ignore lint/suspicious/noExplicitAny:
const loader = makeStatusLoader({} as any);

describe.skipIf(!!process.env.CI)("status loader", () => {
  test("no underlying types", async () => {
    const data = await loader.load(
      // workresults don't have statuses, those would be instances
      encodeGlobalId({ type: "workresult", id: "foobar" }),
    );

    expect(data).toBeUndefined();
  });
});
