import { sql } from "@/datasources/postgres";
import type { Context, CreateWorkerInput, MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import { GraphQLError } from "graphql";

export const createWorker: NonNullable<
  MutationResolvers["createWorker"]
> = async (_, { input }, ctx) => {
  const { id: orgId } = decodeGlobalId(input.orgId);
  const { id: userId } = input.userId
    ? decodeGlobalId(input.userId)
    : { id: undefined };

  // Check for duplicate scan codes because we don't enforce this in the
  // database yet.
  if (input.scanCode) {
    const check = await sql`
      SELECT 1
      FROM public.workerinstance
      WHERE
          workerinstancescanid = ${input.scanCode}
          AND workerinstancecustomerid = (
              SELECT customerid
              FROM public.customer
              WHERE customeruuid = ${orgId}
          );
    `;

    if (check.length) {
      throw new GraphQLError("unique_constraint_violation", {
        extensions: {
          code: "duplicate_scan_code",
        },
        path: ["input", "scanCode"],
      });
    }
  }

  try {
    const node = await execute(
      {
        ...input,
        orgId,
        userId,
      },
      ctx,
    );

    return {
      cursor: node.id as string,
      node,
    };
  } catch (e) {
    if (
      e instanceof Error &&
      e.message.includes("duplicate key value violates unique constraint")
    ) {
      throw new GraphQLError("unique_constraint_violation", {
        extensions: {
          code: "worker_already_exists",
        },
      });
    }

    throw new GraphQLError("Failed to created worker", {
      extensions: {
        code: "unknown",
      },
    });
  }
};

async function execute(input: CreateWorkerInput, ctx: Context) {
  // biome-ignore lint/complexity/noBannedTypes:
  const [row] = await sql<[WithKey<{}>?]>`
      WITH i(userid, customerid, customeruuid, languageid, languageuuid, startdate, enddate, roleid, roleuuid, scancode) AS (
          VALUES (
              ${input.userId ?? null}::text,
              (
                  SELECT customerid
                  FROM public.customer
                  WHERE customeruuid = ${input.orgId}
              ),
              ${input.orgId}::text,
              (
                  SELECT systagid
                  FROM public.systag
                  WHERE systaguuid = ${input.languageId}
              ),
              ${input.languageId}::text,
              ${new Date()}::timestamptz,
              ${input.active ? null : new Date()}::timestamptz,
              (
                  SELECT systagid
                  FROM public.systag
                  WHERE systaguuid = ${input.roleId}
              ),
              ${input.roleId}::text,
              ${input.scanCode ?? null}::text
          )
      ),
      u AS (
          INSERT INTO public.worker (
              workeruuid,
              workerfirstname,
              workerlastname,
              workerfullname,
              workerlanguageid,
              workerstartdate,
              workerenddate
          ) VALUES (
              coalesce(${input.userId ?? null}, gen_random_uuid()::text),
              ${input.firstName},
              ${input.lastName},
              ${input.displayName ?? `${input.firstName} ${input.lastName}`},
              (
                  SELECT systagid
                  FROM public.systag
                  WHERE systaguuid = ${input.languageId}
              ),
              ${new Date()},
              ${input.active === false ? new Date() : null}
          )
          ON CONFLICT DO NOTHING
          RETURNING workerid, workeruuid
      )

      INSERT INTO public.workerinstance (
          workerinstanceworkerid,
          workerinstanceworkeruuid,
          workerinstancecustomerid,
          workerinstancecustomeruuid,
          workerinstancelanguageid,
          workerinstancelanguageuuid,
          workerinstancestartdate,
          workerinstanceenddate,
          workerinstanceuserroleid,
          workerinstanceuserroleuuid,
          workerinstancescanid
      )
      SELECT
          u.workerid,
          u.workeruuid,
          i.customerid,
          i.customeruuid,
          i.languageid,
          i.languageuuid,
          i.startdate,
          i.enddate,
          i.roleid,
          i.roleuuid,
          i.scancode
      FROM u, i
      UNION ALL
      SELECT
          w.workerid,
          w.workeruuid,
          i.customerid,
          i.customeruuid,
          i.languageid,
          i.languageuuid,
          i.startdate,
          i.enddate,
          i.roleid,
          i.roleuuid,
          i.scancode
      FROM public.worker AS w, i
      WHERE w.workeruuid = i.userid
      RETURNING workerinstanceuuid AS _key;
  `;

  // Some comments on the above statement.
  // Because we are using a data-modifying CTE, this entire statement is atomic.
  // We further exploit data-modifying CTEs by way of UNION ALL - the inserted
  // rows from the data-modifying CTE are not yet visible in the underlying
  // table (all parts of the same SQL statement see the same snapshots of the
  // underlying table), and so the UNION ALL will always either see
  // (1) nothing - which means the INSERT INTO public.worker will take.
  // (2) something - in which case the ON CONFLICT DO NOTHING will hit (and
  //     therefore no rows will be inserted as part of the data-modifying CTE)

  if (!row) {
    throw "internal server error";
  }

  return ctx.orm.worker.load(row._key);
}
