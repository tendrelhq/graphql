import { sql } from "@/datasources/postgres";
import type { ActivationStatus, LocationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { isValue } from "@/util";

export const Location: LocationResolvers = {
  async active(parent) {
    const { id } = decodeGlobalId(parent.id as string);
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
    const parentId = decodeGlobalId(parent.id as string).id;
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
  name(parent, _, ctx) {
    return ctx.orm.name.load(decodeGlobalId(parent.nameId).id);
  },
  parent(parent, _, ctx) {
    if (parent.parentId) {
      return ctx.orm.location.load(decodeGlobalId(parent.parentId).id);
    }
  },
  site(parent, _, ctx) {
    return ctx.orm.location.load(decodeGlobalId(parent.siteId).id);
  },
  tags(parent, _, ctx) {
    return [];
  },
};
