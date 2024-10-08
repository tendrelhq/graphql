import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { Temporal } from "@js-temporal/polyfill";
import { GraphQLError } from "graphql";

export const setValue: NonNullable<MutationResolvers["setValue"]> = async (
  _,
  { entity, parent, input },
  _ctx,
) => {
  const { type: parentType, id: parentId } = decodeGlobalId(parent);
  const { type, id } = decodeGlobalId(entity);

  if (parentType !== "workinstance") {
    throw new GraphQLError("Invalid input to ECS operation: AST node", {
      extensions: {
        code: "E_INVALID_OPERAND",
      },
    });
  }

  const value = (() => {
    switch (true) {
      case "checkbox" in input:
        return input.checkbox?.value === true
          ? "true"
          : input.checkbox?.value === false
            ? "false"
            : null;
      case "clicker" in input:
        return input.clicker?.value?.toString();
      case "duration" in input:
        return input.duration?.value;
      case "multiline" in input:
        return input.multiline?.value;
      case "number" in input:
        return input.number?.value?.toString();
      case "reference" in input:
        // FIXME: This isn't right. I'm pretty sure these are global ids.
        return input.reference?.value?.toString();
      case "sentiment" in input:
        return input.sentiment?.value?.toString();
      case "string" in input:
        return input.string?.value;
      case "temporal" in input: {
        if (!input.temporal.value) return null;

        if ("instant" in input.temporal.value) {
          const t = Temporal.Instant.fromEpochMilliseconds(
            Number(input.temporal.value.instant),
          );
          return t.toString();
        }

        const t = Temporal.Instant.fromEpochMilliseconds(
          Number(input.temporal.value.zdt.epochMilliseconds),
        );
        return t
          .toZonedDateTimeISO(input.temporal.value.zdt.timeZone)
          .toString({ calendarName: "never", timeZoneName: "never" });
      }
      default: {
        const _: never = input;
        throw "invariant violated";
      }
    }
  })();

  if (type === "workresultinstance") {
    const result = await sql`
        WITH inputs (value) AS (
            VALUES (
                ${value ?? null}::text
            )
        )

        UPDATE public.workresultinstance AS wri
        SET
            workresultinstancevalue = inputs.value,
            workresultinstancemodifieddate = now()
        FROM inputs
        WHERE
            workresultinstanceuuid = ${id}
            AND (
                (
                    workresultinstancevalue IS null
                    AND
                    inputs.value IS NOT null
                )
                OR
                (
                    workresultinstancevalue IS NOT null
                    AND
                    inputs.value IS null
                )
                OR
                (
                    workresultinstancevalue != inputs.value
                )
            )
    `;

    console.log(
      `Applied ${result.count} update(s) to Entity ${entity} (${type}:${id})`,
    );

    return {
      delta: result.count,
      node: {
        __typename: "ChecklistResult",
        id: entity,
        // biome-ignore lint/suspicious/noExplicitAny:
      } as any,
      parent: {
        __typename: "Checklist",
        id: parent,
        // biome-ignore lint/suspicious/noExplicitAny:
      } as any,
    };
  }

  // Otherwise it's a workresult, in which case we need to create a new
  // workresultinstance.
  const [row] = await sql<[{ id: string }]>`
      INSERT INTO public.workresultinstance AS wri (
          workresultinstancecustomerid,
          workresultinstanceworkresultid,
          workresultinstanceworkinstanceid,
          workresultinstancevalue
      )

      SELECT
          wr.workresultcustomerid,
          wr.workresultid,
          wi.workinstanceid,
          ${value ?? null}::text
      FROM public.workresult AS wr, public.workinstance AS wi
      WHERE
          wr.id = ${id}
          AND
          wi.id = ${parentId}
      ON CONFLICT (workresultinstanceworkresultid, workresultinstanceworkinstanceid)
      DO UPDATE
          SET
              workresultinstancevalue = excluded.workresultinstancevalue,
              workresultinstancemodifieddate = excluded.workresultinstancemodifieddate
      RETURNING encode(('workresultinstance:' || wri.workresultinstanceuuid)::bytea, 'base64') AS id
  `;

  console.log(
    `Lazy instantiation of AST node ${entity} resulted in the creation of ${1} entity`,
  );

  return {
    delta: 1,
    node: {
      __typename: "ChecklistResult",
      id: row.id,
      // biome-ignore lint/suspicious/noExplicitAny:
    } as any,
    parent: {
      __typename: "Checklist",
      id: parent,
      // biome-ignore lint/suspicious/noExplicitAny:
    } as any,
  };
};
