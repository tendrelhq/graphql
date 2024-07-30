export function isError<T>(e: T | Error): e is Error {
  return e instanceof Error;
}

export function isValue<T>(v: T | Error): v is T {
  return !isError(v);
}

export function decodeGlobalId(gid: string | number) {
  const decoded = Buffer.from(gid as string, "base64").toString();
  const [type, id] = decoded.split(":");
  if (!type || !id) {
    throw new Error(`Invalid global id: ${gid}, ${decoded}`);
  }
  return { type, id };
}

export type WithKey<T> = T & { _key: string };
