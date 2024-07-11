import { sql } from "@/datasources/postgres";
import {
  decodeGlobalID,
  encodeGlobalID,
  resolveCursorConnection,
} from "@pothos/plugin-relay";
import DataLoader from "dataloader";
import { builder } from "../builder";
import type { Context, Node } from "../types";
import { node as nameNode } from "./name";

export interface Organization extends Node {
  createdAt: string;
  updatedAt: string;
  //
  nameId: string;
}

export const ref = builder.objectRef<Organization>("Organization");

export const loader = (_: Context) => {
  return new DataLoader<string, Organization>(async keys => {
    const rows = await sql<Organization[]>`
      SELECT
          customeruuid AS id,
          customercreateddate AS "createdAt",
          customermodifieddate AS "updatdAt",
          languagemasteruuid AS "nameId"
      FROM public.customer
      INNER JOIN public.languagemaster
          ON customernamelanguagemasterid = languagemasterid
      WHERE customeruuid IN ${sql(keys)};
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
    //
    nameId: t.exposeString("nameId"),
    //
    name: t.field({
      type: nameNode,
      resolve: (parent, _, ctx) => {
        return ctx.loaders.name.load(parent.nameId);
      },
    }),
  }),
  //
  loadWithoutCache: (id, ctx) => ctx.loaders.organization.load(id),
});

export function resolveConnectionAfter(globalId: string) {
  return sql`
    customerid > (
        SELECT customerid
        FROM public.customer
        WHERE customeruuid = ${decodeGlobalID(globalId).id}
    )
  `;
}

export function resolveConnectionBefore(globalId: string) {
  return sql`
    customerid < (
        SELECT customerid
        FROM public.customer
        WHERE customeruuid = ${decodeGlobalID(globalId).id}
    )
  `;
}
