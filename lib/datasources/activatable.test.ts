import { describe, expect, test } from "bun:test";
import { encodeGlobalId } from "@/schema/system";
import { makeActivatableLoader } from "./activatable";

// biome-ignore lint/suspicious/noExplicitAny:
const makeLoader = () => makeActivatableLoader({} as any);

describe.skipIf(!!process.env.CI)("activatable loader", () => {
  test("activate", async () => {
    const data = await makeLoader().load(
      "d29ya3RlbXBsYXRlOjgyN2RlNDE5LTQ0YmMtNGExMi1iOWFmLWI2NDFmYjU3NjQyOQ==",
    );
    expect(data).toMatchSnapshot();
  });

  test("deactivate", async () => {
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
