import { join, sql } from "@/datasources/postgres";
import type { Attachment, MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";

export const attach: NonNullable<MutationResolvers["attach"]> = async (
  _,
  args,
  ctx,
) => {
  const { type, id, suffix } = decodeGlobalId(args.entity);

  if (type !== "workinstance" && type !== "workresultinstance") {
    throw new GraphQLError("Entity cannot be attached to", {
      extensions: {
        code: "E_NOT_ATTACHABLE",
      },
    });
  }

  if (type === "workresultinstance" && !suffix?.length) {
    throw "invariant violated"; // invalid global id
  }

  // Note that we potentially lazy instantiate the workresultinstance in the
  // following sql. Despite workresultinstances being pre-created at the moment,
  // we still take the precaution in case we change our minds.
  const rows = await sql<Attachment[]>`
      WITH entity AS (
          SELECT
              workinstanceid AS _key,
              workinstancecustomerid AS _pkey
          FROM public.workinstance
          WHERE id = ${id}
      ),

      identity AS (
          SELECT workerinstanceid AS _key
          FROM public.workerinstance
          INNER JOIN entity ON workerinstancecustomerid = _pkey
          WHERE
              workerinstanceworkerid = (
                  SELECT workerid
                  FROM public.worker
                  WHERE workeridentityid = ${ctx.auth.userId}
              )
      ),
      ${
        suffix?.length
          ? sql`
      field_t AS (
          SELECT
              workresultid AS _key,
              workresultdefaultvalue AS default_value
          FROM public.workresult
          WHERE id = ${suffix?.at(0) ?? null}
      ),

      field_lazy AS (
          INSERT INTO public.workresultinstance (
              workresultinstancecustomerid,
              workresultinstanceworkinstanceid,
              workresultinstanceworkresultid,
              workresultinstancevalue
          )
          SELECT
              entity._pkey,
              entity._key,
              field_t._key,
              field_t.default_value
          FROM
              entity,
              field_t
          ON CONFLICT
              (workresultinstanceworkinstanceid, workresultinstanceworkresultid)
          DO NOTHING
          RETURNING workresultinstanceid AS _key
      ),

      field AS (
          SELECT _key
          FROM field_lazy
          UNION ALL
          SELECT workresultinstanceid AS _key
          FROM public.workresultinstance AS wri
          INNER JOIN entity
              ON wri.workresultinstanceworkinstanceid = entity._key
          INNER JOIN field_t
              ON wri.workresultinstanceworkresultid = field_t._key
          LIMIT 1
      )
          `
          : sql`
      field (_key) AS (
          VALUES (null::bigint)
      )
          `
      }
      INSERT INTO public.workpictureinstance (
          workpictureinstancecustomerid,
          workpictureinstanceworkinstanceid,
          workpictureinstanceworkresultinstanceid,
          workpictureinstancestoragelocation,
          workpictureinstancemodifiedby
      )
      SELECT
          entity._pkey,
          entity._key,
          field._key,
          inputs.url,
          identity._key
      FROM
          entity,
          identity,
          (VALUES ${join(
            args.attachments.map(a => sql`(${a.toString()})`),
            sql`,`,
          )}) AS inputs (url)
      LEFT JOIN field ON true
      RETURNING encode(('workpictureinstance:' || workpictureinstanceuuid)::bytea, 'base64') AS id
  `;

  if (!rows.length) {
    throw new GraphQLError(
      `Entity ${args.entity} (${type}:${id}:${suffix?.join(":")}) does not exist`,
      {
        extensions: {
          code: "NOT_FOUND",
        },
      },
    );
  }

  return rows.map(row => ({ cursor: row.id as string, node: row }));
};
