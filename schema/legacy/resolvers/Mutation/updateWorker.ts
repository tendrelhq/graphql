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
      workerlanguageid: sql`(
        SELECT systagid
        FROM public.systag
        WHERE systaguuid = ${input.languageId ?? ""}
      )`,
    };
    const userColumns = [
      shouldUpdate(input.firstName, user.firstName) &&
        ("workerfirstname" as const),
      shouldUpdate(input.lastName, user.lastName) &&
        ("workerlastname" as const),
      shouldUpdate(input.displayName, user.displayName) &&
        ("workerfullname" as const),
      shouldUpdate(input.languageId, user.languageId) &&
        ("workerlanguageid" as const),
    ].filter(e => e !== false);

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

    const workerUpdates = {
      workerinstancescanid: input.scanCode,
      workerinstancelanguageid: sql`(
          SELECT systagid
          FROM public.systag
          WHERE systaguuid = ${input.languageId ?? ""}
      )`,
      workerinstancelanguageuuid: input.languageId,
      workerinstanceuserroleid: sql`(
          SELECT systagid
          FROM public.systag
          WHERE systaguuid = ${input.roleId ?? ""}
      )`,
      workerinstanceuserroleuuid: input.roleId,
    };
    const workerColumns = [
      shouldUpdate(input.scanCode, worker.scanCode) &&
        ("workerinstancescanid" as const),
      shouldUpdate(input.languageId, worker.languageId) &&
        ("workerinstancelanguageid" as const),
      shouldUpdate(input.languageId, worker.languageId) &&
        ("workerinstancelanguageuuid" as const),
      shouldUpdate(input.roleId, worker.roleId) &&
        ("workerinstanceuserroleid" as const),
      shouldUpdate(input.roleId, worker.roleId) &&
        ("workerinstanceuserroleuuid" as const),
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
