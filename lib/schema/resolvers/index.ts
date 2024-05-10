import type { QueryResolvers } from "@/schema";

export type QueryResolver<T extends keyof QueryResolvers> = NonNullable<
  QueryResolvers[T]
>;
