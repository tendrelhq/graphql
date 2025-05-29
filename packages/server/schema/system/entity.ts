import { constructHeadersFromArgs, extractPageInfo } from "@/api";
import { getAccessToken, setCurrentIdentity } from "@/auth";
import { base_url } from "@/config";
import { sql } from "@/datasources/postgres";
import { assert, assertNonNull, assertUnderlyingType } from "@/util";
import { GraphQLError } from "graphql";
import type { ID, Int } from "grats";
import { decodeGlobalId, encodeGlobalId } from ".";
import type { Context } from "../types";
import { type Field, type FieldInput, field$fragment } from "./component";
import type { DisplayName } from "./component/name";
import { Task } from "./component/task";
import type { Connection, Edge } from "./pagination";

//-----------------------------------------------------------------------------
//
// Entity Instances
//
// Note that currently entity instances map directly to `entity.entityinstance`s
// by way of the Entity REST API.
//
//-----------------------------------------------------------------------------

/**
 * Entities represent distinct objects in the system. They can be physical
 * objects, like Locations, Resources and Workers, or logical ones, like
 * "Scan Codes".
 *
 * @gqlType
 */
export interface EntityInstance {
  readonly _type: string;
  readonly _id: string;

  /** @gqlField */
  id: ID;
}

/** @gqlField name */
export async function entityInstanceName(
  entity: EntityInstance,
  ctx: Context,
): Promise<DisplayName> {
  return await ctx.orm.displayName.load(entity.id);
}

/**
 * @gqlQueryField
 */
export async function instances(
  ctx: Context,
  args: {
    first?: Int | null;
    after?: string | null;
    /** TEMPORARY: this should be the customer/organization uuid. */
    owner: ID;
    /** Instances with the given parent (instance). */
    parent?: ID[] | null;
  },
): Promise<Connection<EntityInstance>> {
  const token = await getAccessToken(ctx.auth.userId)
    .then(r => r.json())
    .then(r => r.access_token);

  const headers = constructHeadersFromArgs(args, { count: "exact" });
  headers.set("Authorization", `Bearer ${token}`);

  const { type: ownerType, id: ownerId } = decodeGlobalId(args.owner);
  assert(ownerType === "organization", "`owner` must point to a customer!");

  // FIXME: Should not be required?
  const [{ owner }] = await sql`
    select entityinstanceuuid as owner
    from entity.entityinstance
    where entityinstanceoriginaluuid = ${ownerId}
  `;

  const q = new URLSearchParams({
    select: "id",
    owner: `eq.${owner}`,
    order: "_order.asc",
    _deleted: "eq.false",
  });
  if (args.parent?.length) {
    // FIXME: This is a weird one in Keller's entity model. Every entityinstance
    // has a parent, template and type. I'm not entirely sure why these three
    // exist. From looking through what Keller has done so far, this seems to be
    // the case, e.g. for a custag:
    // - template and type point at the "Customer Tag" template and instance, respectively
    // - parent points at the "Reason Code" instance
    q.append("parent", `in.(${args.parent.join(",")})`);
  }

  const res = await fetch(
    new URL(`/api/v1/entity_instance?${q.toString()}`, base_url),
    {
      method: "GET",
      headers: headers,
    },
  );

  if (!res.ok) {
    // TODO: Better error handling when interacting with the Entity API.
    const body = await res.json();
    console.error(body);
    throw new GraphQLError("Internal Server Error");
  }

  const rows: { id: string }[] = await res.json();
  return {
    edges: rows.map(row => ({
      cursor: "", // ignored but technically required by the connection spec
      node: {
        _id: row.id,
        _type: "entity_instance",
        id: encodeGlobalId({
          id: row.id,
          type: "entity_instance",
        }),
      },
    })),
    ...extractPageInfo(res),
  };
}

/**
 * Lift an EntityInstance to a set of Fields where the given EntityInstance
 * identifies as the Field's ValueType.
 *
 * @gqlField
 */
