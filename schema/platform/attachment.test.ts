import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { decodeGlobalId } from "@/schema/system";
import {
  createTestContext,
  execute,
  findAndEncode,
  getFieldByName,
} from "@/test/prelude";
import { assert, assertNonNull, map } from "@/util";
import type { Field } from "../system/component";
import { Task } from "../system/component/task";
import {
  TestAttachDocument,
  TestRefetchAttachmentDocument,
} from "./attachment.test.generated";

const ctx = await createTestContext();

const FAKE_S3_URI =
  "s3://tendrel-ruggiano-test-attachment-bucket/workpictureinstance/92286ae9-f9f0-4948-b9ed-128dd11ed95d/screenshot-2024-11-05T11:46:56-08:00.png";

describe.skipIf(!!process.env.CI)("attach", () => {
  let CUSTOMER: string;
  let INSTANCE: Task;
  let FIELD: Field;

  test("to an instance", async () => {
    const result = await execute(schema, TestAttachDocument, {
      entity: INSTANCE.id,
      urls: [FAKE_S3_URI, FAKE_S3_URI],
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchObject({
      attach: [
        {
          node: {
            attachedBy: {
              displayName: "Jerry Garcia",
            },
            attachedOn: {
              epochMilliseconds: expect.any(String),
            },
            attachment: expect.any(String),
          },
        },
        {
          node: {
            attachedBy: {
              displayName: "Jerry Garcia",
            },
            attachedOn: {
              epochMilliseconds: expect.any(String),
            },
            attachment: expect.any(String),
          },
        },
      ],
    });

    const node = assertNonNull(result.data?.attach?.at(0)?.node);
    // Test refetch of a entity-level attachment:
    const refetch = await execute(schema, TestRefetchAttachmentDocument, {
      node: node.id,
    });
    expect(refetch.errors).toBeFalsy();
    expect(refetch.data?.node).toMatchObject({
      id: node.id,
      attachedBy: {
        displayName: "Jerry Garcia",
      },
      attachedOn: {
        epochMilliseconds: node.attachedOn?.epochMilliseconds,
      },
    });
  });

  test("to a result", async () => {
    const result = await execute(schema, TestAttachDocument, {
      entity: FIELD.id,
      urls: [FAKE_S3_URI],
    });
    expect(result.errors).toBeFalsy();
    expect(result).toMatchObject({
      data: {
        attach: [
          {
            node: {
              attachedBy: {
                displayName: "Jerry Garcia",
              },
              attachedOn: {
                epochMilliseconds: expect.any(String),
              },
              attachment: expect.any(String),
            },
          },
        ],
      },
    });

    const node = assertNonNull(result.data?.attach?.at(0)?.node);
    // Test refetch of a field-level attachment:
    const refetch = await execute(schema, TestRefetchAttachmentDocument, {
      node: node.id,
    });
    expect(refetch.errors).toBeFalsy();
    expect(refetch.data?.node).toMatchObject({
      id: node.id,
      attachedBy: {
        displayName: "Jerry Garcia",
      },
      attachedOn: {
        epochMilliseconds: node.attachedOn?.epochMilliseconds,
      },
    });
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
      id => new Task({ id }, ctx),
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
