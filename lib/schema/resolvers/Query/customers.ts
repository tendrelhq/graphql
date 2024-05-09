import sql from "@/datasources/postgres";
import type {
  Customer,
  QueryResolvers,
} from "./../../__generated__/types.generated";

export const customers: NonNullable<QueryResolvers['customers']> = async (
  _,
  __,
  ___,
) => {
  return await sql<Customer[]>`
    SELECT
        c.customeruuid AS id,
        c.customernamelanguagemasterid AS name_id,
        l.systaguuid AS default_language_id
    FROM public.customer AS c
    INNER JOIN public.systag AS l
        ON c.customerlanguagetypeid = l.systagid;
  `;
};
