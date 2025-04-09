import type { Connection } from "@/schema/system/pagination";
import { assert, type RawPaginationArgs, assertNonNull, map } from "./util";

type PaginationMeta = Omit<Connection<void>, "edges">;

export function extractPageInfo(res: Response): PaginationMeta {
  const contentRange = assertNonNull(
    res.headers.get("Content-Range"),
    "cannot paginate without content-range",
  );

  const [start, end, count] = map(contentRange.split("/"), cr =>
    [...cr[0].split("-"), cr[1]].map(Number),
  );
  assert(Number.isFinite(start));
  assert(Number.isFinite(end));
  assert(Number.isFinite(count));

  if (res.status === 206) {
    return {
      pageInfo: {
        hasNextPage: true,
        hasPreviousPage: false,
        endCursor: end.toString(),
        startCursor: start.toString(),
      },
      totalCount: count,
    };
  }

  return {
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: count,
  };
}

export function constructHeadersFromArgs(
  args: RawPaginationArgs,
  preferences?: string[],
): Headers {
  const headers = new Headers({
    Prefer: ["count=estimated"].concat(preferences ?? []).join(","),
  });
  const lower = Number(args.after ?? 0);
  const count = Math.min(args.first ?? 100, 100);
  const upper = lower + count - 1;
  headers.append("Range", `${lower}-${upper}`);
  return headers;
}
