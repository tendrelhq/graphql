import { sql } from "@/datasources/postgres";
import type { LocationResolvers } from "@/schema";
import { isValue } from "@/util";

export const Location: LocationResolvers = {
  async children(parent, { options }, ctx) {
    const childIds = await sql<{ id: string }[]>`
      SELECT locationuuid AS id
      FROM public.location
      WHERE
          locationparentid = (
              SELECT locationid
              FROM public.location
              WHERE locationuuid = ${parent.id}
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
    return ctx.orm.name.load({
      id: parent.name_id as string,
      language_id: ctx.user.language_id as string,
    });
  },
  parent(parent, _, ctx) {
    return ctx.orm.location.load(parent.parent_id as string);
  },
  site(parent, _, ctx) {
    return ctx.orm.location.load(parent.site_id as string);
  },
  tags(parent, _, ctx) {
    return [];
  },
};
