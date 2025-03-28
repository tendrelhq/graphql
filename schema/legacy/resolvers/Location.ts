import { sql } from "@/datasources/postgres";
import type { ActivationStatus, LocationResolvers } from "@/schema";
import { Location as LocationNew } from "@/schema/platform/archetype/location";
import { decodeGlobalId } from "@/schema/system";
import { isValue, nullish } from "@/util";

export const Location: Pick<
  LocationResolvers,
  | "active"
  | "children"
  | "geofence"
  | "id"
  | "name"
  | "nameId"
  | "parent"
  | "parentId"
  | "scanCode"
  | "site"
  | "siteId"
  | "tags"
  | "timeZone"
> = {
  async active(parent) {
    const { id } = decodeGlobalId(parent.id);
    const [row] = await sql<[ActivationStatus]>`
      SELECT
          (
              locationenddate IS null
              OR
              locationenddate > now()
          ) AS active,
          locationstartdate::text AS "activatedAt",
          locationenddate::text AS "deactivatedAt"
      FROM public.location
      WHERE locationuuid = ${id};
    `;
    return row;
  },
  async children(parent, { options }, ctx) {
    const parentId = decodeGlobalId(parent.id).id;
    const childIds = await sql<{ id: string }[]>`
      SELECT locationuuid AS id
      FROM public.location
      WHERE
          locationparentid = (
              SELECT locationid
              FROM public.location
              WHERE locationuuid = ${parentId}
          )
          ${
            options?.cornerstone
              ? sql`AND locationiscornerstone = ${true}`
              : sql``
          }
          ${options?.site ? sql`AND locationistop = ${true}` : sql``}
    `;
    const children = await ctx.orm.location.loadMany(childIds.map(c => c.id));
    return children.filter(isValue);
  },
  async geofence(parent, _, ctx) {
    const hack = await ctx.orm.location.load(decodeGlobalId(parent.id).id);
    const isGeofenceDefined =
      nullish(hack.latitude) || nullish(hack.longitude) || nullish(hack.radius);

    if (isGeofenceDefined) return undefined;

    return {
      latitude: hack.latitude,
      longitude: hack.longitude,
      radius: hack.radius,
    };
  },
  async name(parent, _, ctx) {
    const hack = await ctx.orm.location.load(decodeGlobalId(parent.id).id);
    return ctx.orm.name.load(decodeGlobalId(hack.nameId).id);
  },
  // @ts-expect-error: temporary under migration
  async parent(parent, _, ctx) {
    const hack = await ctx.orm.location.load(decodeGlobalId(parent.id).id);
    if (hack.parentId) {
      return new LocationNew({ id: hack.parentId as string });
    }
  },
  async scanCode(parent, _, ctx) {
    const hack = await ctx.orm.location.load(decodeGlobalId(parent.id).id);
    return hack.scanCode;
  },
  // @ts-expect-error: temporary under migration
  async site(parent, _, ctx) {
    const hack = await ctx.orm.location.load(decodeGlobalId(parent.id).id);
    return new LocationNew({ id: hack.siteId as string });
  },
  tags(parent, _, ctx) {
    return [];
  },
  async timeZone(parent, _, ctx) {
    const hack = await ctx.orm.location.load(decodeGlobalId(parent.id).id);
    return hack.timeZone;
  },
};
