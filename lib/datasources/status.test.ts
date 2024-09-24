import { describe, expect, test } from "bun:test";
import { makeStatusLoader } from "./status";
import { encodeGlobalId } from "@/schema/system";

// biome-ignore lint/suspicious/noExplicitAny:
const loader = makeStatusLoader({} as any);

describe.skipIf(!!process.env.CI)("status loader", () => {
  test("open", async () => {
    const data = await loader.load(
      "d29ya2luc3RhbmNlOndvcmstaW5zdGFuY2VfMDA4NWE3Y2YtMmI5ZC00MDU2LTlhYzUtYTBiNTgxYTliNmZhOnN0YXR1cw==",
    );
    expect(data).toMatchSnapshot();
  });

  test("item - open", async () => {
    const data = await loader.load(
      "d29ya3Jlc3VsdGluc3RhbmNlOjE0ZGVjYWE5LWNmZjItNDYxNi05Yjc1LTc5Mzg3OTRkMjk0MA==",
    );
    expect(data).toMatchSnapshot();
  });

  test("no underlying types", async () => {
    const data = await loader.load(
      // workresults don't have statuses
      encodeGlobalId({ type: "workresult", id: "foobar" }),
    );

    expect(data).toBeUndefined();
  });
});
