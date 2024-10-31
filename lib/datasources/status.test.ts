import { describe, expect, test } from "bun:test";
import { testGlobalId } from "@/test/prelude";
import { makeStatusLoader } from "./status";

// biome-ignore lint/suspicious/noExplicitAny:
const makeLoader = () => makeStatusLoader({} as any);

describe.skipIf(!!process.env.CI)("status loader", () => {
  test("open", async () => {
    const data = await makeLoader().load(
      "d29ya2luc3RhbmNlOndvcmstaW5zdGFuY2VfODkzMGFkMTItNDcxZi00MDZhLWE0YjYtMGYwZjI3ZTgwMzk2",
    );
    expect(data).toMatchSnapshot();
  });

  test("item - open", async () => {
    const data = await makeLoader().load(
      "d29ya3Jlc3VsdGluc3RhbmNlOndvcmstaW5zdGFuY2VfODkzMGFkMTItNDcxZi00MDZhLWE0YjYtMGYwZjI3ZTgwMzk2OndvcmstcmVzdWx0X2E3ODQ0MDM2LTRmZTItNDZkZC1hY2I5LTY2YmY1NzU3YWZlZA==",
    );
    expect(data).toMatchSnapshot();
  });

  test("no underlying types", async () => {
    const data = await makeLoader().load(testGlobalId());
    expect(data).toBeUndefined();
  });
});
