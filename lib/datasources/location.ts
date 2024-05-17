import { NotFoundError } from "@/errors";
import type { Context, Location } from "@/schema";
import Dataloader from "dataloader";
import { sql } from "./postgres";

export default (ctx: Omit<Context, "orm">) =>
  new Dataloader<string, Location>(async keys => {
    const rows = await sql<Location[]>`
      SELECT
          l.locationuuid AS id,
          l.locationnameid AS name_id,
          p.locationuuid AS parent_id,
          s.locationuuid AS site_id
      FROM public.location AS l
      INNER JOIN public.location AS s
          ON l.locationsiteid = s.locationid
      LEFT JOIN public.location AS p
          ON l.locationparentid = p.locationid
      WHERE l.locationuuid IN ${sql(keys)};
    `;

    const byId = rows.reduce(
      (acc, row) => acc.set(row.id as string, row),
      new Map<string, Location>(),
    );

    return keys.map(key => byId.get(key) ?? new NotFoundError(key, "location"));
  });
