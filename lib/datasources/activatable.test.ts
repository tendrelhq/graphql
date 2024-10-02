import { describe, expect, test } from "bun:test";
import { encodeGlobalId } from "@/schema/system";
import { makeActiveLoader } from "./activatable";

// biome-ignore lint/suspicious/noExplicitAny:
const makeLoader = () => makeActiveLoader({} as any);

describe.skipIf(!!process.env.CI)("active loader", () => {
  test("load", async () => {
    const data = await makeLoader().load(
      "d29ya3RlbXBsYXRlOjgyN2RlNDE5LTQ0YmMtNGExMi1iOWFmLWI2NDFmYjU3NjQyOQ==",
    );
    expect(data).toMatchSnapshot();
  });

  test("no underlying types", async () => {
    const data = await makeLoader().load(
      // workinstances aren't activatable
      encodeGlobalId({ type: "workinstance", id: "foobar" }),
    );

    expect(data).toBeUndefined();
  });
});
