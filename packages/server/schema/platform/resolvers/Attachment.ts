import { sql } from "@/datasources/postgres";
import type { AttachmentResolvers, ResolversTypes } from "@/schema";
import { decodeGlobalId } from "@/schema/system";

// TODO: migrate to grats with Temporal.
export const Attachment: Pick<AttachmentResolvers, "attachedOn"> = {
  async attachedOn(parent) {
    const { id } = decodeGlobalId(parent.id);
    const [row] = await sql<[ResolversTypes["Temporal"]]>`
        SELECT
            'ZonedDateTime' AS "__typename",
            (extract(epoch from workpictureinstancecreateddate) * 1000)::text AS "epochMilliseconds",
            wi.workinstancetimezone AS "timeZone"
        FROM public.workpictureinstance AS wpi
        INNER JOIN public.workinstance AS wi
            ON wpi.workpictureinstanceworkinstanceid = wi.workinstanceid
        WHERE workpictureinstanceuuid = ${id};
    `;
    return row;
  },
};
