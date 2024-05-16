import { assertAuthenticated } from "@/auth";
import { sql } from "@/datasources/postgres";
import type { CustomerResolvers, Name } from "@/schema";

export const Customer: CustomerResolvers = {
  async name(parent, _, ctx) {
    assertAuthenticated(ctx);

    const name = await ctx.orm.name.load({
      id: parent.name_id as string,
      language_id: ctx.user.language_id,
    });

    if (!name) {
      const [fallback] = await sql<[Name]>`
        SELECT
            c.customeruuid AS id,
            l.systaguuid AS language_id,
            c.customername AS value
        FROM public.customer AS c
        INNER JOIN public.systag AS l
            ON c.customerlanguagetypeid = l.systagid
        WHERE customeruuid = ${parent.id};
      `;

      ctx.orm.name.prime(
        {
          id: fallback.id as string,
          language_id: fallback.language_id as string,
        },
        fallback,
      );

      console.log(fallback);
      return fallback;
    }

    return name;
  },
  async defaultLanguage(parent, _, ctx) {
    return ctx.orm.language.load(parent.default_language_id as string);
  },
};
