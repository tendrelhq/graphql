import { randomUUID } from "node:crypto";
import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import type express from "express";
import z from "myzod";

const parser = z.object({
  filename: z.string(),
  mimetype: z.string(),
  size: z.number(),
});

const s3 = new S3Client();

const POST: express.RequestHandler = async (
  req: express.Request,
  res: express.Response,
) => {
  const { filename, mimetype, size } = parser.parse(req.body);
  console.log(
    `Requesting presigned upload url for ${filename} (${mimetype} ${size}B)`,
  );

  const Bucket = process.env.ATTACHMENT_BUCKET as string;
  const Key = `${randomUUID()}/${filename}`;
  const command = new PutObjectCommand({ Bucket, Key });
  console.log(`Presigning upload url for s3://${Bucket}/${Key}`);

  const url = await getSignedUrl(s3, command);
  res.json({ uri: `s3://${Bucket}/${Key}`, url: url });
};

export default { POST };
