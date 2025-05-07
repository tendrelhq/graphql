import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import {
  type Customer,
  createTestContext,
  execute,
  paginateQuery,
} from "@/test/prelude";
import { assert, mapOrElse } from "@/util";
import { Faker, base, en } from "@faker-js/faker";
import { createCustomer } from "../app/runtime/prelude/canonical";
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
    expect(listQuery.data).toMatchSnapshot();
  });

  test("search", async () => {
    const listQuery = await execute(ctx, schema, ListLanguagesTestDocument, {
      customerId: CUSTOMER.id,
      search: {
        primary: true,
      },
    });
    expect(listQuery.errors).toBeFalsy();
    expect(listQuery.data?.node.__typename).toBe("Organization");
    if (listQuery.data?.node.__typename === "Organization") {
      expect(listQuery.data.node.languages.totalCount).toBe(2);
    }
  });

  test("add", async () => {
    const [{ id: languageId }] = await sql`
      select systaguuid as id
      from public.systag
      where systagparentid = 2 and systagtype = 'fr'
    `;

    const addMutation = await execute(ctx, schema, AddLanguageTestDocument, {
      customerId: CUSTOMER.id,
      languageId: languageId,
    });
    expect(addMutation.errors).toBeFalsy();
    expect(addMutation.data).toMatchSnapshot();

    const listQuery = await execute(ctx, schema, ListLanguagesTestDocument, {
      customerId: CUSTOMER.id,
    });
    expect(listQuery.errors).toBeFalsy();
    expect(listQuery.data).toMatchSnapshot();
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
        if (result.data?.node.__typename !== "Organization") {
          throw "invariant violated";
        }
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
      CUSTOMER = await createCustomer({ faker, seed }, ctx, sql);
      console.log("identity", ctx.auth.userId);
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
