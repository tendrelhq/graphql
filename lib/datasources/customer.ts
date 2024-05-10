import type { Context, Customer } from "@/schema";
import Dataloader from "dataloader";
import { GraphQLError } from "graphql";
import { sql } from "./postgres";

export default (ctx: Omit<Context, "orm">) =>
  new Dataloader<string, Customer>(async keys => {
    const { authScope } = ctx;

    if (!authScope)
      throw new GraphQLError("Unauthenticated", {
        extensions: {
          code: 401,
        },
      });

    if (keys.length) {
      return await sql<Customer[]>`
        SELECT
            c.customeruuid AS id,
            c.customernamelanguagemasterid AS name_id,
            l.systaguuid AS default_language_id
        FROM public.customer AS c
        INNER JOIN public.systag AS l
            ON c.customerlanguagetypeid = l.systagid
        WHERE c.customeruuid IN ${sql(keys)};
      `;
    }

    return await sql<Customer[]>`
      SELECT
          c.customeruuid AS id,
          c.customernamelanguagemasterid AS name_id,
          l.systaguuid AS default_language_id
      FROM public.workerinstance AS w
      INNER JOIN public.customer AS c
          ON w.workerinstancecustomerid = c.customerid
      INNER JOIN public.systag AS l
          ON c.customerlanguagetypeid = l.systagid
      WHERE w.workerinstanceworkerid = ${authScope};
    `;
  });
