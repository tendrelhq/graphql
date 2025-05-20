import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import assert from "node:assert";
import { setCurrentIdentity } from "@/auth";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import {
  type Customer,
  createDefaultCustomer,
  createTestContext,
  execute,
  findAndEncode,
  paginateQuery,
} from "@/test/prelude";
import { mapOrElse } from "@/util";
import { Faker, base, en } from "@faker-js/faker";
import {
  CreateWorkerTestDocument,
  ListWorkersTestDocument,
  PaginateWorkersTestDocument,
} from "./workers.test.generated";

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

describe("[console] workers", () => {
  let CUSTOMER: Customer;

  test("list", async () => {
    const result = await execute(ctx, schema, ListWorkersTestDocument, {
      account: CUSTOMER.id,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchInlineSnapshot(`
      {
        "node": {
          "__typename": "Organization",
          "workers": {
            "__typename": "WorkerConnection",
            "edges": [
              {
                "__typename": "WorkerEdge",
                "node": {
                  "__typename": "Worker",
                  "active": {
                    "active": true,
                  },
                  "displayName": "Jerry Garcia",
                  "firstName": "Jerry",
                  "language": {
                    "code": "en",
                  },
                  "lastName": "Garcia",
                  "role": {
                    "type": "Admin",
                  },
                  "scanCode": "username1",
                },
              },
            ],
            "pageInfo": {
              "__typename": "PageInfo",
              "hasNextPage": false,
              "hasPreviousPage": false,
            },
            "totalCount": 1,
          },
        },
      }
    `);
  });

  // Kinda useless test right now since there is only the one worker created via
  // crud_customer_create :/
  test("paginate", async () => {
    let i = 0;
    for await (const page of paginateQuery({
      async execute(cursor) {
        return await execute(ctx, schema, PaginateWorkersTestDocument, {
          account: CUSTOMER.id,
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
    expect(i).toBe(1); // lmao.
  });

  test("search", async () => {
    const result = await execute(ctx, schema, ListWorkersTestDocument, {
      account: CUSTOMER.id,
      search: {
        active: true,
        user: {
          displayName: "jerry",
        },
      },
    });
    expect(result.errors).toBeFalsy();
    expect(result.data?.node.__typename).toBe("Organization");
    if (result.data?.node.__typename === "Organization") {
      expect(result.data.node.workers.totalCount).toBe(1);
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
