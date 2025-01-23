import type { Geofence, Location } from "@/schema";
import type { WithKey } from "@/util";
import Dataloader from "dataloader";
import type { Request } from "express";
import { GraphQLError } from "graphql/error";
import { sql } from "./postgres";

export default (_: Request) =>
  new Dataloader<string, Location & Geofence>(async keys => {
    const rows = await sql<WithKey<Location & Geofence>[]>`
      SELECT
          l.locationuuid AS _key,
          encode(('location:' || l.locationuuid)::bytea, 'base64') AS id,
          encode(('name:' || n.languagemasteruuid)::bytea, 'base64') AS "nameId",
          encode(('location:' || p.locationuuid)::bytea, 'base64') AS "parentId",
          l.locationscanid AS "scanCode",
          --l.locationradius AS "radius",
          --l.locationlatitude AS "latitude",
          --l.locationlongitude AS "longitude",
          encode(('location:' || s.locationuuid)::bytea, 'base64') AS "siteId",
          l.locationtimezone AS "timeZone"
      FROM public.location AS l
      INNER JOIN public.languagemaster AS n
          ON l.locationnameid = n.languagemasterid
      INNER JOIN public.location AS s
          ON l.locationsiteid = s.locationid
      LEFT JOIN public.location AS p
          ON l.locationparentid = p.locationid
      WHERE l.locationuuid IN ${sql(keys)};
    `;

    const byId = rows.reduce(
      (acc, row) => acc.set(row._key, row),
      new Map<string, Location & Geofence>(),
    );

    return keys.map(
      key =>
        byId.get(key) ??
        new GraphQLError(`No Location with id '${key}'`, {
          extensions: {
            code: "NOT_FOUND",
          },
        }),
    );
  });
