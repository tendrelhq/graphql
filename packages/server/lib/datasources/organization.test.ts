import {
  afterAll,
  afterEach,
  beforeAll,
  describe,
  expect,
  test,
} from "bun:test";
import assert from "node:assert";
import {
  type Customer,
  createDefaultCustomer,
  createTestContext,
} from "@/test/prelude";
import { mapOrElse } from "@/util";
import { Faker, base, en } from "@faker-js/faker";
import { sql } from "./postgres";

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

describe("organization loader", () => {
  // See beforeAll for initialization of these variables.
  let CUSTOMER: Customer;

  test("not paying", async () => {
    const data = await ctx.orm.organization.load(CUSTOMER._id);
    expect(data).toMatchObject({
      billingId: expect.any(String),
      billingType: "Test", // FIXME: use Keller's customer create.
      isPaying: false,
    });
  });

  test("still not paying - null billing id", async () => {
    await sql`
      update public.customer
      set customerexternalsystemid = systagid
      from public.systag
      where customeruuid = ${CUSTOMER._id} and systagtype = 'Tendrel';
    `;

    const data = await ctx.orm.organization.load(CUSTOMER._id);
    expect(data).toMatchObject({
      billingId: expect.any(String),
      billingType: "Tendrel",
      isPaying: false,
    });
  });

  test("still not paying - not stripe", async () => {
    await sql`
      update public.customer
      set customerexternalid = 'fake-for-testing'
      where customeruuid = ${CUSTOMER._id};
    `;

    const data = await ctx.orm.organization.load(CUSTOMER._id);
    expect(data).toMatchObject({
      billingId: "fake-for-testing",
      billingType: "Tendrel",
      isPaying: false,
    });
  });

  test("$$$", async () => {
    await sql`
      update public.customer
      set customerexternalsystemid = systagid
      from public.systag
      where customeruuid = ${CUSTOMER._id} and systagtype = 'Stripe';
    `;

    const data = await ctx.orm.organization.load(CUSTOMER._id);
    expect(data).toMatchObject({
      billingId: "fake-for-testing",
      billingType: "Stripe",
      isPaying: true,
    });
  });

  afterEach(() => ctx.orm.organization.clearAll());

  beforeAll(async () => {
    await sql.begin(async sql => {
      CUSTOMER = await createDefaultCustomer({ faker, seed }, ctx, sql);
    });
  });

  afterAll(async () => {
    // await cleanup(CUSTOMER.id);

    console.log(`
To reproduce this test:

  SEED=${seed} bun test organization.test --bail
    `);
  });
});
