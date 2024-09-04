import { describe, expect, test } from "bun:test";
import { decodeGlobalId, decodeGlobalIdRaw, encodeGlobalId } from ".";

describe("global id codec", () => {
  test("there and back again", () => {
    const encoded = encodeGlobalId({ type: "foo", id: "420af" });
    expect(decodeGlobalIdRaw(encoded)).toEqual("foo:420af");

    const decoded = decodeGlobalId(encoded);
    expect(decoded).toEqual({ type: "foo", id: "420af", suffix: [] });

    expect(encodeGlobalId(decoded)).toEqual(encoded);
  });

  test("with suffix", () => {
    const encoded = encodeGlobalId({ type: "foo", id: "420af", suffix: "bar" });
    expect(decodeGlobalIdRaw(encoded)).toEqual("foo:420af:bar");
    const encoded2 = encodeGlobalId({
      type: "foo",
      id: "420af",
      suffix: ["bar"],
    });
    expect(encoded).toEqual(encoded2);

    const encoded3 = encodeGlobalId({
      type: "foo",
      id: "420af",
      suffix: ["bar", "baz"],
    });
    expect(decodeGlobalIdRaw(encoded3)).toEqual("foo:420af:bar:baz");
  });
});
