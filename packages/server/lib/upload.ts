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

const POST: express.RequestHandler = async (req, res, next) => {
  const input = parser.try(req.body);
  if (input instanceof z.ValidationError) {
    // @ts-ignore
    input.statusCode = 400;
    return next(input);
  }

  const { filename, mimetype, size } = input;
  console.debug(
    `Requesting presigned upload url for ${filename} (${mimetype} ${size}B)`,
  );

  try {
    const Bucket = process.env.ATTACHMENT_BUCKET as string;
    const Key = `${randomUUID()}/${filename}`;
    const command = new PutObjectCommand({ Bucket, Key });
    console.debug(`Presigning upload url for s3://${Bucket}/${Key}`);
    const url = await getSignedUrl(s3, command);
    res.json({ uri: `s3://${Bucket}/${Key}`, url: url });
  } catch (e) {
    console.error("Error while generating presigned url", e);
    return next(e);
  }
};

export default { POST };
