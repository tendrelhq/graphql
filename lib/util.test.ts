import { afterEach, describe, expect, test } from "bun:test";
import { encodeGlobalId } from "@/schema/system";
import {
  assert,
  type Exact,
  buildPaginationArgs,
  map,
  mapOrElse,
} from "./util";

const CURSOR = encodeGlobalId({ type: "__test__", id: "1" });
const NODE_ENV = process.env.NODE_ENV;

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
    process.env.NODE_ENV = "test";
    expect(() => assert(true)).not.toThrow();
  });

  test("fail", () => {
    process.env.NODE_ENV = "test";
    expect(() => assert(false)).toThrow("assertion failed");
  });

  test("don't panic in production", () => {
    process.env.NODE_ENV = "production";
    expect(() => assert(false)).not.toThrow();
  });

  test("don't panic when explicitly disabled", () => {
    process.env.DISABLE_ASSERTIONS = "";
    expect(() => assert(false)).not.toThrow();
    process.env.DISABLE_ASSERTIONS = undefined;
  });

  afterEach(() => {
    process.env.NODE_ENV = NODE_ENV;
  });
});

describe("map", () => {
  // I am being intentionally verbose with all of these manual type
  // annotations. We are testing both runtime execution and type inference.

  test("over null", () => {
    const r: null = map(null, (_: never) => "foo");
    expect(r).toBeNull();
  });

  test("over undefined", () => {
    const r: undefined = map(undefined, (_: never) => "foo");
    expect(r).toBeUndefined();
  });

  test("over T", () => {
    const r: string = map("hello", (s: string) => `${s} world`);
    expect(r).toBe("hello world");
  });

  test("over nullable T", () => {
    const s = "hello" as string | null | undefined;
    const r: string | null | undefined = map(s, (s: string) => `${s} world`);
    expect(r).toBe("hello world");
  });
});

describe("mapOrElse", () => {
  // Ditto note above above verbose type annotations.

  test("over null", () => {
    const r: string = mapOrElse(null, (_: never) => "foo", "bar");
    expect(r).toBe("bar");
  });

  test("over undefined", () => {
    const r = mapOrElse(undefined, (_: never) => "foo", "bar");
    expect(r).toBe("bar");
  });

  test("over T", () => {
    const r = mapOrElse("hello", (s: string) => `${s} world`, "bar");
    expect(r).toBe("hello world");
  });

  test("orElse is a function", () => {
    const r = mapOrElse(
      null,
      (_: never) => "foo",
      () => "bar",
    );
    expect(r).toBe("bar");
  });
});

describe("type assertions", () => {
  test("Exact<T, U>", () => {
    true satisfies Exact<string, string>;
    true satisfies Exact<number, number>;
    true satisfies Exact<{ foo: "bar" }, { foo: "bar" }>;
    false satisfies Exact<string, number>;
    false satisfies Exact<{ bar: "foo" }, { foo: "bar" }>;
    false satisfies Exact<{ foo: "bar"; bar: 42 }, { foo: "bar" }>;
    false satisfies Exact<
      { foo: "bar"; bar: { baz: 42 } },
      { foo: "bar"; bar: { baz: "foo" } }
    >;
  });
});
