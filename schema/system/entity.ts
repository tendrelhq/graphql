import { constructHeadersFromArgs, extractPageInfo } from "@/api";
import { getAccessToken } from "@/auth";
import type { ID, Int } from "grats";
import { encodeGlobalId } from ".";
import type { Context } from "../types";
import type { DisplayName } from "./component/name";
import type { Connection } from "./pagination";

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
    /**
     * Only Entities of the given type. The type is the *canonical* type, i.e.
     * not localized. This is best for programmatic usage.
     */
    ofType?: string[] | null;
  },
): Promise<Connection<EntityInstance>> {
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
    `http://localhost:4001/entity_instance?${q.toString()}`,
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
export async function entityTemplate_name(
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
