import { describe, expect, test } from "bun:test";
import { schema } from "@/schema/final";
import { encodeGlobalId } from "@/schema/system";
import { execute } from "@/test/prelude";
import {
  TestMftEntrypointDocument,
  TestMftRefetchQueryDocument,
} from "./mft.test.generated";

describe.skipIf(!!process.env.CI)("MFT", () => {
  test("entrypoint query", async () => {
    const result = await execute(schema, TestMftEntrypointDocument, {
      root: encodeGlobalId({
        type: "organization",
        id: "customer_83f6f643-132c-4255-ad9e-f3c37dc84885",
      }),
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  describe("refetch query", () => {
    test("with Location as node", async () => {
      const result = await execute(schema, TestMftRefetchQueryDocument, {
        node: encodeGlobalId({
          type: "location",
          id: "location_a8bcb43b-d11c-4d05-855c-5d6586c2da35",
        }),
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    test("with Task as node", async () => {
      const result = await execute(schema, TestMftRefetchQueryDocument, {
        node: encodeGlobalId({
          type: "worktemplate",
          id: "work-template_1bf31cd5-8fc2-47b1-a28f-e4bc5513e028",
        }),
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });
  });
});