export async function asFieldTemplateValueType(
  edge: Edge<EntityInstance>,
): Promise<Connection<Field>> {
  // This is sort of half baked at the moment since we are only using this for
  // Runtime "reason codes". Additionally, work instances and templates are not
  // yet covered by the entity model.

  // The EntityInstance we have here is really a custag. We need to:
  // 1. Find the custag
  // 2. Find the systag for (1)
  // 3. Find workresults whose type is (2)

  // Note however that we are cheating, in that the workresults we create are of
  // type String. So we can't naively lookup the Fields using canonical foreign
  // keys. Rather, we must go through worktemplateconstraint.

  const rows = await sql<Field[]>`
    with field as (
      select
        engine1.base64_encode(convert_to('workresult:' || wr.id, 'utf8')) as id,
        s.systagtype as "type",
        wr.workresultdefaultvalue as "value"
      from entity.entityinstance
      inner join public.custag on entityinstanceoriginaluuid = custaguuid
      inner join public.worktemplateconstraint
        on custagcustomerid = worktemplateconstraintcustomerid
        and custaguuid = worktemplateconstraintconstraintid
      inner join public.workresult as wr
        on worktemplateconstraintresultid = wr.id
      inner join public.systag as s
        on wr.workresulttypeid = s.systagid
      where entityinstanceuuid = ${edge.node._id}
    )
    ${field$fragment}
  `;

  return {
    edges: rows.map(row => ({ cursor: row.id, node: row })),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: rows.length,
  };
}

/**
 * @gqlField asTask
 */
export async function castEntityInstanceToTask(
  i: EntityInstance,
): Promise<Task> {
  return Task.fromTypeId(i._type, i._id);
}

/** @gqlMutationField */
export async function createCustagAsFieldTemplateValueTypeConstraint(
  ctx: Context,
  field: ID,
  name: string,
  parent: ID,
  order?: Int | null,
): Promise<Edge<EntityInstance>> {
  const { type: fieldType, id: fieldId } = decodeGlobalId(field);
  assert(fieldType === "workresult", "`field` must point to a workresult!");

  const entity_id = await sql.begin(async sql => {
    // Grab the owner id.
    const [{ owningEntity, owningLegacyCustomer }] = await sql`
      select
        entityinstance.entityinstanceuuid as "owningEntity",
        customer.customerid as "owningLegacyCustomer"
      from public.workresult
      inner join public.customer on workresultcustomerid = customerid
      inner join entity.entityinstance on customeruuid = entityinstanceoriginaluuid
      where workresult.id = ${fieldId}
    `;

    // Create the custag and entity instance.
    const [
      { create_custaguuid: custag_id, create_custagentityuuid: entity_id },
    ] = await sql`
      call entity.crud_custag_create(
        ${owningEntity},
        ${parent},
        null,
        ${order ?? null},
        ${name},
        null,
        null,
        null,
        null, 
        null, 
        null,
        null,
        null,
        auth.current_identity(${owningLegacyCustomer}, ${ctx.auth.userId})
      );
    `;

    // Create the template constraint.
    await sql`
      insert into public.worktemplateconstraint (
        worktemplateconstraintcustomerid,
        worktemplateconstraintcustomeruuid,
        worktemplateconstrainttemplateid,
        worktemplateconstraintresultid,
        worktemplateconstraintconstrainedtypeid,
        worktemplateconstraintconstraintid,
        worktemplateconstraintmodifiedby
      )
      select
        customerid,
        customeruuid,
        worktemplate.id,
        workresult.id,
        systag.systaguuid,
        custag.custaguuid,
        auth.current_identity(customerid, ${ctx.auth.userId})
      from
        public.customer,
        public.workresult,
        public.worktemplate,
        public.systag,
        public.custag
      where customerid = ${owningLegacyCustomer}
        and workresult.id = ${fieldId}
        and workresult.workresultworktemplateid = worktemplate.worktemplateid
        and custag.custaguuid = ${custag_id}
        and systag.systaguuid = (
            select entityinstanceoriginaluuid
            from entity.entityinstance
            where entityinstanceuuid = ${parent}
        )
    `;

    return entity_id;
  });

  return {
    cursor: "",
    node: {
      _id: entity_id,
      _type: "entity_instance",
      id: encodeGlobalId({ type: "entity_instance", id: entity_id }),
    },
  };
}

/** @gqlType */
export type CreateInstancePayload = {
  /** @gqlField */
  edge: Edge<EntityInstance>;
};

