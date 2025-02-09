import { describe, expect, test } from "bun:test";
import { schema } from "@/schema/final";
import { encodeGlobalId } from "@/schema/system";
import { execute } from "@/test/prelude";
import { TestAttachDocument } from "./attach.test.generated";

const ENTITY =
  "d29ya2luc3RhbmNlOndvcmstaW5zdGFuY2VfOWNkYmE2ZDQtMDA1Yi00M2Y3LWI4NDMtMzA5ZDI4MjQ0YWMw";
const S3URI =
  "s3://tendrel-ruggiano-test-attachment-bucket/workpictureinstance/92286ae9-f9f0-4948-b9ed-128dd11ed95d/screenshot-2024-11-05T11:46:56-08:00.png";

describe.skip("attach", () => {
  test("to an instance", async () => {
    const result = await execute(schema, TestAttachDocument, {
      entity: ENTITY,
      urls: [S3URI, S3URI],
    });
    expect(result.errors).toBeFalsy();
    expect(result).toMatchObject({
      data: {
        attach: [
          {
            node: {
              attachedBy: {
                displayName: "Will Ruggiano",
              },
              attachedOn: {
                epochMilliseconds: expect.any(String),
              },
            },
          },
          {
            node: {
              attachedBy: {
                displayName: "Will Ruggiano",
              },
              attachedOn: {
                epochMilliseconds: expect.any(String),
              },
            },
          },
        ],
      },
    });
  });

  test("to a result", async () => {
    const result = await execute(schema, TestAttachDocument, {
      entity: encodeGlobalId({
        type: "workresultinstance",
        id: "work-instance_93c61cb5-e5ec-43e1-8777-d9f6e930e6b0",
        suffix: "work-result_fa536e61-2e9f-480c-b815-5cb1ec0a0f79",
      }),
      urls: [S3URI],
    });
    expect(result.errors).toBeFalsy();
    expect(result).toMatchObject({
      data: {
        attach: [
          {
            node: {
              attachedBy: {
                displayName: "Will Ruggiano",
              },
              attachedOn: {
                epochMilliseconds: expect.any(String),
              },
            },
          },
        ],
      },
    });
  });
});
