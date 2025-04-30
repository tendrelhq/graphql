import { describe, expect, test } from "bun:test";
import { env } from "@/test/prelude";
import { Limits } from "./limits";

describe("limits", () => {
  test("defaults", () => {
    expect(new Limits()).toMatchObject({
      paginationDefaultLimit: 10,
      paginationMaxLimit: 100,
      attachmentPaginationDefaultLimit: 10,
      attachmentPaginationMaxLimit: 100,
      fieldAttachmentPaginationDefaultLimit: 10,
      fieldAttachmentPaginationMaxLimit: 100,
    });
  });

  test("overrides", () => {
    using _0 = env("PAGINATION_DEFAULT_LIMIT", 0);
    using _1 = env("PAGINATION_MAX_LIMIT", 1);
    using _2 = env("ATTACHMENT_PAGINATION_DEFAULT_LIMIT", 2);
    using _3 = env("ATTACHMENT_PAGINATION_MAX_LIMIT", 3);
    using _4 = env("FIELD_ATTACHMENT_PAGINATION_DEFAULT_LIMIT", 4);
    using _5 = env("FIELD_ATTACHMENT_PAGINATION_MAX_LIMIT", 5);

    expect(new Limits()).toMatchObject({
      paginationDefaultLimit: 0,
      paginationMaxLimit: 1,
      attachmentPaginationDefaultLimit: 2,
      attachmentPaginationMaxLimit: 3,
      fieldAttachmentPaginationDefaultLimit: 4,
      fieldAttachmentPaginationMaxLimit: 5,
    });
  });
});
