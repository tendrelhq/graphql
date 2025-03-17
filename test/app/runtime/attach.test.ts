import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { decodeGlobalId } from "@/schema/system";
import type { Field } from "@/schema/system/component";
import { Task } from "@/schema/system/component/task";
import {
  createTestContext,
  execute,
  findAndEncode,
  getFieldByName,
  paginateQuery,
} from "@/test/prelude";
import { assert, assertNonNull, map } from "@/util";
import type { ID } from "grats";
import {
  TestAttachDocument,
  TestGetTaskWithAttachmentsDocument,
  TestGetTaskWithFieldAttachmentsDocument,
  TestPaginateAttachmentsDocument,
} from "./attach.test.generated";

const ctx = await createTestContext();

const FAKE_S3_URI =
  "s3://tendrel-ruggiano-test-attachment-bucket/workpictureinstance/92286ae9-f9f0-4948-b9ed-128dd11ed95d/screenshot-2024-11-05T11:46:56-08:00.png";
const SKIP = !process.env.ATTACHMENT_BUCKET;

describe("[app/runtime] attach", () => {
  let CUSTOMER: string;
  let INSTANCE: Task;
  let FIELD: Field;

  test("no attachments", async () => {
    const result = await execute(schema, TestGetTaskWithAttachmentsDocument, {
      nodeId: INSTANCE.id,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchObject({
      node: {
        attachments: {
          edges: [],
        },
      },
    });
  });

  test.skipIf(SKIP)("add, list, repeat (4x)", async () => {
    for (let i = 0; i < 4; i++) {
      const add = await execute(schema, TestAttachDocument, {
        attachment: FAKE_S3_URI,
        node: INSTANCE.id,
      });
      expect(add.errors).toBeFalsy();
      expect(add.data?.attach).toHaveLength(1);

      const task = await execute(schema, TestGetTaskWithAttachmentsDocument, {
        nodeId: INSTANCE.id,
      });
      expect(task.errors).toBeFalsy();
      if (task.data?.node.__typename === "Task") {
        expect(task.data.node.attachments?.totalCount).toBe(i + 1);
        expect(task.data.node.attachments).toMatchObject({
          edges: new Array(i + 1).fill({
            node: expect.objectContaining({
              attachedBy: {
                displayName: "Jerry Garcia",
              },
              attachment: expect.any(String),
            }),
          }),
          pageInfo: {
            hasNextPage: false,
            hasPreviousPage: false,
          },
        });
      }
    }
  });

  test.skipIf(SKIP)("attach to a field", async () => {
    const add = await execute(schema, TestAttachDocument, {
      attachment: FAKE_S3_URI,
      node: FIELD.id,
    });
    expect(add.errors).toBeFalsy();
    expect(add.data?.attach).toHaveLength(1);

    const result = await execute(
      schema,
      TestGetTaskWithFieldAttachmentsDocument,
      {
        nodeId: INSTANCE.id,
      },
    );
    expect(result.errors).toBeFalsy();
    if (result.data?.node.__typename === "Task") {
      const f = result.data.node.fields?.edges?.find(e =>
        e.node?.attachments?.edges?.some(() => true),
      );
      expect(f).toBeDefined();
      expect(f?.node?.attachments).toMatchObject({
        edges: [
          {
            node: expect.objectContaining({
              attachedBy: {
                displayName: "Jerry Garcia",
              },
              attachment: expect.any(String),
            }),
          },
        ],
        pageInfo: {
          hasNextPage: false,
          hasPreviousPage: false,
        },
        totalCount: 1,
      });
    }
  });

  test.skipIf(SKIP)("paginate", async () => {
    const seen = new Set<ID>();
    for await (const page of paginateQuery({
      async execute(cursor) {
        return await execute(schema, TestPaginateAttachmentsDocument, {
          nodeId: INSTANCE.id,
          first: 1,
          after: cursor,
        });
      },
      next(result) {
        if (result.data?.node.__typename !== "Task") {
          throw "invariant violated";
        }
        for (const a of result.data.node.attachments?.edges ?? []) {
          // biome-ignore lint/style/noNonNullAssertion:
          const id = a.node!.id;
          assert(!seen.has(id));
          seen.add(id);
        }
        return assertNonNull(result.data.node?.attachments?.pageInfo);
      },
    })) {
      expect(page.errors).toBeFalsy();
    }
    expect(seen.size).toBe(4);
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
    INSTANCE = map(
      findAndEncode("instance", "workinstance", logs),
      id => new Task({ id }),
    );
    FIELD = await getFieldByName(INSTANCE, "Comments");
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
