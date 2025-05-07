import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { Location } from "@/schema/platform/archetype/location";
import { decodeGlobalId } from "@/schema/system";
import { Task } from "@/schema/system/component/task";
import {
  cleanup,
  createTestContext,
  execute,
  findAndEncode,
  getFieldByName,
  setup,
} from "@/test/prelude";
import { map } from "@/util";
import { TestCreateTemplateConstraintDocument } from "./createTemplateConstraint.test.generated";

const ctx = await createTestContext();

describe("createTemplateConstraint", () => {
  let CUSTOMER: string;
  let TEMPLATE: Task;
  let LOCATION: Location;

  test("create a new constraint", async () => {
    const result = await execute(
      ctx,
      schema,
      TestCreateTemplateConstraintDocument,
      {
        template: TEMPLATE.id,
        location: LOCATION.id,
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data?.createTemplateConstraint).toMatchObject({
      constraint: {
        id: expect.any(String),
      },
      diagnostics: [],
      instantiations: [],
    });

    const [{ count }] = await sql`
      select count(*)
      from public.worktemplateconstraint
      where worktemplateconstraintcustomeruuid = ${decodeGlobalId(CUSTOMER).id}
    `;
    expect(count).toBe(1n);
  });

  test("operation is idempotent", async () => {
    const result = await execute(
      ctx,
      schema,
      TestCreateTemplateConstraintDocument,
      {
        template: TEMPLATE.id,
        location: LOCATION.id,
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data?.createTemplateConstraint).toMatchObject({
      constraint: {
        id: expect.any(String),
      },
      diagnostics: [],
      instantiations: [],
    });

    const [{ count }] = await sql`
      select count(*)
      from public.worktemplateconstraint
      where worktemplateconstraintcustomeruuid = ${decodeGlobalId(CUSTOMER).id}
    `;
    expect(count).toBe(1n);
  });

  test("request eager instantiation", async () => {
    const result = await execute(
      ctx,
      schema,
      TestCreateTemplateConstraintDocument,
      {
        template: TEMPLATE.id,
        location: LOCATION.id,
        options: {
          instantiate: {},
        },
      },
    );
    expect(
      result.data?.createTemplateConstraint?.instantiations,
    ).toMatchSnapshot();
  });

  test("request eager instantiation with field-level edits", async () => {
    const field = await getFieldByName(TEMPLATE, "Description");
    const result = await execute(
      ctx,
      schema,
      TestCreateTemplateConstraintDocument,
      {
        template: TEMPLATE.id,
        location: LOCATION.id,
        options: {
          instantiate: {
            fields: [
              {
                field: field.id,
                value: {
                  string: "First try?",
                },
                valueType: field.valueType,
              },
            ],
          },
        },
      },
    );
    expect(
      result.data?.createTemplateConstraint?.instantiations,
    ).toMatchSnapshot();
  });

  beforeAll(async () => {
    const logs = await setup(ctx);
    CUSTOMER = findAndEncode("customer", "organization", logs);
    TEMPLATE = map(
      findAndEncode("next", "worktemplate", logs),
      id => new Task({ id }),
    );
    LOCATION = map(
      findAndEncode("location", "location", logs),
      id => new Location({ id }),
    );

    // Delete all constraints. FIXME: don't create a Runtime customer every time.
    await sql`
      delete from public.worktemplateconstraint
      where worktemplateconstraintcustomeruuid = ${decodeGlobalId(CUSTOMER).id}
    `;
  });

  afterAll(async () => {
    await cleanup(CUSTOMER);
  });
});
