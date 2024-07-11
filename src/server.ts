import { sql } from "@/datasources/postgres";
import {
  useEngine,
  useExtendContext,
  useLogger,
  useSchema,
} from "@envelop/core";
import { useOpenTelemetry } from "@envelop/opentelemetry";
import { useParserCache } from "@envelop/parser-cache";
import { useValidationCache } from "@envelop/validation-cache";
import * as graphql from "graphql";
import { createYoga } from "graphql-yoga";
import { provider } from "./instrumentation";
import { schema } from "./schema";
import { loader as nameLoader } from "./schema/name";
import { loader as organizationLoader } from "./schema/organization";
import { loader as userLoader } from "./schema/user";
import type { Context } from "./types";

async function getCurrentUser() {
  const [row] = await sql<[{ id: string }]>`
    SELECT workeruuid AS id
    FROM public.worker
    WHERE workerfullname = 'Will Ruggiano';
  `;

  return row.id;
}

export const yoga = createYoga({
  async context({ request }) {
    return {
      auth: {
        userId: await getCurrentUser(),
      },
    } satisfies Omit<Context, "loaders">;
  },
  plugins: [
    useEngine(graphql),
    useSchema(schema),
    useExtendContext(context => ({
      ...context,
      loaders: {
        name: nameLoader(context),
        organization: organizationLoader(context),
        user: userLoader(context),
      },
    })),
    // useLogger(),
    useParserCache(),
    useValidationCache(),
    useOpenTelemetry(
      {
        resolvers: true,
        result: true,
        variables: true,
      },
      provider,
    ),
  ],
});
