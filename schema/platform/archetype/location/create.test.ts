import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import {
  cleanup,
  createTestContext,
  execute,
  findAndEncode,
} from "@/test/prelude";
import { map } from "@/util";
import { Location } from "../location";
import { TestCreateLocationDocument } from "./create.test.generated";

const ctx = await createTestContext();

describe("createLocation", () => {
  let CUSTOMER: string;
  let SITE: Location;

  test("only required inputs; parent == customer", async () => {
    const result = await execute(ctx, schema, TestCreateLocationDocument, {
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
    const result = await execute(ctx, schema, TestCreateLocationDocument, {
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
    const result = await execute(ctx, schema, TestCreateLocationDocument, {
      input: {
        category: "Runtime Location",
        name: "test child location",
        parent: SITE.id,
        timeZone: "America/Denver",
      },
    });
    expect(result).toMatchSnapshot();
    // Our expects aren't as comprehensive as we'd like here due to our messed
    // up return type for this mutation. You should see a log line:
    // > createLocation: engine.instantiate.count: 1
    // as a result of running this test.
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
      id => new Location({ id }),
    );
  });

  afterAll(async () => {
    await cleanup(CUSTOMER);
  });
});
