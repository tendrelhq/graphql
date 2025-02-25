import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { decodeGlobalId } from "@/schema/system";
import { createTestContext, execute, findAndEncode } from "@/test/prelude";
import { map } from "@/util";
import { Location } from "../location";
import { TestCreateLocationDocument } from "./create.test.generated";

const ctx = await createTestContext();

describe("createLocation", () => {
  let CUSTOMER: string;
  let SITE: Location;

  test("only required inputs; parent == customer", async () => {
    const result = await execute(schema, TestCreateLocationDocument, {
      input: {
        category: "asdf",
        name: "test only required inputs",
        parent: CUSTOMER,
        timeZone: "America/Denver",
      },
    });
    expect(result).toMatchSnapshot();
  });

  test("with optional inputs", async () => {
    const result = await execute(schema, TestCreateLocationDocument, {
      input: {
        category: "asdf",
        name: "test optional inputs",
        parent: CUSTOMER,
        scanCode: "asdf", // <-- optional
        timeZone: "America/Denver",
      },
    });
    expect(result).toMatchSnapshot();
  });

  test("parent == location", async () => {
    const result = await execute(schema, TestCreateLocationDocument, {
      input: {
        category: "asdf",
        name: "test child location",
        parent: SITE.id,
        timeZone: "America/Denver",
      },
    });
    expect(result).toMatchSnapshot();
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
                  where workeridentityid = ${ctx.auth.userId}
              ),
              modified_by := 895
          )
      ;
    `;
    CUSTOMER = findAndEncode("customer", "organization", logs);
    SITE = map(
      findAndEncode("site", "location", logs),
      id => new Location({ id }, ctx),
    );
  });

  afterAll(async () => {
    const { id } = decodeGlobalId(CUSTOMER);
    process.stdout.write("Cleaning up... ");
    const [row] = await sql<[{ ok: string }]>`
      select runtime.destroy_demo(${id}) as ok;
    `;
    console.log(row.ok);
  });
});
