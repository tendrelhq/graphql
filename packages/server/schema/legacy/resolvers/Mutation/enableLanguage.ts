import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";

export const enableLanguage: NonNullable<
  MutationResolvers["enableLanguage"]
> = async (_, { languageId, ...args }, ctx) => {
  const { id: customerId } = decodeGlobalId(args.orgId);

  const crl = await sql.begin(async sql => {
    const [row] = await sql`
      select t.id
      from
          public.customer as c,
          public.systag as s,
          i18n.add_language_to_customer(
              customer_id := c.customeruuid,
              language_code := s.systagtype,
              modified_by := auth.current_identity(
                  parent := c.customerid,
                  identity := ${ctx.auth.userId}
              )
          ) as t
      where c.customeruuid = ${customerId} and s.systaguuid = ${languageId}
    `;

    // FIXME: This is bad. This scales linearly with the count of
    // languagemasters.
    // Set a flag to trigger the translation service.
    await sql`
        UPDATE public.languagemaster
        SET languagemasterstatus = 'NEEDS_TRANSLATION'
        WHERE
            languagemastercustomerid = (
                SELECT customerid
                FROM public.customer
                WHERE customeruuid = ${customerId}
            );
    `;

    return row.id;
  });

  const row = await ctx.orm.crl.load(crl);

  return {
    cursor: row.id.toString(),
    node: row,
  };
};
