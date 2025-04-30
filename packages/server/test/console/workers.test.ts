import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { setCurrentIdentity } from "@/auth";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import {
  cleanup,
  createTestContext,
  execute,
  findAndEncode,
  paginateQuery,
} from "@/test/prelude";
import {
  ListWorkersTestDocument,
  PaginateWorkersTestDocument,
} from "./workers.test.generated";

const ctx = await createTestContext();

describe("[console] workers", () => {
  let CUSTOMER: string;

  test("list", async () => {
    const result = await execute(ctx, schema, ListWorkersTestDocument, {
      account: CUSTOMER,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("paginate", async () => {
    let i = 0;
    for await (const page of paginateQuery({
      async execute(cursor) {
        return await execute(ctx, schema, PaginateWorkersTestDocument, {
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
    expect(i).toBe(2); // 7 total, 5 per page
  });

  test("search", async () => {
    const result = await execute(ctx, schema, ListWorkersTestDocument, {
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
      expect(result.data.node.workers.totalCount).toBe(2);
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
                        'Will Ruggiano'
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
