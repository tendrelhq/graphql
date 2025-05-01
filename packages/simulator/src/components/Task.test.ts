import { describe, expect, test } from "bun:test";
import { formatDuration } from "./Task";

describe("Task", () => {
  test("formatDuration(500)", () => {
    expect(formatDuration(500)).toBe("500ms");
  });
  test("formatDuration(1000)", () => {
    expect(formatDuration(1000)).toBe("1s");
  });
  test("formatDuration(30000)", () => {
    expect(formatDuration(30000)).toBe("30s");
  });
  test("formatDuration(60000)", () => {
    expect(formatDuration(60000)).toBe("1m");
  });
  test("formatDuration(70000)", () => {
    expect(formatDuration(70000)).toBe("1m 10s");
  });
});
