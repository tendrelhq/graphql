import "dotenv/config";

import { schema } from "@/schema/schema";
import type { Serve } from "bun";
import { createHandler } from "graphql-http/lib/use/fetch";
import { ruruHTML } from "ruru/server";

const handler = createHandler({
  schema,
  context: async () => {
    return {
      auth: "hello" as const,
    };
  },
});

export default {
  port: 4000,
  fetch(req) {
    const [path] = req.url.split("?");
    if (path.endsWith("/graphql")) {
      return handler(req);
    }
    return new Response(
      ruruHTML({
        endpoint: "/graphql",
      }),
      {
        headers: {
          "Content-Type": "text/html",
        },
      },
    );
  },
} satisfies Serve;
