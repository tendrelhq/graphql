import { describe, expect, test } from "bun:test";
import makeAttachmentLoader from "./attachment";
import { encodeGlobalId } from "@/schema/system";

// biome-ignore lint/suspicious/noExplicitAny:
const makeLoader = () => makeAttachmentLoader({} as any);

process.env.ATTACHMENT_BUCKET = "tendrel-ruggiano-test-attachment-bucket";

describe.skipIf(!!process.env.CI)("attachment loader", () => {
  test("ok", async () => {
    const data = await makeLoader().byId.load(
      encodeGlobalId({
        type: "workpictureinstance",
        id: "ace41781-58df-452b-8525-d7f1c8130586",
      }),
    );
    expect(data).toMatchObject({
      id: expect.any(String),
      attachment: expect.stringMatching(
        /^https:\/\/tendrel-ruggiano-test-attachment-bucket/,
      ),
    });
  });

  test("not found", async () => {
    const p = makeLoader().byId.load(
      encodeGlobalId({
        type: "__test__",
        id: "1",
      }),
    );
    expect(p).rejects.toThrow("No Attachment for id '1'");
  });
});
