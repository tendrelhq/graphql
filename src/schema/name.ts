import { sql } from "@/datasources/postgres";
import DataLoader from "dataloader";
import { builder } from "../builder";
import type { Context, Node } from "../types";

export interface Name extends Node {
  createdAt: string;
  updatedAt: string;
  //
  value: string;
  languageId: string;
}

export const ref = builder.objectRef<Name>("Name");

export const loader = (_: Context) => {
  return new DataLoader<string, Name>(async keys => {
    const rows = await sql<Name[]>`
      SELECT
          languagemasteruuid AS id,
          languagemastercreateddate AS "createdAt",
          languagemastermodifieddate AS "updatedAt",
          languagemastersource AS value,
          systaguuid AS "languageId"
      FROM public.languagemaster
      INNER JOIN public.systag
          ON languagemastersourcelanguagetypeid = systagid
      WHERE languagemasteruuid IN ${sql(keys)};
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
    value: t.exposeString("value"),
    languageId: t.exposeString("languageId"),
  }),
  //
  loadWithoutCache: (id, ctx) => ctx.loaders.name.load(id),
});
