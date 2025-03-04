import { assertNonNull, map } from "@/util";

export const baseurl = assertNonNull(
  map(process.env.BASE_URL, url => {
    const _ = new URL(url);
    return url;
  }),
  "BASE_URL must be set",
);
