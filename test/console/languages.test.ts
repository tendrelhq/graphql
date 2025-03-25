import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import {
  cleanup,
  createTestContext,
  execute,
  findAndEncode,
  paginateQuery,
  setup,
} from "@/test/prelude";
import {
  AddLanguageTestDocument,
  ListLanguagesTestDocument,
  PaginateLanguagesTestDocument,
} from "./languages.test.generated";

const ctx = await createTestContext();

describe("[console] languages", () => {
  let CUSTOMER: string;

  test("list", async () => {
    const result = await execute(schema, ListLanguagesTestDocument, {
      account: CUSTOMER,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("search", async () => {
    const result = await execute(schema, ListLanguagesTestDocument, {
      account: CUSTOMER,
      search: {
        primary: true,
      },
    });
    expect(result.errors).toBeFalsy();
    expect(result.data?.node.__typename).toBe("Organization");
    if (result.data?.node.__typename === "Organization") {
      expect(result.data.node.languages.totalCount).toBe(1);
    }
  });

  test("add", async () => {
    const [{ id: languageId }] = await sql`
        select systaguuid as id
        from public.systag
        where systagparentid = 2 and systagtype = 'es'

    `;

    const result = await execute(schema, AddLanguageTestDocument, {
      account: CUSTOMER,
      languageId: languageId,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("paginate", async () => {
    let i = 0;
    for await (const page of paginateQuery({
      async execute(cursor) {
        return await execute(schema, PaginateLanguagesTestDocument, {
          account: CUSTOMER,
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
    expect(i).toBe(2); // 2 total, 1 per page
  });

  beforeAll(async () => {
    const logs = await setup(ctx);
    CUSTOMER = findAndEncode("customer", "organization", logs);
  });

  afterAll(async () => {
    await cleanup(CUSTOMER);
  });
});
