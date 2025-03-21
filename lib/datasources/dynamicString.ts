import { decodeGlobalId } from "@/schema/system";
import type { DynamicString } from "@/schema/system/i18n";
import { assert, normalizeBase64 } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import { GraphQLError } from "graphql/error";
import type { ID } from "grats";
import { sql, unionAll } from "./postgres";

type SourceLocations = {
  // These are legacy. They map directly to languagemasters.
  languagemaster: string[];
  workdescription: string[];
};

export function makeDynamicStringLoader(req: Request) {
  return new DataLoader<ID, DynamicString>(async keys => {
    const sources: SourceLocations = {
      // DisplayNames are really just languagemasters, and so map directly to
      // the languagemaster table.
      languagemaster: [],
      workdescription: [],
    };

    for (const key of keys) {
      const { type, id } = decodeGlobalId(key);
      switch (type) {
        case "name": {
          sources.languagemaster.push(id);
          break;
        }
        case "workdescription": {
          sources.workdescription.push(id);
          break;
        }
        default: {
          console.warn(`Unknown underlying type for DynamicString: ${type}`);
          break;
        }
      }
    }

    const queries = [];
    if (sources.languagemaster.length) {
      queries.push(
        sql`
          select
              encode(('name:' || languagemasteruuid)::bytea, 'base64') as key,
              coalesce(
                  encode(('languagetranslation:' || languagetranslationuuid)::bytea, 'base64'),
                  encode(('languagemaster:' || languagemasteruuid)::bytea, 'base64')
              ) as id,
              coalesce(t.systagtype, m.systagtype) as locale,
              coalesce(languagetranslationvalue, languagemastersource) as value
          from public.languagemaster
          inner join public.systag as m
              on languagemastersourcelanguagetypeid = systagid
          left join public.languagetranslations
              on languagemasterid = languagetranslationmasterid
              and languagetranslationtypeid = (
                  select systagid
                  from public.systag
                  where systagparentid = 2 and systagtype = ${req.i18n.language}
              )
          left join public.systag as t on languagetranslationtypeid = t.systagid
          where languagemasteruuid in ${sql(sources.languagemaster)}
        `,
      );
    }
    if (sources.workdescription.length) {
      queries.push(
        sql`
          select
              encode(('workdescription:' || wd.id)::bytea, 'base64') as key,
              coalesce(
                  encode(('languagetranslation:' || lt.languagetranslationuuid)::bytea, 'base64'),
                  encode(('languagemaster:' || lm.languagemasteruuid)::bytea, 'base64')
              ) as id,
              coalesce(ltt.systagtype, lmt.systagtype) as locale,
              coalesce(lt.languagetranslationvalue, lm.languagemastersource) as value
          from public.workdescription as wd
          inner join public.languagemaster as lm
              on wd.workdescriptionlanguagemasterid = lm.languagemasterid
          inner join public.systag as lmt
              on lm.languagemastersourcelanguagetypeid = lmt.systagid
          left join public.languagetranslations as lt
              on lm.languagemasterid = lt.languagetranslationmasterid
              and lt.languagetranslationtypeid = (
                  select systagid
                  from public.systag
                  where systagparentid = 2 and systagtype = ${req.i18n.language}
              )
          left join public.systag as ltt on lt.languagetranslationtypeid = ltt.systagid
          where wd.id in ${sql(sources.workdescription)}
        `,
      );
    }

    assert(queries.length > 0);

    type Row = { key: string; id: string; locale: string; value: string };
    const rows = await sql<Row[]>`${unionAll(queries)}`;
    return keys.map(key => {
      return (
        rows.find(row => normalizeBase64(row.key) === normalizeBase64(key)) ??
        new GraphQLError(`No DynamicString for key: ${key}`, {
          extensions: {
            code: "NOT_FOUND",
          },
        })
      );
    });
  });
}
