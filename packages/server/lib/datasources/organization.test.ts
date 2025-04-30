import {
  afterAll,
  afterEach,
  beforeAll,
  describe,
  expect,
  test,
} from "bun:test";
import { decodeGlobalId } from "@/schema/system";
import {
  cleanup,
  createTestContext,
  findAndEncode,
  setup,
} from "@/test/prelude";
import { sql } from "./postgres";

const ctx = await createTestContext();

describe("organization loader", () => {
  // See beforeAll for initialization of these variables.
  let CUSTOMER: string;

  test("not paying", async () => {
    const { id } = decodeGlobalId(CUSTOMER);
    const data = await ctx.orm.organization.load(id);
    expect(data).toMatchObject({
      billingId: null,
      billingType: null, // FIXME: use Keller's customer create.
      isPaying: false,
    });
  });

  test("still not paying - null billing id", async () => {
    const { id } = decodeGlobalId(CUSTOMER);
    await sql`
      update public.customer
      set customerexternalsystemid = systagid
      from public.systag
      where customeruuid = ${id} and systagtype = 'Tendrel';
    `;

    const data = await ctx.orm.organization.load(id);
    expect(data).toMatchObject({
      billingId: null,
      billingType: "Tendrel",
      isPaying: false,
    });
  });

  test("still not paying - not stripe", async () => {
    const { id } = decodeGlobalId(CUSTOMER);
    await sql`
      update public.customer
      set customerexternalid = 'fake-for-testing'
      where customeruuid = ${id};
    `;

    const data = await ctx.orm.organization.load(id);
    expect(data).toMatchObject({
      billingId: "fake-for-testing",
      billingType: "Tendrel",
      isPaying: false,
    });
  });

  test("$$$", async () => {
    const { id } = decodeGlobalId(CUSTOMER);
    await sql`
      update public.customer
      set customerexternalsystemid = systagid
      from public.systag
      where customeruuid = ${id} and systagtype = 'Stripe';
    `;

    const data = await ctx.orm.organization.load(id);
    expect(data).toMatchObject({
      billingId: "fake-for-testing",
      billingType: "Stripe",
      isPaying: true,
    });
  });

  afterEach(() => ctx.orm.organization.clearAll());

  beforeAll(async () => {
    const logs = await setup(ctx);
    CUSTOMER = findAndEncode("customer", "organization", logs);
  });

  afterAll(async () => {
    await cleanup(CUSTOMER);
  });
});
