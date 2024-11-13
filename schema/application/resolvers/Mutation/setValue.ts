import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { Temporal } from "@js-temporal/polyfill";
import { GraphQLError } from "graphql";
import { match } from "ts-pattern";

export const setValue: NonNullable<MutationResolvers["setValue"]> = async (
  _,
  { entity, parent, input },
  _ctx,
) => {
  const { type, id, suffix } = decodeGlobalId(entity);

  if (type !== "workresult" && type !== "workresultinstance") {
    throw new GraphQLError(`Entity is not mutable: ${type}`, {
      extensions: {
        code: "E_INVALID_OPERATION",
      },
    });
  }

  // At this point this is merely a convenience to get at the parent from the
  // node. I can't remember if we are using this convenience in the client, but
  // if not then we can probably just remove it entirely.
  const { type: parentType } = decodeGlobalId(parent);
  if (parentType !== "workinstance" && parentType !== "worktemplate") {
    throw new GraphQLError(
      `Type '${parentType}' is an invalid parent type for type '${type}'`,
      {
        extensions: {
          code: "TYPE_ERROR",
        },
      },
    );
  }

  const value = (() => {
    switch (true) {
      case "checkbox" in input:
        return input.checkbox?.value?.toString() ?? null;
      case "boolean" in input:
        return input.boolean?.value?.toString() ?? null;
      case "section" in input:
        return input.section?.value?.toString() ?? null;
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
          return (
            Temporal.Instant
              //
              .fromEpochMilliseconds(Number(input.temporal.value.instant))
              .toString()
          );
        }

        return (
          Temporal.Instant
            //
            .fromEpochMilliseconds(
              Number(input.temporal.value.zdt.epochMilliseconds),
            )
            .toZonedDateTimeISO(input.temporal.value.zdt.timeZone)
            .toString({ calendarName: "never", timeZoneName: "never" })
        );
      }
      default: {
        const _: never = input;
        throw "invariant violated";
      }
    }
  })();

  const result = await match(type)
    .with(
      "workresult",
      () => sql`
        UPDATE public.workresult
        SET
            workresultdefaultvalue = ${value ?? null},
            workresultmodifieddate = now()
        WHERE
            id = ${id}
            AND workresultdefaultvalue IS DISTINCT FROM ${value ?? null}
      `,
    )
    .with("workresultinstance", () => {
      if (!suffix?.length) {
        console.warn(
          "Invalid global id for underlying type 'workresultinstance'. Expected it to be of the form `workresultinstance:<workinstanceid>:<workresultid>`, but no <workresultid> was found.",
        );
        throw "invariant violated";
      }
      return sql`
        INSERT INTO public.workresultinstance AS wri (
            workresultinstancecustomerid,
            workresultinstanceworkresultid,
            workresultinstanceworkinstanceid,
            workresultinstancevalue
        )
        (
          SELECT
              wr.workresultcustomerid,
              wr.workresultid,
              wi.workinstanceid,
              COALESCE(${value ?? null}::text, wr.workresultdefaultvalue)
          FROM
              public.workinstance AS wi,
              public.workresult AS wr
          WHERE
              wi.id = ${id}
              AND wr.id = ${suffix[0]}
        )
        ON CONFLICT (workresultinstanceworkresultid, workresultinstanceworkinstanceid)
        DO UPDATE
            SET
                workresultinstancevalue = EXCLUDED.workresultinstancevalue,
                workresultinstancemodifieddate = now()
            WHERE
                wri.workresultinstancevalue IS DISTINCT FROM EXCLUDED.workresultinstancevalue
      `;
    })
    .exhaustive();

  // Note that this is a no-op if the values are identical.

  console.log(
    `Applied ${result.count} update(s) to Entity ${entity} (${type}:${id}${suffix ? `:${suffix.join(":")}` : ""})`,
  );

  return {
    delta: result.count,
    node: {
      __typename: "ChecklistResult",
      id: entity,
      // biome-ignore lint/suspicious/noExplicitAny:
    } as any,
    // This is what I mean by "convenience":
    parent: {
      __typename: "Checklist",
      id: parent,
      // biome-ignore lint/suspicious/noExplicitAny:
    } as any,
  };
};
