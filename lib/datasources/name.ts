import { NotFoundError } from "@/errors";
import type { Context, Name } from "@/schema";
import Dataloader from "dataloader";
import { sql } from "./postgres";

type Key = { id: string; language_id: string };

export default (ctx: Omit<Context, "orm">) =>
  new Dataloader<Key, Name, string>(
    async keys => {
      const rows = await sql<(Name & { key: number })[]>`
        SELECT
            m.languagemasterid AS key,
            COALESCE(t.languagetranslationid, m.languagemasterid) AS id,
            COALESCE(tl.systaguuid, ml.systaguuid) AS language_id,
            COALESCE(t.languagetranslationvalue, m.languagemastersource) AS value
        FROM public.languagemaster AS m
        INNER JOIN public.systag AS ml
            ON m.languagemastersourcelanguagetypeid = ml.systagid
        LEFT JOIN public.languagetranslations AS t
            ON
                m.languagemasterid = t.languagetranslationmasterid
                AND t.languagetranslationtypeid = (
                    SELECT systagid
                    FROM public.systag
                    WHERE systaguuid = ${ctx.user.language_id}
                )
        LEFT JOIN public.systag AS tl
            ON t.languagetranslationtypeid = tl.systagid
        WHERE m.languagemasterid IN ${sql(keys.map(k => k.id))};
      `;

      const byId = rows.reduce(
        (acc, row) => acc.set(`${row.key}:${row.language_id}`, row),
        new Map<string, Name>(),
      );

      return keys.map(
        key =>
          byId.get(`${key.id}:${key.language_id}`) ??
          new NotFoundError(`${key.id}${key.language_id}`, "name"),
      );
    },
    {
      cacheKeyFn: key => `${key.id}:${key.language_id}`,
    },
  );
