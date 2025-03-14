import { assertNonNull, map } from "@/util";

export const baseurl = assertNonNull(
  map(process.env.BASE_URL, url => new URL(url)),
  "BASE_URL must be set",
);
