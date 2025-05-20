import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import assert from "node:assert";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import {
  type Customer,
  createDefaultCustomer,
  createTestContext,
  execute,
  paginateQuery,
} from "@/test/prelude";
import { mapOrElse } from "@/util";
import { Faker, base, en } from "@faker-js/faker";
import {
  ListLocationsTestDocument,
  PaginateLocationsTestDocument,
} from "./locations.test.generated";

const ctx = await createTestContext();

const seed = mapOrElse(
  process.env.SEED,
  seed => {
    const s = Number.parseInt(seed);
    assert(Number.isFinite(s), "invalid seed");
    return s;
  },
  Date.now(),
);
const faker = new Faker({ locale: [en, base], seed });

describe("[console] locations", () => {
  let CUSTOMER: Customer;

  test("list", async () => {
    const result = await execute(ctx, schema, ListLocationsTestDocument, {
      account: CUSTOMER.id,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchObject({
      node: {
        locations: {
          edges: [
            {
              node: {
                active: {
                  active: true,
                },
                geofence: null,
                name: {
                  value: "My Site",
                },
                parent: null,
                scanCode: null,
                site: {
                  name: {
                    value: "My Site",
                  },
                },
                timeZone: expect.any(String),
              },
            },
            {
              node: {
                active: {
                  active: true,
                },
                geofence: null,
                name: {
                  value: "My First Location",
                },
                parent: {
                  name: {
                    value: "My Site",
                  },
                },
                scanCode: null,
                site: {
                  name: {
                    value: "My Site",
                  },
                },
                timeZone: expect.any(String),
              },
            },
          ],
          pageInfo: {
            hasNextPage: false,
            // FIXME: this is broken...
            hasPreviousPage: true,
          },
          totalCount: 2,
        },
      },
    });
  });

  test("paginate", async () => {
    let i = 0;
    for await (const page of paginateQuery({
      async execute(cursor) {
        return await execute(ctx, schema, PaginateLocationsTestDocument, {
          account: CUSTOMER.id,
          first: 1,
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
    expect(i).toBe(2); // 2 total, 1 per page
  });

  test("search", async () => {
    const result = await execute(ctx, schema, ListLocationsTestDocument, {
      account: CUSTOMER.id,
      search: {
        active: true,
        isSite: true,
      },
    });
    expect(result.errors).toBeFalsy();
    expect(result.data?.node.__typename).toBe("Organization");
    if (result.data?.node.__typename === "Organization") {
      expect(result.data.node.locations.totalCount).toBe(1);
    }
  });

  beforeAll(async () => {
    await sql.begin(async sql => {
      CUSTOMER = await createDefaultCustomer({ faker, seed }, ctx, sql);
    });
  });

  afterAll(async () => {
    // await cleanup(CUSTOMER.id);

    console.log(`
To reproduce this test:

  SEED=${seed} bun test languages.test --bail
    `);
  });
});
