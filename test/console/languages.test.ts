import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import { cleanup, execute, paginateQuery } from "@/test/prelude";
import {
  AddLanguageTestDocument,
  ListLanguagesTestDocument,
  PaginateLanguagesTestDocument,
} from "./languages.test.generated";

describe("[console] languages", () => {
  let ACCOUNT: string; // customer

  test("list", async () => {
    const result = await execute(schema, ListLanguagesTestDocument, {
      account: ACCOUNT,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("search", async () => {
    const result = await execute(schema, ListLanguagesTestDocument, {
      account: ACCOUNT,
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
      account: ACCOUNT,
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
          account: ACCOUNT,
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
    await cleanup(id);
  });
});
