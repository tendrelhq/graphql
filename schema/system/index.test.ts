import { expect, test } from "bun:test";
import { decodeGlobalId, encodeGlobalId } from ".";

test("global id codec", () => {
  const encoded = encodeGlobalId({ type: "foo", id: "420af" });
  const decoded = decodeGlobalId(encoded);
  expect(decoded).toEqual({ type: "foo", id: "420af" });
  expect(encodeGlobalId(decoded)).toEqual(encoded);
});
