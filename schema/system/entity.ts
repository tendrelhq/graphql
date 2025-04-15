import { constructHeadersFromArgs, extractPageInfo } from "@/api";
import { getAccessToken } from "@/auth";
import { sql } from "@/datasources/postgres";
import { GraphQLError } from "graphql";
import type { ID, Int } from "grats";
import { encodeGlobalId } from ".";
import type { Context } from "../types";
import { type Field, field$fragment } from "./component";
import type { DisplayName } from "./component/name";
import type { Connection, Edge } from "./pagination";

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

  const headers = constructHeadersFromArgs(args);
  headers.set("Authorization", `Bearer ${token}`);

  // FIXME: Should not be required?
  const [{ owner }] = await sql`
    select entityinstanceuuid as owner
    from entity.entityinstance
    where entityinstanceoriginaluuid = ${args.owner}
  `;

  const q = new URLSearchParams({
    select: "id",
    owner: `eq.${owner}`,
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

  const r = await fetch(
    `http://localhost:4001/entity_instance?${q.toString()}`,
    {
      method: "GET",
      headers: headers,
    },
  );

  if (!r.ok) {
    const e = await r.json();
    console.error(e);
    throw new GraphQLError("Internal Server Error");
  }

  const rows: { id: string }[] = await r.json();
  return {
    edges: rows.map(e => ({
      cursor: "", // ignored but technically required by the connection spec
      node: {
        _id: e.id,
        _type: "entity_instance",
        id: encodeGlobalId({
          id: e.id,
          type: "entity_instance",
        }),
      },
    })),
    ...extractPageInfo(r),
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

/** @gqlMutationField */
export async function createEntityInstance(
  ctx: Context,
  // Temporary. This should ideally come via the JWT, but we aren't there yet.
  owner: ID,
  template: ID,
  name: string,
  type: ID,
): Promise<EntityInstance> {
  const token = await getAccessToken(ctx.auth.userId)
    .then(r => r.json())
    .then(r => r.access_token);

  const r = await fetch("http://localhost:4001/entity_instance?select=id", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      Prefer: "return=representation",
    },
    body: JSON.stringify({ owner, template, name, type }),
  });

  const [entity]: [{ id: ID }] = await r.json();
  return {
    _id: entity.id,
    _type: "entity_instance",
    id: encodeGlobalId({ type: "entity_instance", id: entity.id }),
  };
}

/**
 * @gqlType
 */
export interface EntityTemplate {
  readonly _type: string;
  readonly _id: string;

  /** @gqlField */
  id: ID;
}

/** @gqlField name */
export async function entityTemplateName(
  entity: EntityTemplate,
  ctx: Context,
): Promise<DisplayName> {
  return await ctx.orm.displayName.load(entity.id);
}

/**
 * @gqlQueryField
 */
export async function templates(
  ctx: Context,
  args: {
    first?: Int | null;
    after?: string | null;
    /**
     * Only Entities of the given type. The type is the *canonical* type, i.e.
     * not localized. This is best for programmatic usage.
     */
    ofType?: string[] | null;
  },
): Promise<Connection<EntityTemplate>> {
  const token = await getAccessToken(ctx.auth.userId)
    .then(r => r.json())
    .then(r => r.access_token);

  const headers = constructHeadersFromArgs(args);
  headers.set("Authorization", `Bearer ${token}`);

  const q = new URLSearchParams({ select: "id" });
  if (args.ofType?.length) {
    // FIXME: This is wrong!
    q.append("type", `in.(${args.ofType.join(",")})`);
  }

  const r = await fetch(
    `http://localhost:4001/entity_template?${q.toString()}`,
    {
      method: "GET",
      headers: headers,
    },
  );

  const rows: { id: string }[] = await r.json();
  return {
    edges: rows.map(e => ({
      cursor: "", // ignored but technically required by the connection spec
      node: {
        _id: e.id,
        _type: "entity_template",
        id: encodeGlobalId({ id: e.id, type: "entity_template" }),
      },
    })),
    ...extractPageInfo(r),
  };
}

/** @gqlMutationField */
export async function createEntityTemplate(
  ctx: Context,
  // Temporary. This should ideally come via the JWT, but we aren't there yet.
  owner: ID,
  template: ID,
  name: string,
  type: ID,
): Promise<EntityTemplate> {
  const token = await getAccessToken(ctx.auth.userId)
    .then(r => r.json())
    .then(r => r.access_token);

  const r = await fetch("http://localhost:4001/entity_template?select=id", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      Prefer: "return=representation",
    },
    body: JSON.stringify({ owner, template, name, type }),
  });

  const [row]: [{ id: ID }] = await r.json();
  return {
    _id: row.id,
    _type: "entity_instance",
    id: encodeGlobalId({ type: "entity_template", id: row.id }),
  };
}
