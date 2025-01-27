import { expect, test } from "bun:test";
import { splitmix32 } from "./splitmix32";

test("splitmix32", () => {
  const seed = 1337 ^ 0xdeadbeef;
  const prng = splitmix32(seed);
  for (let i = 0; i < 15; i++) prng(); // warm it up
  expect([
    prng(),
    prng(),
    prng(),
    prng(),
    prng(),
    prng(),
    prng(),
    prng(),
    prng(),
    prng(),
    prng(),
  ]).toMatchSnapshot();
});
