import type { Attachment } from "@/schema";
import { GetObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import Dataloader from "dataloader";
import type { Request } from "express";
import { sql } from "./postgres";
import { decodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";

async function createPresignedUrl(client: S3Client, uri: URL) {
  const command = new GetObjectCommand({
    Bucket: uri.host,
    Key: uri.pathname.slice(1), // remove the leading '/'
  });
  if (uri.protocol !== "s3:") {
    throw "invariant violated";
  }
  return getSignedUrl(client, command, {
    expiresIn: Number(process.env.ATTACHMENT_EXPIRATION_TIME_SECONDS ?? 3600),
  });
}

export default (_: Request) => ({
  byId: new Dataloader<string, Attachment>(async keys => {
    const pks = keys.map(k => decodeGlobalId(k).id);
    const rows = await sql<{ _key: string; uri: string }[]>`
        SELECT
            workpictureinstanceuuid AS _key,
            workpictureinstancestoragelocation AS uri
        FROM public.workpictureinstance
        WHERE workpictureinstanceuuid IN ${sql(pks)};
    `;
    const s3 = new S3Client();
    return Promise.all(
      pks.map(async (pk, i) => {
        const row = rows.find(r => r._key === pk);

        if (!row) {
          throw new GraphQLError(`No Attachment for id '${pk}'`, {
            extensions: {
              code: "NOT_FOUND",
            },
          });
        }

        return {
          id: keys[i],
          attachment: await createPresignedUrl(s3, new URL(row.uri)),
        };
      }),
    );
  }),
});
