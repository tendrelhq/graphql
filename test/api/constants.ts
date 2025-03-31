import { assertNonNull, map } from "@/util";

export const baseurl = assertNonNull(
  map(process.env.BASE_URL, url => new URL(url)),
  "BASE_URL must be set",
);

export const pgrst_base_url = assertNonNull(
  map(process.env.PGRST_BASE_URL, url => new URL(url)),
  "PGRST_BASE_URL must be set",
);
