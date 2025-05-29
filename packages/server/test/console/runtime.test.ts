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
import { assertNonNull, mapOrElse } from "@/util";
import { Faker, base, en } from "@faker-js/faker";
import {
  TestAddFieldDocument,
  TestDeleteFieldDocument,
  TestRuntimeDocument,
} from "./runtime.test.generated";

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

describe("[console] runtime", () => {
  let CUSTOMER: Customer;

  test("add fields", async () => {
    const templateQuery = await execute(ctx, schema, TestRuntimeDocument, {
      owner: CUSTOMER.id,
      type: ["Batch"],
    });
    expect(templateQuery.errors).toBeFalsy();
    expect(templateQuery.data?.templates?.totalCount).toBe(1);
    const template = assertNonNull(
      templateQuery.data?.templates?.edges?.at(0)?.node?.asTask,
    );

    const mutation0 = await execute(ctx, schema, TestAddFieldDocument, {
      node: template.id,
      fields: [], // Should have no effect.
    });
    expect(mutation0.errors).toBeFalsy();
    expect(mutation0.data?.addFields).toEqual(template);

    const mutation1 = await execute(ctx, schema, TestAddFieldDocument, {
      node: template.id,
      fields: [
        {
          name: "Foo",
          type: "string",
          description: "This is the foo field",
          order: 100,
        },
        {
          name: "Bar",
          type: "boolean",
          description: "This is the bar field",
          order: 99,
          value: {
            boolean: false,
          },
        },
        {
          name: "Baz",
          type: "number",
          description: "This is the baz field",
          order: 98,
          isDraft: true,
        },
      ],
      includeDraftFields: true,
    });
    expect(mutation1.errors).toBeFalsy();
    expect(mutation1.data?.addFields?.fields).toMatchInlineSnapshot(`
      {
        "edges": [
          {
            "node": {
              "description": null,
              "name": {
                "value": "Customer",
              },
              "value": {
                "__typename": "StringValue",
                "string": null,
              },
              "valueType": "string",
            },
          },
          {
            "node": {
              "description": null,
              "name": {
                "value": "Product Name",
              },
              "value": {
                "__typename": "StringValue",
                "string": null,
              },
              "valueType": "string",
            },
          },
          {
            "node": {
              "description": null,
              "name": {
                "value": "SKU",
              },
              "value": {
                "__typename": "StringValue",
                "string": null,
              },
              "valueType": "string",
            },
          },
          {
            "node": {
              "description": {
                "value": "This is the baz field",
              },
              "name": {
                "value": "Baz",
              },
              "value": {
                "__typename": "NumberValue",
                "number": null,
              },
              "valueType": "number",
            },
          },
          {
            "node": {
              "description": {
                "value": "This is the bar field",
              },
              "name": {
                "value": "Bar",
              },
              "value": {
                "__typename": "BooleanValue",
                "boolean": false,
              },
              "valueType": "boolean",
            },
          },
          {
            "node": {
              "description": {
                "value": "This is the foo field",
              },
              "name": {
                "value": "Foo",
              },
              "value": {
                "__typename": "StringValue",
                "string": null,
              },
              "valueType": "string",
            },
          },
        ],
        "totalCount": 6,
      }
    `);
  });

  test("delete fields", async () => {
    const query0 = await execute(ctx, schema, TestRuntimeDocument, {
      owner: CUSTOMER.id,
      type: ["Batch"],
      includeFieldIds: true,
    });
    expect(query0.errors).toBeFalsy();
    const fields = assertNonNull(
      query0.data?.templates?.edges?.at(0)?.node?.asTask?.fields?.edges,
    );

    for (const field of fields) {
      const m = await execute(ctx, schema, TestDeleteFieldDocument, {
        field: assertNonNull(field.node?.id),
      });
      expect(m.errors).toBeFalsy();
    }

    const query1 = await execute(ctx, schema, TestRuntimeDocument, {
      owner: CUSTOMER.id,
      type: ["Batch"],
      includeFieldIds: true,
    });
    expect(query1.errors).toBeFalsy();
    expect(
      query1.data?.templates?.edges?.at(0)?.node?.asTask?.fields?.totalCount,
    ).toBe(0);
  });

  beforeAll(async () => {
    await sql.begin(async sql => {
      CUSTOMER = await createDefaultCustomer({ faker, seed }, ctx, sql);
    });
  });

  afterAll(async () => {
    // await cleanup(CUSTOMER.id);

    console.log(`
To reproduce this test:

  SEED=${seed} bun test runtime.test --bail
    `);
  });
});
