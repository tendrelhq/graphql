import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import { execute } from "@/test/prelude";
import { TestCreateLocationDocument } from "./create.test.generated";

describe.skipIf(!!process.env.CI)("createLocation", () => {
  let ACCOUNT: string; // customer

  test("only required inputs; parent == customer", async () => {
    const result = await execute(schema, TestCreateLocationDocument, {
      input: {
        category: "asdf",
        name: "ASDF",
        parent: ACCOUNT,
        timeZone: "America/Denver",
      },
    });
    expect(result).toMatchSnapshot();
  });

  test("with optional inputs", async () => {
    const result = await execute(schema, TestCreateLocationDocument, {
      input: {
        category: "asdf",
        name: "ASDF",
        parent: ACCOUNT,
        scanCode: "asdf", // <-- optional
        timeZone: "America/Denver",
      },
    });
    expect(result).toMatchSnapshot();
  });

  test("parent == location", async () => {
    const [parent] = await sql`
      select encode(('location:' || locationuuid)::bytea, 'base64') as id
      from public.location
      where locationcustomerid = (
          select customerid
          from public.customer
          where customeruuid = ${decodeGlobalId(ACCOUNT).id}
      )
      limit 1;
    `;
    const result = await execute(schema, TestCreateLocationDocument, {
      input: {
        category: "asdf",
        name: "ASDF",
        parent: parent.id,
        timeZone: "America/Denver",
      },
    });
    expect(result).toMatchSnapshot();
  });

  beforeAll(async () => {
    const [row] = await sql`
      select id
      from mft.create_customer('ASDF', 'en');
    `;
    ACCOUNT = encodeGlobalId({
      type: "organization",
      id: row.id,
    });
  });

  afterAll(async () => {
    process.env.X_TENDREL_USER = undefined;

    const { id } = decodeGlobalId(ACCOUNT);
    // useful for debugging tests:
    if (process.env.SKIP_LOCATION_CRUD_CLEANUP) {
      console.log(
        "Skipping clean up... don't forget to cleanup after yourself!",
      );
      console.debug(`select mft.destroy_demo(${id})`);
      return;
    }

    process.stdout.write("Cleaning up... ");
    const [row] = await sql<[{ ok: string }]>`
      select mft.destroy_demo(${id}) as ok;
    `;
    console.log(row.ok);
  });
});
