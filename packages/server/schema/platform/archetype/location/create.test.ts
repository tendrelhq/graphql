import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import assert from "node:assert";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import {
  type Customer,
  createDefaultCustomer,
  createTestContext,
  execute,
} from "@/test/prelude";
import { mapOrElse } from "@/util";
import { Faker, base, en } from "@faker-js/faker";
import type { Location } from "../location";
import { TestCreateLocationDocument } from "./create.test.generated";

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

describe("createLocation", () => {
  let CUSTOMER: Customer;
  let SITE: Location;

  test("only required inputs; parent == customer", async () => {
    const result = await execute(ctx, schema, TestCreateLocationDocument, {
      input: {
        category: "asdf",
        name: "test only required inputs",
        parent: CUSTOMER.id,
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
        parent: CUSTOMER.id,
        scanCode: "asdf", // <-- optional
        timeZone: "America/Denver",
      },
    });
    expect(result).toMatchSnapshot();
  });

  /*
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
  */

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
