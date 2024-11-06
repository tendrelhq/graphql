import { sql } from "@/datasources/postgres";
import type { AttachmentResolvers, ResolversTypes } from "@/schema";
import { decodeGlobalId } from "@/schema/system";

export const Attachment: AttachmentResolvers = {
  // S3 is slow; do it only when explicitly asked.
  async attachment(parent, _, ctx) {
    // and on top of that make DAMN sure we use a loader!
    const a = await ctx.orm.attachment.byId.load(parent.id as string);
    return a.attachment;
  },
  async attachedBy(parent, _, ctx) {
    const { id } = decodeGlobalId(parent.id);
    const [row] = await sql<[{ _key: string }?]>`
        SELECT wi.workerinstanceuuid AS _key
        FROM public.workpictureinstance AS wpi
        INNER JOIN public.workerinstance AS wi
            ON wpi.workpictureinstancemodifiedby = wi.workerinstanceid
        WHERE wpi.workpictureinstanceuuid = ${id}
    `;

    if (row) {
      const worker = await ctx.orm.worker.load(row._key);
      return {
        __typename: "Worker",
        ...worker,
      };
    }

    return undefined;
  },
  async attachedOn(parent, _, ctx) {
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
