import { describe, expect, test } from "bun:test";
import { encodeGlobalId } from "@/schema/system";
import { testGlobalId } from "@/test/prelude";
import { assert, buildPaginationArgs } from "./util";

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

describe("assert", () => {
  test("ok", () => {
    expect(() => assert(true)).not.toThrow();
  });

  test("fail", () => {
    expect(() => assert(false)).toThrow("assertion failed");
  });

  test("don't panic in production", () => {
    const nodeEnv = process.env.NODE_ENV;
    process.env.NODE_ENV = "production";
    expect(() => assert(false)).not.toThrow();
    process.env.NODE_ENV = nodeEnv;
  });

  test("don't panic when explicitly disabled", () => {
    process.env.DISABLE_ASSERTIONS = "";
    expect(() => assert(false)).not.toThrow();
    process.env.DISABLE_ASSERTIONS = undefined;
  });
});
