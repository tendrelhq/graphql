import { sql } from "@/datasources/postgres";
import type { QueryResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";

export const assignable: NonNullable<QueryResolvers["assignable"]> = async (
  _,
  { entity },
) => {
  const { type, id } = decodeGlobalId(entity);
  console.log("entity", { type, id });

  switch (type) {
    case "workinstance": {
      const rows = await sql<{ id: string }[]>`
          SELECT
              'Worker' AS "__typename",
              encode(('worker:' || workerinstanceuuid)::bytea, 'base64') AS id
          FROM public.workerinstance
          INNER JOIN public.worker
              ON workerinstanceworkerid = workerid
          WHERE
              workerinstancecustomerid IN (
                  SELECT workinstancecustomerid
                  FROM public.workinstance
                  WHERE id = ${id}
              )
          ORDER BY workerfullname, workerid
      `;

      return {
        edges: rows.map(node => ({ cursor: node.id, node })),
        pageInfo: {
          hasNextPage: false,
          hasPreviousPage: false,
        },
        totalCount: rows.length,
      };
    }
  }

  throw new GraphQLError("Entity cannot be assigned", {
    extensions: {
      code: "E_NOT_ASSIGNABLE",
    },
  });
};
