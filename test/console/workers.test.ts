import { schema } from "@/schema/final";
import {
  cleanup,
  createTestContext,
  execute,
  findAndEncode,
  paginateQuery,
  setup,
} from "@/test/prelude";
import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import {
  ListWorkersTestDocument,
  PaginateWorkersTestDocument,
} from "./workers.test.generated";
import { setCurrentIdentity } from "@/auth";
import { sql } from "@/datasources/postgres";

const ctx = await createTestContext();

describe("[console] workers", () => {
  let CUSTOMER: string;

  test("list", async () => {
    const result = await execute(schema, ListWorkersTestDocument, {
      account: CUSTOMER,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("paginate", async () => {
    let i = 0;
    for await (const page of paginateQuery({
      async execute(cursor) {
        return await execute(schema, PaginateWorkersTestDocument, {
          account: CUSTOMER,
          first: 5,
          after: cursor,
        });
      },
      next(result) {
        if (result.data?.node.__typename !== "Organization") {
          throw "invariant violated";
        }
        return result.data.node?.workers.pageInfo;
      },
    })) {
      expect(page.errors).toBeFalsy();
      i++;
    }
    expect(i).toBe(3); // 12 total, 5 per page
  });

  test("search", async () => {
    const result = await execute(schema, ListWorkersTestDocument, {
      account: CUSTOMER,
      search: {
        active: true,
        user: {
          displayName: "will",
        },
      },
    });
    expect(result.errors).toBeFalsy();
    expect(result.data?.node.__typename).toBe("Organization");
    if (result.data?.node.__typename === "Organization") {
      expect(result.data.node.workers.totalCount).toBe(8);
    }
  });

  beforeAll(async () => {
    const logs = await sql.begin(async sql => {
      await setCurrentIdentity(sql, ctx);
      return await sql<{ op: string; id: string }[]>`
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
    });
    CUSTOMER = findAndEncode("customer", "organization", logs);
  });

  afterAll(async () => {
    await cleanup(CUSTOMER);
  });
});
