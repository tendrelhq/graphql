import { afterAll, beforeAll, describe, expect, test } from "bun:test";
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
  ListLocationsTestDocument,
  PaginateLocationsTestDocument,
} from "./locations.test.generated";

const ctx = await createTestContext();

describe("[console] locations", () => {
  let CUSTOMER: string;

  test("list", async () => {
    const result = await execute(ctx, schema, ListLocationsTestDocument, {
      account: CUSTOMER,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("paginate", async () => {
    let i = 0;
    for await (const page of paginateQuery({
      async execute(cursor) {
        return await execute(ctx, schema, PaginateLocationsTestDocument, {
          account: CUSTOMER,
          first: 2,
          after: cursor,
        });
      },
      next(result) {
        if (result.data?.node.__typename !== "Organization") {
          throw "invariant violated";
        }
        return result.data.node?.locations.pageInfo;
      },
    })) {
      expect(page.errors).toBeFalsy();
      i++;
    }
    expect(i).toBe(3); // 6 total, 2 per page
  });

  test("search", async () => {
    const result = await execute(ctx, schema, ListLocationsTestDocument, {
      account: CUSTOMER,
      search: {
        active: true,
        isSite: true,
      },
    });
    expect(result.errors).toBeFalsy();
    expect(result.data?.node.__typename).toBe("Organization");
    if (result.data?.node.__typename === "Organization") {
      expect(result.data.node.locations.totalCount).toBe(1);
    }
  });

  beforeAll(async () => {
    const logs = await setup(ctx);
    CUSTOMER = findAndEncode("customer", "organization", logs);
  });

  afterAll(async () => {
    await cleanup(CUSTOMER);
  });
});
