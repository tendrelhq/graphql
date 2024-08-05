import { describe, expect, test } from "bun:test";
import { Kind } from "graphql";
import { CronExpression } from "./CronExpression";

describe("CronExpression", () => {
  test("serialize()", () => {
    // "At 22:00 on every day-of-week from Monday through Friday."
    expect(CronExpression.serialize("0 22 * * 1-5")).toBe("0 22 * * 1-5");
  });

  test("parseValue()", () => {
    // "At 22:00 on every day-of-week from Monday through Friday."
    expect(CronExpression.parseValue("0 22 * * 1-5")).toBe("0 22 * * 1-5");
  });

  test("parseLiteral()", () => {
    // "At 22:00 on every day-of-week from Monday through Friday."
    expect(
      CronExpression.parseLiteral({ value: "0 22 * * 1-5", kind: Kind.STRING }),
    ).toBe("0 22 * * 1-5");
  });

  describe("invalid", () => {
    test("serialize()", () => {
      expect(() => CronExpression.serialize("invalid")).toThrow(
        /Value is not a valid CronExpression/,
      );
    });

    test("parseValue()", () => {
      expect(() => CronExpression.parseValue("invalid")).toThrow(
        /Value is not a valid CronExpression/,
      );
    });

    test("parseLiteral()", () => {
      expect(() =>
        CronExpression.parseLiteral({ value: "invalid", kind: Kind.STRING }),
      ).toThrow(/Value is not a valid CronExpression/);
    });

    describe("not a string", () => {
      test("serialize()", () => {
        expect(() => CronExpression.serialize(123)).toThrow(
          /Value is not a string/,
        );
      });

      test("parseValue()", () => {
        expect(() => CronExpression.parseValue(123)).toThrow(
          /Value is not a string/,
        );
      });

      test("parseLiteral()", () => {
        expect(() =>
          CronExpression.parseLiteral({ value: "123", kind: Kind.INT }),
        ).toThrow(/Can only validate strings as CronExpressions/);
      });
    });

    describe("not an empty string", () => {
      test("serialize()", () => {
        expect(() => CronExpression.serialize("")).toThrow();
      });

      test("parseValue()", () => {
        expect(() => CronExpression.parseValue("")).toThrow();
      });

      test("parseLiteral()", () => {
        expect(() =>
          CronExpression.parseLiteral({ value: "", kind: Kind.STRING }),
        ).toThrow();
      });
    });
  });
});
