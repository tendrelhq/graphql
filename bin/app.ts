import "dotenv/config";

import { yoga } from "../src/server";

const server = Bun.serve({
  port: Number(process.env.PORT ?? 4000),
  fetch: yoga,
});

console.log(`Server listening at ${server.url}`);
