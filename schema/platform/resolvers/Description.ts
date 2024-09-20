import { sql } from "@/datasources/postgres";
import { EntityNotFound } from "@/errors";
import type { DescriptionResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { match } from "ts-pattern";

export const Description: DescriptionResolvers = {
  async description(parent, _, ctx) {
    const { type, id } = decodeGlobalId(parent.id);
    // TODO: This doesn't quite feel right...
    // All we're doing here is figuring out which languagemasterid to use :/
    const [row] = await match(type)
      .with(
        "workinstance",
        () => sql<[{ id: string }]>`
            SELECT encode(('description:' || m.languagemasteruuid)::bytea, 'base64') AS id
            FROM public.workinstance AS wi
            INNER JOIN public.worktemplate AS wt
                ON wi.workinstanceworktemplateid = wt.worktemplateid
            INNER JOIN public.languagemaster AS m
                ON wt.worktemplatedescriptionid = m.languagemasterid
            WHERE wi.id = ${id}
        `,
      )
      .with(
        "worktemplate",
        () => sql<[{ id: string }]>`
            SELECT encode(('description:' || m.languagemasteruuid)::bytea, 'base64') AS id
            FROM public.worktemplate AS wt
            INNER JOIN public.languagemaster AS m
                ON wt.worktemplatedescriptionid = m.languagemasterid
            WHERE wt.id = ${id}
        `,
      )
      .otherwise(() => Promise.reject(new EntityNotFound("description")));

    // This is where we actually grab the rest of the fields.
    return ctx.orm.dynamicString.load(row.id);
  },
  async value(parent, _, ctx) {
    const { type, id } = decodeGlobalId(parent.id);
    // TODO: This doesn't quite feel right...
    // All we're doing here is figuring out which languagemasterid to use :/
    const [row] = await match(type)
      .with(
        "workinstance",
        () => sql<[{ id: string }]>`
            SELECT encode(('description:' || m.languagemasteruuid)::bytea, 'base64') AS id
            FROM public.workinstance AS wi
            INNER JOIN public.worktemplate AS wt
                ON wi.workinstanceworktemplateid = wt.worktemplateid
            INNER JOIN public.languagemaster AS m
                ON wt.worktemplatedescriptionid = m.languagemasterid
            WHERE wi.id = ${id}
        `,
      )
      .with(
        "worktemplate",
        () => sql<[{ id: string }]>`
            SELECT encode(('description:' || m.languagemasteruuid)::bytea, 'base64') AS id
            FROM public.worktemplate AS wt
            INNER JOIN public.languagemaster AS m
                ON wt.worktemplatedescriptionid = m.languagemasterid
            WHERE wt.id = ${id}
        `,
      )
      .otherwise(() => Promise.reject(new EntityNotFound("description")));

    // This is where we actually grab the rest of the fields.
    return ctx.orm.dynamicString.load(row.id);
  },
};
