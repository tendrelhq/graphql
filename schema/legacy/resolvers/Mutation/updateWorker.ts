import { sql } from "@/datasources/postgres";
import type { Context, MutationResolvers, UpdateWorkerInput } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";

function shouldUpdate<T>(input?: T, existing?: T): input is T {
  return typeof input !== "undefined" && input !== existing;
}

export const updateWorker: NonNullable<
  MutationResolvers["updateWorker"]
> = async (_, { input }, ctx) => {
  const { id: workerId } = decodeGlobalId(input.id);

  // Check for duplicate scan codes because we don't enforce this in the
  // database yet.
  if (input.scanCode) {
    const check = await sql`
      SELECT 1
      FROM public.workerinstance
      WHERE
          workerinstanceuuid != ${workerId}
          AND workerinstancescanid = ${input.scanCode}
          AND workerinstancecustomerid = (
              SELECT workerinstancecustomerid
              FROM public.workerinstance
              WHERE workerinstanceuuid = ${workerId}
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
        id: workerId,
      },
      ctx,
    );
    return {
      cursor: node.id as string,
      node,
    };
  } catch (e) {
    if (e instanceof GraphQLError) {
      throw e;
    }

    throw new GraphQLError("Failed to update worker", {
      extensions: {
        code: "unknown",
      },
    });
  }
};

async function execute(input: UpdateWorkerInput, ctx: Context) {
  await sql.begin(async sql => {
    // Make sure it exists.
    const worker = await ctx.orm.worker.load(input.id);
    const { id: userId } = decodeGlobalId(worker.userId);

    // Update the user with any relevant changes.
    const user = await ctx.orm.user.byId.load(userId);
    const userUpdates = {
      workerfirstname: input.firstName,
      workerlastname: input.lastName,
      workerfullname: input.displayName,
      workerlanguageid: input.languageId,
    };
    const userColumns = [
      shouldUpdate(input.firstName, user.firstName) &&
        ("workerfirstname" as const),
      shouldUpdate(input.lastName, user.lastName) &&
        ("workerlastname" as const),
      shouldUpdate(input.displayName, user.displayName) &&
        ("workerfullname" as const),
    ].filter(e => e !== false);

    if (shouldUpdate(input.languageId, user.languageId)) {
      await sql`
        UPDATE public.worker
        SET
            workerlanguageid = (
                SELECT systagid
                FROM public.systag
                WHERE systaguuid = ${input.languageId}
            ),
            workermodifieddate = now()
        WHERE workeruuid = ${userId};
      `;
    }

    if (userColumns.length) {
      await sql`
        UPDATE public.worker
        SET
            ${sql(userUpdates, userColumns)},
            workermodifieddate = now()
        WHERE workeruuid = ${userId};
      `;

      ctx.orm.user.byId.clear(userId);
    }

    // Update the worker with any relevant changes.
    // Language first, because we're in flux with bigint vs uuid :/
    if (shouldUpdate(input.languageId, worker.languageId)) {
      await sql`
        UPDATE public.workerinstance
        SET
            workerinstancelanguageuuid = ${input.languageId},
            workerinstancelanguageid = (
                SELECT systagid
                FROM public.systag
                WHERE systaguuid = ${input.languageId}
            ),
            workerinstancemodifieddate = now()
        WHERE workerinstanceuuid = ${userId};
      `;
    }

    // Also role, for the same "in flux" reason :/
    if (shouldUpdate(input.roleId, worker.roleId)) {
      await sql`
        UPDATE public.workerinstance
        SET
            workerinstanceuserroleuuid = ${input.roleId},
            workerinstanceuserroleid = (
                SELECT systagid
                FROM public.systag
                WHERE systaguuid = ${input.roleId}
            ),
            workerinstancemodifieddate = now()
        WHERE workerinstanceuuid = ${userId};
      `;
    }

    const workerUpdates = {
      workerinstancescanid: input.scanCode,
    };
    const workerColumns = [
      shouldUpdate(input.scanCode, worker.scanCode) &&
        ("workerinstancescanid" as const),
    ].filter(e => e !== false);

    if (workerColumns.length) {
      await sql`
        UPDATE public.workerinstance
        SET
            ${sql(workerUpdates, workerColumns)},
            workerinstancemodifieddate = now()
        WHERE workerinstanceuuid = ${input.id}
      `;

      ctx.orm.worker.clear(input.id);
    }
  });

  return ctx.orm.worker.load(input.id);
}
