import { EntityNotFound } from "@/errors";
import type { Location } from "@/schema";
import type { WithKey } from "@/util";
import Dataloader from "dataloader";
import type { Request } from "express";
import { sql } from "./postgres";

export default (_: Request) =>
  new Dataloader<string, Location>(async keys => {
    const rows = await sql<WithKey<Location>[]>`
      SELECT
          l.locationuuid AS _key,
          encode(('location:' || l.locationuuid)::bytea, 'base64') AS id,
          (l.locationenddate IS NULL OR l.locationenddate > now()) AS active,
          l.locationstartdate::text AS "activatedAt",
          l.locationenddate::text AS "deactivatedAt",
          encode(('name:' || n.languagemasteruuid)::bytea, 'base64') AS "nameId",
          encode(('location:' || p.locationuuid)::bytea, 'base64') AS "parentId",
          l.locationscanid AS "scanCode",
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
      (acc, row) => acc.set(row._key as string, row),
      new Map<string, Location>(),
    );

    return keys.map(key => byId.get(key) ?? new EntityNotFound("location"));
  });
