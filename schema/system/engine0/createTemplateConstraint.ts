import { type TxSql, sql } from "@/datasources/postgres";
import { type Diagnostic, DiagnosticKind } from "@/schema/result";
import type { Mutation } from "@/schema/root";
import {
  Task,
  type ConstructorArgs as TaskConstructorArgs,
  applyFieldEdits_,
} from "@/schema/system/component/task";
import type { Edge } from "@/schema/system/pagination";
import type { Context } from "@/schema/types";
import { assert, map } from "@/util";
import type { ID } from "grats";
import { match } from "ts-pattern";
import { decodeGlobalId } from "..";
import type { FieldInput } from "../component";

/**
 * Template constraints allow you to constrain the *type* of thing that can go
 * into a field. Currently, this is only supported for Locations (and by that I
 * mean "primary locations") as a means of "enabling" a template for the given
 * location.
 *
 * @gqlType
 */
export class TemplateConstraint {
  constructor(
    /** @gqlField */
    public readonly id: ID,
    private ctx: Context,
  ) {}
}

/** @gqlType CreateTemplateConstraintResult */
type Result = {
  /** @gqlField */
  constraint?: TemplateConstraint | null;
  /** @gqlField */
  diagnostics: Diagnostic[];
  /** @gqlField */
  instantiations: Edge<Task>[];
};

/** @gqlInput */
type InstantiateOptions = {
  fields?: FieldInput[] | null;
};

/** @gqlInput TemplateConstraintOptions */
type Options = {
  /**
   * Request eager instantiation of the given template.
   */
  instantiate?: InstantiateOptions | null;
};

/**
 * Create a new template constraint.
 *
 * @gqlField
 * @see {@link TemplateConstraint}
 */
export async function createTemplateConstraint(
  _: Mutation,
  ctx: Context,
  template: ID,
  entity: ID,
  options?: Options | null,
): Promise<Result> {
  const t = new Task({ id: template }, ctx);
  const { id: entityId, type: entityType } = decodeGlobalId(entity);

  if (t._type !== "worktemplate") {
    return {
      diagnostics: [
        {
          __typename: "Diagnostic",
          code: DiagnosticKind.invalid_type,
          message: `expected one of: worktemplate; received: ${t._type}`,
        },
      ],
      instantiations: [],
    };
  }

  // Locations are the only constrained type we support right now.
  if (entityType !== "location") {
    return {
      diagnostics: [
        {
          __typename: "Diagnostic",
          code: DiagnosticKind.invalid_type,
          message: `expected one of: location; received: ${entityType}`,
        },
      ],
      instantiations: [],
    };
  }

  const result = await sql.begin(async sql => {
    await sql`select * from auth.set_actor(${ctx.auth.userId}, ${ctx.req.i18n.language})`;
    return await createTemplateConstraint_(
      ctx,
      sql,
      t,
      { id: entityId, type: entityType }, // to make tsc happy
      options,
    );
  });

  // If we didn't create a constraint, there should be at least one diagnostic.
  assert(!!result.constraint || result.diagnostics.length > 0);

  return result;
}

export async function createTemplateConstraint_(
  ctx: Context,
  sql: TxSql,
  template: Task,
  entity: { id: string; type: "location" },
  options?: Options | null,
): Promise<Result> {
  assert(template._type === "worktemplate");

  const [constraint] = await match(entity.type)
    .with(
      "location",
      () => sql<[{ id: ID }?]>`
        select encode(('worktemplateconstraint:' || r.id)::bytea, 'base64') as id
        from
            public.worktemplate as t,
            public.location as e,
            legacy0.create_template_constraint_on_location(
                template_id := t.id,
                location_id := e.locationuuid,
                modified_by := auth.current_identity(t.worktemplatecustomerid, ${ctx.auth.userId})
            ) as r
        where
            t.id = ${template._id}
            and e.locationuuid = ${entity.id}
      `,
    )
    .exhaustive();

  assert(!!constraint, "silently failed to create template constraint :(");
  if (!constraint) {
    return {
      diagnostics: [],
      instantiations: [],
    };
  }

  const instantiations = await map(options?.instantiate, async opts => {
    const [row] = await sql<[TaskConstructorArgs?]>`
      select encode(('workinstance:' || r.instance)::bytea, 'base64') as id
      from
          public.worktemplate as t,
          public.location as e,
          engine0.instantiate(
              template_id := t.id,
              location_id := e.locationuuid,
              target_state := 'Open',
              target_type := 'On Demand',
              modified_by := auth.current_identity(t.worktemplatecustomerid, ${ctx.auth.userId})
          ) as r
      where
          t.id = ${template._id}
          and e.locationuuid = ${entity.id}
      group by r.instance
    `;

    if (row) {
      const node = new Task(row, ctx);

      if (opts.fields?.length) {
        const result = await applyFieldEdits_(sql, ctx, node, opts.fields);
        console.debug(
          `createTemplateConstraint: applied ${result.length} field-level edits`,
        );
      }

      return [{ cursor: node.id, node: node } satisfies Edge<Task>];
    }

    return [];
  });

  return {
    constraint: new TemplateConstraint(constraint.id, ctx),
    diagnostics: [],
    instantiations: instantiations ?? [],
  };
}
