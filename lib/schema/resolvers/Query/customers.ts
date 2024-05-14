import { sql } from "@/datasources/postgres";
import type { Customer } from "@/schema";
import type { QueryResolver } from "@/schema/resolvers";
import { GraphQLError } from "graphql";

export const customers: QueryResolver<"customers"> = async (_, __, ctx) => {
  const { authScope } = ctx;

  if (!authScope)
    throw new GraphQLError("Unauthenticated", {
      extensions: {
        code: 401,
      },
    });

  return await sql<Customer[]>`
    SELECT
        c.customeruuid AS id,
        c.customernamelanguagemasterid AS name_id,
        l.systaguuid AS default_language_id
    FROM public.workerinstance AS w
    INNER JOIN public.worker AS u
        ON w.workerinstanceworkerid = u.workerid
    INNER JOIN public.customer AS c
        ON w.workerinstancecustomerid = c.customerid
    INNER JOIN public.systag AS l
        ON c.customerlanguagetypeid = l.systagid
    WHERE u.workeruuid = ${authScope};
  `;
};
