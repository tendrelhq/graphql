import { describe, expect, test } from "bun:test";
import { chunkArray } from "./chunk";

describe("chunk", () => {
  test("chunkArray", () => {
    expect(chunkArray([1, 2, 3, 4, 5, 6, 7, 8, 9], 2)).toEqual([
      [1, 2],
      [3, 4],
      [5, 6],
      [7, 8],
      [9],
    ]);
  });
});
