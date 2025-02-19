import { describe, expect, test } from "bun:test";
import { schema } from "@/schema/final";
import type { GraphQLScalarType } from "graphql";
import { Kind } from "graphql/language";
import type { GqlUrl } from "./url";

const url = schema.getType("URL") as GraphQLScalarType<GqlUrl, string>;

describe("URL", () => {
  describe("valid - localhost", () => {
    test("serialize", () => {
      expect(url.serialize(new URL("http://localhost/"))).toBe(
        "http://localhost/",
      );
    });

    test("parseValue", () => {
      expect(url.parseValue("http://localhost/")).toMatchObject(
        new URL("http://localhost/"),
      );
    });

    test("parseLiteral", () => {
      expect(
        url.parseLiteral({ value: "http://localhost/", kind: Kind.STRING }, {}),
      ).toMatchObject(new URL("http://localhost/"));
    });
  });

  describe("valid - localhost with port", () => {
    test("serialize", () => {
      expect(url.serialize(new URL("http://localhost:3000/"))).toBe(
        "http://localhost:3000/",
      );
    });

    test("parseValue", () => {
      expect(url.parseValue("http://localhost:3000/")).toMatchObject(
        new URL("http://localhost:3000/"),
      );
    });

    test("parseLiteral", () => {
      expect(
        url.parseLiteral(
          { value: "http://localhost:3000/", kind: Kind.STRING },
          {},
        ),
      ).toMatchObject(new URL("http://localhost:3000/"));
    });
  });

  describe("invalid", () => {
    describe("not a URL", () => {
      expect(() => url.serialize("invalidurlexample")).toThrow(/is not a URL/);
    });

    test("parseValue invalidurlexample", () => {
      expect(() => url.parseValue("invalidurlexample")).toThrow(
        /cannot be parsed as a URL/,
      );
    });

    test("parseLiteral invalidurlexample", () => {
      expect(() =>
        url.parseLiteral({ value: "invalidurlexample", kind: Kind.STRING }, {}),
      ).toThrow(/cannot be parsed as a URL/);
    });
  });

  describe("not a string", () => {
    test("serialize", () => {
      expect(() => url.serialize(123)).toThrow();
    });

    test("parseValue", () => {
      expect(() => url.parseValue(123)).toThrow();
    });

    test("parseLiteral", () => {
      expect(() =>
        url.parseLiteral({ value: "123", kind: Kind.INT }, {}),
      ).toThrow();
    });
  });

  describe("not a empty string", () => {
    test("serialize", () => {
      expect(() => url.serialize("")).toThrow();
    });

    test("parseValue", () => {
      expect(() => url.parseValue("")).toThrow();
    });

    test("parseLiteral", () => {
      expect(() =>
        url.parseLiteral({ value: "", kind: Kind.STRING }, {}),
      ).toThrow();
    });
  });
});
