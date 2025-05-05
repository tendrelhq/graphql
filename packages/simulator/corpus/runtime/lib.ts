import type { TxSql } from "@/datasources/postgres";
import type { Location } from "@/schema/platform/archetype/location";
import type { Context } from "@/schema/types";

export const DEFAULT_RUNTIME_LOCATION_TYPE = "Runtime Location";
export const DEFAULT_RUNTIME_CHILD_LOCATIONS = [
  "Mixing Line",
  "Fill Line",
  "Assembly Line",
  "Cartoning Line",
  "Packaging Line",
];

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
