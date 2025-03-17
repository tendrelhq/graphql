import { setCurrentIdentity } from "@/auth";
import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { Task } from "@/schema/system/component/task";
import { assert, assertNonNull, normalizeBase64 } from "@/util";
import { GraphQLError } from "graphql";

export const setValue: NonNullable<MutationResolvers["setValue"]> = async (
  _,
  { entity, parent, input },
  ctx,
) => {
  const { type, id, suffix } = decodeGlobalId(entity);
  if (type !== "workresultinstance" && type !== "workresult") {
    throw new GraphQLError(`Field is not mutable: ${type}`, {
      extensions: {
        code: "E_INVALID_OPERATION",
      },
    });
  }

  const p = new Task({ id: parent });
  if (p._type !== "workinstance" && p._type !== "worktemplate") {
    throw new GraphQLError(
      `Type '${p._type}' is an invalid parent type for type '${type}'`,
      {
        extensions: {
          code: "TYPE_ERROR",
        },
      },
    );
  }

  const [value, valueType] = (() => {
    switch (true) {
      case "checkbox" in input:
        return [input.checkbox?.value ?? null, "Boolean"];
      case "boolean" in input:
        return [input.boolean?.value ?? null, "Boolean"];
      case "section" in input:
        return [input.section?.value ?? null, "String"];
      case "clicker" in input:
        return [input.clicker?.value ?? null, "Number"];
      case "duration" in input:
        return [input.duration?.value ?? null, "Duration"];
      case "multiline" in input:
        return [input.multiline?.value ?? null, "String"];
      case "number" in input:
        return [input.number?.value ?? null, "Number"];
      case "reference" in input:
        return [null, "Entity"];
      case "sentiment" in input:
        return [input.sentiment?.value ?? null, "Number"];
      case "string" in input:
        return [input.string?.value ?? null, "String"];
      case "temporal" in input:
        return [null, "Date"];
      default: {
        const _: never = input;
        throw "invariant violated";
      }
    }
  })();

  console.debug(`field: ${normalizeBase64(entity)}`);
  if (p._type === "worktemplate" && type === "workresult") {
    // Ugh. This is such a mess. We just need to get everything moved over and
    // all will be well :)
    const result = await sql`
        update public.workresult
        set workresultdefaultvalue = ${value}::text,
            workresultmodifieddate = now(),
            workresultmodifiedby = auth.current_identity(workresultcustomerid, ${ctx.auth.userId})
        where id = ${id} and workresultdefaultvalue is distinct from ${value}::text
    `;
    console.debug(`setValue: count: ${result.count}`);
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
  }

  // We should have a workinstance (parent) + workresultinstance (field) at this point. Gross :(
  assert(p._type === "workinstance" && type === "workresultinstance");

  const field = assertNonNull(suffix?.at(0), "invariant violated");
  const result = await sql.begin(async sql => {
    await setCurrentIdentity(sql, ctx);
    return await sql`
      select *
      from engine0.apply_field_edit(
          entity := ${p._id},
          field := ${field},
          field_v := ${value}::text,
          field_vt := ${valueType},
          on_error := 'raise'
      )
    `;
  });
  console.debug(`setValue: engine.apply_field_edit.count: ${result.count}`);

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
