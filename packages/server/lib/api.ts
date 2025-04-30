import type { Connection } from "@/schema/system/pagination";
import { assert, type RawPaginationArgs, assertNonNull, map } from "./util";

type PaginationMeta = Omit<Connection<void>, "edges">;

export function extractPageInfo(res: Response): PaginationMeta {
  const contentRange = assertNonNull(
    res.headers.get("Content-Range"),
    "cannot paginate without content-range",
  );

  const range = map(contentRange.split("/"), cr => {
    const [start, end] = cr[0].split("-");
    return {
      start: start,
      end: end,
      count: Number(cr[1]),
    };
  });
  assert(Number.isFinite(range.count), `invalid count: ${contentRange}`);

  if (range.start === "*" || res.status !== 206) {
    // Range not satisfiable
    return {
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: range.count,
    };
  }

  const start = Number(range.start);
  const end = Number(range.end);
  assert(Number.isFinite(start), `invalid start: ${contentRange}`);
  assert(Number.isFinite(end), `invalid end: ${contentRange}`);
  return {
    pageInfo: {
      hasNextPage: end < range.count - 1,
      hasPreviousPage: start > 0,
      endCursor: end.toString(),
      startCursor: start.toString(),
    },
    totalCount: range.count,
  };
}

export function constructHeadersFromArgs(
  args: RawPaginationArgs,
  preferences?: Record<string, string> & {
    count?: "estimated" | "exact" | "planned";
  },
): Headers {
  const prefers = preferences
    ? Object.keys(preferences)
        .map(key => `${key}=${preferences[key]}`)
        .join(",")
    : "count=estimated";
  const headers = new Headers({ Prefer: prefers });
  const lower = Number(args.after ?? 0);
  const count = Math.min(args.first ?? 100, 100);
  const upper = lower + count - 1;
  headers.append("Range-Unit", "items");
  headers.append("Range", `${lower}-${upper}`);
  return headers;
}
