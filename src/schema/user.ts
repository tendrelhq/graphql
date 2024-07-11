import { sql } from "@/datasources/postgres";
import {
  type ResolveCursorConnectionArgs,
  decodeGlobalID,
  encodeGlobalID,
  resolveCursorConnection,
} from "@pothos/plugin-relay";
import DataLoader from "dataloader";
import { builder } from "../builder";
import type { Context, Node } from "../types";
import {
  type Organization,
  node as organizationNode,
  resolveConnectionAfter,
  resolveConnectionBefore,
} from "./organization";

export interface User extends Node {
  createdAt: string;
  updatedAt: string;
  //
  name: string;
}

export const ref = builder.objectRef<User>("User");

export const loader = (_: Context) => {
  return new DataLoader<string, User>(async keys => {
    const rows = await sql<User[]>`
      SELECT
          workeruuid AS id,
          workercreateddate AS "createdAt",
          workermodifieddate AS "updatedAt",
          workerfullname AS name
      FROM public.worker
      WHERE workeruuid IN ${sql(keys)};
    `;
    return rows;
  });
};
export type Loader = ReturnType<typeof loader>;

export const node = builder.node(ref, {
  id: {
    resolve: parent => parent.id,
  },
  //
  fields: t => ({
    createdAt: t.exposeString("createdAt"),
    updatedAt: t.exposeString("updatedAt"),
    name: t.exposeString("name"),
    //
    organizations: t.connection({
      type: organizationNode,
      resolve: (parent, args) =>
        resolveCursorConnection(
          {
            args,
            toCursor: ({ id }) => encodeGlobalID("Organization", id),
          },
          async ({
            before,
            after,
            limit,
            inverted,
          }: ResolveCursorConnectionArgs) => {
            const rows = await sql<Organization[]>`
              SELECT
                  customeruuid AS id,
                  customercreateddate AS "createdAt",
                  customermodifieddate AS "updatdAt",
                  languagemasteruuid AS "nameId"
              FROM public.customer
              INNER JOIN public.workerinstance
                  ON customerid = workerinstancecustomerid
              INNER JOIN public.languagemaster
                  ON customernamelanguagemasterid = languagemasterid
              WHERE
                  workerinstanceworkerid = (
                      SELECT workerid
                      FROM public.worker
                      WHERE workeruuid = ${parent.id}
                  )
                  ${after ? sql`AND ${resolveConnectionAfter(after)}` : sql``}
                  ${before ? sql`AND ${resolveConnectionBefore(before)}` : sql``}
              ORDER BY customerid ${inverted ? sql`DESC` : sql`ASC`}
              LIMIT ${limit};
            `;

            return rows;
          },
        ),
    }),
  }),
  //
  loadWithoutCache: (id, ctx) => ctx.loaders.user.load(id),
});

builder.queryFields(t => ({
  user: t.field({
    type: node,
    nullable: false,
    resolve: (_, __, ctx, ___) => ctx.loaders.user.load(ctx.auth.userId),
  }),
}));
