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
  AddLanguageTestDocument,
  ListLanguagesTestDocument,
  PaginateLanguagesTestDocument,
} from "./languages.test.generated";

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

describe("[console] languages", () => {
  let CUSTOMER: Customer;

  test("list", async () => {
    const listQuery = await execute(ctx, schema, ListLanguagesTestDocument, {
      customerId: CUSTOMER.id,
    });
    expect(listQuery.errors).toBeFalsy();
    expect(listQuery.data).toMatchInlineSnapshot(`
      {
        "node": {
          "__typename": "Organization",
          "languages": {
            "__typename": "EnabledLanguageConnection",
            "edges": [
              {
                "__typename": "EnabledLanguageEdge",
                "node": {
                  "__typename": "EnabledLanguage",
                  "active": {
                    "active": true,
                  },
                  "language": {
                    "code": "en",
                  },
                  "primary": true,
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

  test("search", async () => {
    const listQuery = await execute(ctx, schema, ListLanguagesTestDocument, {
      customerId: CUSTOMER.id,
      search: {
        primary: true,
      },
    });
    expect(listQuery.errors).toBeFalsy();
    assert(listQuery.data?.node.__typename === "Organization");
    expect(listQuery.data.node.languages.totalCount).toBe(1);
  });

  test("add", async () => {
    const rows = await sql<{ id: string; code: string }[]>`
      select systaguuid as id, systagtype as code
      from public.systag
      where systagparentid = 2 and systagtype in ('es', 'fr')
      order by systagid
    `;
    for (const row of rows) {
      const addMutation = await execute(ctx, schema, AddLanguageTestDocument, {
        customerId: CUSTOMER.id,
        languageId: row.id,
      });
      expect(addMutation.errors).toBeFalsy();
      expect(addMutation.data).toMatchInlineSnapshot(`
        {
          "enableLanguage": {
            "__typename": "EnabledLanguageEdge",
            "node": {
              "__typename": "EnabledLanguage",
              "active": {
                "__typename": "ActivationStatus",
                "active": true,
              },
              "language": {
                "__typename": "Language",
                "code": "${row.code}",
              },
              "primary": false,
            },
          },
        }
      `);
    }

    const listQuery = await execute(ctx, schema, ListLanguagesTestDocument, {
      customerId: CUSTOMER.id,
    });
    expect(listQuery.errors).toBeFalsy();
    expect(listQuery.data).toMatchInlineSnapshot(`
      {
        "node": {
          "__typename": "Organization",
          "languages": {
            "__typename": "EnabledLanguageConnection",
            "edges": [
              {
                "__typename": "EnabledLanguageEdge",
                "node": {
                  "__typename": "EnabledLanguage",
                  "active": {
                    "active": true,
                  },
                  "language": {
                    "code": "en",
                  },
                  "primary": true,
                },
              },
              {
                "__typename": "EnabledLanguageEdge",
                "node": {
                  "__typename": "EnabledLanguage",
                  "active": {
                    "active": true,
                  },
                  "language": {
                    "code": "es",
                  },
                  "primary": false,
                },
              },
              {
                "__typename": "EnabledLanguageEdge",
                "node": {
                  "__typename": "EnabledLanguage",
                  "active": {
                    "active": true,
                  },
                  "language": {
                    "code": "fr",
                  },
                  "primary": false,
                },
              },
            ],
            "pageInfo": {
              "__typename": "PageInfo",
              "hasNextPage": false,
              "hasPreviousPage": false,
            },
            "totalCount": 3,
          },
        },
      }
    `);
  });

  test("paginate", async () => {
    let i = 0;
    for await (const page of paginateQuery({
      async execute(cursor) {
        return await execute(ctx, schema, PaginateLanguagesTestDocument, {
          customerId: CUSTOMER.id,
          first: 1,
          after: cursor,
        });
      },
      next(result) {
        assert(result.data?.node.__typename === "Organization");
        return result.data.node?.languages.pageInfo;
      },
    })) {
      expect(page.errors).toBeFalsy();
      i++;
    }
    expect(i).toBe(3); // 3 total, 1 per page
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
