import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import { execute, paginateQuery } from "@/test/prelude";
import {
  ListLocationsTestDocument,
  PaginateLocationsTestDocument,
} from "./locations.test.generated";

describe("[console] locations", () => {
  let ACCOUNT: string; // customer

  test("list locations", async () => {
    const result = await execute(schema, ListLocationsTestDocument, {
      account: ACCOUNT,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("pagination", async () => {
    let i = 0;
    for await (const page of paginateQuery({
      async execute(cursor) {
        return await execute(schema, PaginateLocationsTestDocument, {
          account: ACCOUNT,
          first: 2,
          after: cursor,
        });
      },
      next(result) {
        if (result.data?.node.__typename !== "Organization") {
          throw "invariant violated";
        }
        return result.data.node?.locations.pageInfo;
      },
    })) {
      expect(page.errors).toBeFalsy();
      i++;
    }
    expect(i).toBe(3); // 6 total, 2 per page
  });

  test("search", async () => {
    const result = await execute(schema, ListLocationsTestDocument, {
      account: ACCOUNT,
      search: {
        active: true,
        isSite: true,
      },
    });
    expect(result.data?.node.__typename).toBe("Organization");
    if (result.data?.node.__typename === "Organization") {
      expect(result.data.node.locations.totalCount).toBe(1);
    }
  });

  beforeAll(async () => {
    const logs = await sql<{ op: string; id: string }[]>`
      select *
      from
          runtime.create_demo(
              customer_name := 'Frozen Tendy Factory',
              admins := (
                  select array_agg(workeruuid)
                  from public.worker
                  where workerfullname in (
                      'Jerry Garcia',
                      'Mike Heavner',
                      'Will Ruggiano',
                      'Will Twait'
                  )
              ),
              modified_by := 895
          )
      ;
    `;
    // we get customer uuid back in the first row
    const row1 = logs.at(0);
    // but we can check the tag to be sure
    if (row1?.op?.trim() !== "+customer") {
      throw "setup failed to find customer";
    }
    ACCOUNT = encodeGlobalId({
      type: "organization", // bleh
      id: row1.id,
    });
  });

  afterAll(async () => {
    const { id } = decodeGlobalId(ACCOUNT);
    process.stdout.write("Cleaning up... ");
    const [row] = await sql<[{ ok: string }]>`
      select runtime.destroy_demo(${id}) as ok;
    `;
    console.log(row.ok);
  });
});
