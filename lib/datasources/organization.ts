import { assertAuthenticated } from "@/auth";
import type { Context, Customer } from "@/schema";
import Dataloader from "dataloader";
import { sql } from "./postgres";

export default (ctx: Omit<Context, "orm">) =>
  new Dataloader<string, Customer>(async keys => {
    assertAuthenticated(ctx);

    const rows = await sql<Customer[]>`
      SELECT
          c.customeruuid AS id,
          c.customernamelanguagemasterid AS name_id,
          l.systaguuid AS default_language_id
      FROM public.customer AS c
      INNER JOIN public.systag AS l
          ON c.customerlanguagetypeid = l.systagid
      WHERE c.customeruuid IN ${sql(keys)};
    `;

    const byId = rows.reduce(
      (acc, row) => acc.set(row.id as string, row),
      new Map<string, Customer>(),
    );

    return keys.map(key => byId.get(key) ?? new Error(`${key} does not exist`));
  });