/** @gqlMutationField */
export async function createInstance(
  args: {
    /** @deprecated use `parent` instead */
    location?: ID | null;
    parent?: ID | null;
    template: ID;
    fields?: FieldInput[] | null;
    name?: string | null;
  },
  ctx: Context,
): Promise<CreateInstancePayload> {
  const t = new Task({ id: args.template });
  const i = await sql.begin(async sql => {
    await setCurrentIdentity(sql, ctx);
    const i = await t.instantiate(
      {
        ...args,
        parent: assertNonNull(
          args.parent ?? args.location,
          "args.parent is required",
        ),
      },
      ctx,
      sql,
    );
    return assertNonNull(i);
  });
  // NOTE: this is kinda hacky at the moment. We want everything to be an
  // EntityInstance but those guys actually map to Keller's entity model whereas
  // there is no place in the entity model at the moment for work instances. So,
  // for now, we will just fake it. Note that "entity_instance" is already taken
  // (and maps to the entity model) so we need a new type name here.
  const entityInstanceId = encodeGlobalId({ type: "instance", id: i._id });
  return {
    edge: {
      cursor: entityInstanceId,
      node: {
        _type: i._type,
        _id: i._id,
        id: entityInstanceId,
      },
    },
  };
}

//-----------------------------------------------------------------------------
//
// Entity Templates
//
// Note that currently "entity" templates are really just (and only)
// worktemplates under the hood. This will soon change.
//
//-----------------------------------------------------------------------------

export type EntityTemplateConstructorArgs = { id: ID };

/** @gqlType */
export class EntityTemplate {
  readonly _type: "template";
  readonly _id: string;
  /** @gqlField */
  readonly id: ID;

  constructor(args: EntityTemplateConstructorArgs) {
    const { type, id } = decodeGlobalId(args.id);
    this._type = assertUnderlyingType("template", type);
    this._id = id;
    this.id = args.id;
  }

  static fromTypeId(type: "template", id: string) {
    return new EntityTemplate({ id: encodeGlobalId({ type, id }) });
  }
}

/** @gqlQueryField */
export async function templates(
  args: {
    /** TEMPORARY: this should be the customer/organization uuid. */
    owner: ID;
    /**
     * Templates of the given type. This maps (currently) to worktemplatetype.
     * For example, in Runtime the following template types exist:
     * - Run
     * - Downtime
     * - Idle Time
     * Any of these are suitable for this API.
     *
     * Also see `Task.chainAgg`, as that API takes a similar parameter `overType`.
     */
    type?: string[] | null;
  },
  ctx: Context,
): Promise<Connection<EntityTemplate>> {
  const owner = decodeGlobalId(args.owner);
  assertUnderlyingType("organization", owner.type);

  const cte = args.type?.length
    ? sql`
        select
          worktemplate.id,
          worktemplate.worktemplateorder as _order
        from public.worktemplate
        inner join public.customer
          on worktemplatecustomerid = customerid
          and customeruuid = ${owner.id}
        where exists (
          select 1
          from public.worktemplatetype
          inner join public.systag on worktemplatetypesystagid = systagid
          where worktemplate.worktemplateid = worktemplatetypeworktemplateid
            and systagtype in ${sql(args.type)}
        )
      `
    : sql`
        select
          worktemplate.id,
          worktemplate.worktemplateorder as _order
        from public.worktemplate
        inner join public.customer
          on worktemplatecustomerid = customerid
          and customeruuid = ${owner.id}
      `;

  const rows = await sql<EntityTemplateConstructorArgs[]>`
    with cte as (${cte})
    select engine1.base64_encode(convert_to('template:' || cte.id, 'utf8')) as id
    from cte
    order by cte._order;
  `;

  return {
    edges: rows.map(row => ({
      cursor: row.id,
      node: new EntityTemplate(row),
    })),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: rows.length,
  };
}

/** @gqlField asTask */
export function castEntityTemplateToTask(t: EntityTemplate): Task {
  if (t._type !== "template") {
    throw new GraphQLError(
      `Cannot cast Template (of type: ${t._type}) to Task`,
      {
        extensions: {
          code: "BAD_REQUEST",
        },
      },
    );
  }
  return Task.fromTypeId("worktemplate", t._id);
}
