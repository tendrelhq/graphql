import { assert } from "@/util";
import { GetObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import DataLoader from "dataloader";
import type { Request } from "express";

type Options = {
  expiresIn: number;
};

export default (_: Request, opts: Options) =>
  new DataLoader<URL, URL>(async urls => {
    const s3 = new S3Client();
    return Promise.all(urls.map(url => createPresignedUrl(s3, url, opts)));
  });

async function createPresignedUrl(client: S3Client, uri: URL, opts: Options) {
  assert(uri.protocol === "s3:");
  const command = new GetObjectCommand({
    Bucket: uri.host,
    Key: uri.pathname.slice(1), // remove the leading '/'
  });
  const url = await getSignedUrl(client, command, {
    expiresIn: opts.expiresIn,
  });
  return new URL(url);
}
