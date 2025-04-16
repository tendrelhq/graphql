import { describe, expect, test } from "bun:test";
import { extractPageInfo } from "./api";

describe("extractPageInfo", () => {
  test("cannot paginate without content-range", () => {
    expect(() => extractPageInfo(new Response())).toThrow(
      "cannot paginate without content-range",
    );
  });

  test("unsatisfiable", () => {
    const res = new Response(null, {
      headers: {
        "Content-Range": "*/1",
      },
      status: 206,
    });
    expect(extractPageInfo(res)).toEqual({
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: 1,
    });
  });

  test("ok, hasNext", () => {
    const res = new Response(null, {
      headers: {
        "Content-Range": "0-10/42",
      },
      status: 206,
    });
    expect(extractPageInfo(res)).toEqual({
      pageInfo: {
        hasNextPage: true,
        hasPreviousPage: false,
        endCursor: "10",
        startCursor: "0",
      },
      totalCount: 42,
    });
  });

  test("ok, done", () => {
    const res = new Response(null, {
      headers: {
        "Content-Range": "35-41/42",
      },
      status: 206,
    });
    expect(extractPageInfo(res)).toEqual({
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: true,
        endCursor: "41",
        startCursor: "35",
      },
      totalCount: 42,
    });
  });
});
