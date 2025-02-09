import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import { execute } from "@/test/prelude";
import { TestCreateLocationDocument } from "./create.test.generated";

process.env.X_TENDREL_USER = "";

describe.skip("createLocation", () => {
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
    process.env.X_TENDREL_USER = "user_2iADtxE5UonU4KO5lphsG59bkR9";

    const [row] = await sql`
      select id
      from mft.create_customer(
          customer_name := 'ASDF',
          language_type := 'en',
          modified_by := 895
      );
    `;
    ACCOUNT = encodeGlobalId({
      type: "organization",
      id: row.id,
    });

    // We also need to create a worker for our test :/
    await sql`
      select 1
      from
          public.worker,
          util.create_worker(
              customer_id := ${row.id},
              user_id := workeruuid,
              user_role := 'Admin',
              modified_by := 895
          )
      where workeridentityid = ${process.env.X_TENDREL_USER}
    `;
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
