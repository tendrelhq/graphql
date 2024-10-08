import { describe, expect, test } from "bun:test";
import { buildPaginationArgs } from "./util";
import { testGlobalId } from "@/test/prelude";
import { encodeGlobalId } from "@/schema/system";

const CURSOR = encodeGlobalId({ type: "__test__", id: "1" });

describe("buildPaginationArgs", () => {
  test("first -> forward", () => {
    expect(
      buildPaginationArgs(
        {
          first: 10,
          after: CURSOR,
        },
        { defaultLimit: 5, maxLimit: 100 },
      ),
    ).toMatchObject({
      cursor: { type: "__test__", id: "1" },
      direction: "forward",
      limit: 10,
    });
  });

  test("last -> backward", () => {
    expect(
      buildPaginationArgs(
        {
          last: 10,
          before: CURSOR,
        },
        { defaultLimit: 5, maxLimit: 100 },
      ),
    ).toMatchObject({
      cursor: { type: "__test__", id: "1" },
      direction: "backward",
      limit: 10,
    });
  });

  test("default", () => {
    expect(
      buildPaginationArgs({}, { defaultLimit: 5, maxLimit: 100 }),
    ).toMatchObject({
      direction: "forward",
      limit: 5,
    });
  });
});
