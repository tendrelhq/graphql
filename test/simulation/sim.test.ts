import { expect, test } from "bun:test";
import { Simulation } from "./simulation";

test("default; max_iterations=2, peer_count=10", async () => {
  const sim = new Simulation({
    max_iterations: 2,
    peer_count: 10,
  });

  await sim.run();
});
