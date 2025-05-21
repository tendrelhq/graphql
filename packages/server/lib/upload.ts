import { randomUUID } from "node:crypto";
import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import type express from "express";
import z from "zod";

const parser = z.object({
  filename: z.string(),
  mimetype: z.string(),
  size: z.number(),
});

const s3 = new S3Client();

const POST: express.RequestHandler = async (req, res) => {
  const result = parser.safeParse(req.body);
  if (!result.success) {
    return res.status(400).json({ message: result.error.message });
  }

  const { filename, mimetype, size } = result.data;
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
    res.status(500).json({ message: "Upload failed" });
  }
};

export default { POST };
