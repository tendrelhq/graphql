import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { schema } from "@/schema/final";
import { Task } from "@/schema/system/component/task";
import {
  cleanup,
  createTestContext,
  execute,
  findAndEncode,
  setup,
} from "@/test/prelude";
import { assertNonNull, map } from "@/util";
import { TestCopyFromDocument } from "./copyFrom.test.generated";

const ctx = await createTestContext();

describe("copyFrom", () => {
  let CUSTOMER: string;
  let TEMPLATE: Task;
  let INSTANCE: Task;

  test("when entity is a template", async () => {
    const result = await execute(ctx, schema, TestCopyFromDocument, {
      entity: TEMPLATE.id,
      options: {
        withStatus: "open",
      },
    });

    expect(result.errors).toBeFalsy();
    expect(result.data).toEqual({
      copyFrom: {
        __typename: "CopyFromPayload",
        edge: {
          __typename: "ChecklistEdge",
          node: {
            __typename: "Checklist",
            id: expect.any(String),
            name: {
              __typename: "DisplayName",
              name: {
                __typename: "DynamicString",
                value: "Run",
              },
            },
            status: {
              __typename: "ChecklistOpen",
            },
          },
        },
      },
    });

    // Check that the new instance's location is the same as the template's
    // site. This is part of the default (template) instantiation rules.
    const t = new Task({
      id: assertNonNull(result.data?.copyFrom.edge.node.id),
    });
    const p = await t.parent();
    expect(p).toBeTruthy();
  });

  test("when entity is an instance", async () => {
    const result = await execute(ctx, schema, TestCopyFromDocument, {
      entity: INSTANCE.id,
      options: {
        withStatus: "open",
      },
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toEqual({
      copyFrom: {
        __typename: "CopyFromPayload",
        edge: {
          __typename: "ChecklistEdge",
          node: {
            __typename: "Checklist",
            id: expect.any(String),
            name: {
              __typename: "DisplayName",
              name: {
                __typename: "DynamicString",
                value: "Run",
              },
            },
            status: {
              __typename: "ChecklistOpen",
            },
          },
        },
      },
    });

    // Check that the new instance's location is the same as the previous
    // instance's location. By default, when we create a new instance from an
    // existing instance, we instantiate the new instance at the same location
    // as the existing instance.
    const t = new Task({
      id: assertNonNull(result.data?.copyFrom.edge.node.id),
    });
    const p = await t.parent();
    expect(p).toBeTruthy();
    const p2 = await INSTANCE.parent();
    expect(p2).toBeTruthy();
    expect(p).toEqual(p2);
  });

  beforeAll(async () => {
    const logs = await setup(ctx);
    CUSTOMER = findAndEncode("customer", "organization", logs);
    TEMPLATE = map(
      findAndEncode("task", "worktemplate", logs),
      id => new Task({ id }),
    );
    INSTANCE = map(
      findAndEncode("instance", "workinstance", logs),
      id => new Task({ id }),
    );
  });

  afterAll(async () => {
    await cleanup(CUSTOMER);
  });
});
