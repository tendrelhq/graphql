export function isError<T>(e: T | Error): e is Error {
  return e instanceof Error;
}

export function isValue<T>(v: T | Error): v is T {
  return !isError(v);
}

export type WithKey<T> = T & { _key: string };
