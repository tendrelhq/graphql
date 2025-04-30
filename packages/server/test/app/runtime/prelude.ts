import { type TxSql, sql } from "@/datasources/postgres";
import type { Location } from "@/schema/platform/archetype/location";
import { Task, type TaskStateName } from "@/schema/system/component/task";
import { fsm } from "@/schema/system/component/task_fsm";
import type { Context } from "@/schema/types";
import type { Customer } from "@/test/prelude";
import { assert, assertNonNull, nullish } from "@/util";
import { match } from "ts-pattern";

export const DEFAULT_SITE_NAME = "Frozen Tendy Factory";
export const DEFAULT_RUNTIME_LOCATION_TYPE = "Runtime Location";
export const DEFAULT_RUNTIME_CHILD_LOCATIONS = [
  "Mixing Line",
  "Fill Line",
  "Assembly Line",
  "Cartoning Line",
  "Packaging Line",
];

/**
 * Note that this also creates the default child Locations!
 */
export async function createDefaultRuntimeSite(
  args: {
    customer: Customer;
    name: string;
  },
  ctx: Context,
  sql: TxSql,
): Promise<Location> {
  const s = await args.customer.addLocation(
    { name: args.name, type: DEFAULT_SITE_NAME },
    ctx,
    sql,
  );
  for (const name of DEFAULT_RUNTIME_CHILD_LOCATIONS) {
    await s.insertChild(
      { name, type: DEFAULT_RUNTIME_LOCATION_TYPE },
      ctx,
      sql,
    );
  }
  return s;
}

export async function createDefaultRuntimeTemplate(
  args: {
    location: Location;
    /** @see Location.createTemplate */
    supportsLazyInstantiation?: boolean;
  },
  ctx: Context,
  sql: TxSql,
) {
  return await args.location.createTemplate(
    {
      name: "Run",
      fields: [
        // Note that we still have the primary/order requirement for
        // Overrides (primary + 0 => start, 1 => end).
        // This will be removed in the future.
        {
          name: "Override Start Time",
          type: "timestamp",
          isPrimary: true,
          order: 0,
        },
        {
          name: "Override End Time",
          type: "timestamp",
          isPrimary: true,
          order: 1,
        },
        { name: "Run Output", type: "number", order: 2 },
        { name: "Reject Count", type: "number", order: 3 },
        { name: "Comments", type: "string", order: 99 },
      ],
      supportsLazyInstantiation: args.supportsLazyInstantiation,
      types: ["Trackable", "Runtime"],
    },
    ctx,
    sql,
  );
}

export async function createDefaultDowntimeTemplate(
  args: {
    location: Location;
    order?: number;
  },
  ctx: Context,
  sql: TxSql,
) {
  return await args.location.createTemplate(
    {
      name: "Downtime",
      fields: [
        // Note that we still have the primary/order requirement for
        // Overrides (primary + 0 => start, 1 => end).
        // This will be removed in the future.
        {
          name: "Override Start Time",
          type: "timestamp",
          isPrimary: true,
          order: 0,
        },
        {
          name: "Override End Time",
          type: "timestamp",
          isPrimary: true,
          order: 1,
        },
        { name: "Description", type: "string", order: 99 },
      ],
      order: 0,
      types: ["Downtime"],
    },
    ctx,
    sql,
  );
}

export async function createDefaultIdleTimeTemplate(
  args: {
    location: Location;
  },
  ctx: Context,
  sql: TxSql,
) {
  return await args.location.createTemplate(
    {
      name: "Idle Time",
      fields: [
        // Note that we still have the primary/order requirement for
        // Overrides (primary + 0 => start, 1 => end).
        // This will be removed in the future.
        {
          name: "Override Start Time",
          type: "timestamp",
          isPrimary: true,
          order: 0,
        },
        {
          name: "Override End Time",
          type: "timestamp",
          isPrimary: true,
          order: 1,
        },
        { name: "Description", type: "string", order: 99 },
      ],
      order: 1,
      types: ["Idle Time"],
    },
    ctx,
    sql,
  );
}

export async function createDefaultBatchTemplate(
  args: {
    location: Location;
    /** @default false */
    supportsLazyInstantiation?: boolean;
  },
  ctx: Context,
  sql: TxSql,
) {
  return await args.location.createTemplate(
    {
      name: "Batch",
      fields: [
        { name: "Customer", type: "string" },
        { name: "Product Name", type: "string" },
        { name: "SKU", type: "string" },
      ],
      supportsLazyInstantiation: args.supportsLazyInstantiation ?? false,
      types: ["Batch"],
    },
    ctx,
    sql,
  );
}

export async function mostRecentlyInProgress(t: Task): Promise<Task> {
  assert(t._type === "workinstance");
  const [row] = await sql`
    select id
    from public.workinstance
    where
        workinstanceoriginatorworkinstanceid in (
            select og.workinstanceid
            from public.workinstance as og
            where og.id = ${t._id}
        )
        and workinstancestatusid = 707
    order by workinstanceid desc
    limit 1;
  `;
  assert(!nullish(row), "no in progress instance");
  return Task.fromTypeId("workinstance", row.id);
}

export async function mostRecentInstance(t: Task): Promise<Task> {
  assert(t._type === "worktemplate");
  const [row] = await sql`
    select id
    from public.workinstance
    where
      workinstanceworktemplateid in (
        select worktemplateid
        from public.worktemplate
        where id = ${t._id}
      )
    order by workinstanceid desc
    limit 1;
  `;
  assert(!nullish(row), "no instance");
  return Task.fromTypeId("workinstance", row.id);
}

export async function getLatestFsm(t: Task) {
  assert(t._type === "worktemplate");
  const root = await mostRecentInstance(t);
  const f = await fsm(root);
  return { root, fsm: assertNonNull(f) };
}

export async function newlyInstantiatedChainFrom(
  t: Task,
): Promise<Task | null> {
  assert(t._type === "workinstance");
  const [row] = await sql`
    select id
    from public.workinstance
    where
        workinstancepreviousid = (
            select workinstanceid
            from public.workinstance
            where id = ${t._id}
        )
        and workinstancestatusid = 706
  `;
  if (!row) return null;
  return Task.fromTypeId("workinstance", row.id);
}
