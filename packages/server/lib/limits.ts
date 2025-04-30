import { mapOrElse } from "./util";

export class Limits {
  constructor() {
    this.paginationDefaultLimit = mapOrElse(
      process.env.PAGINATION_DEFAULT_LIMIT,
      Number.parseInt,
      10,
    );
    this.paginationMaxLimit = mapOrElse(
      process.env.PAGINATION_MAX_LIMIT,
      Number.parseInt,
      100,
    );
    this.attachmentPaginationDefaultLimit = mapOrElse(
      process.env.ATTACHMENT_PAGINATION_DEFAULT_LIMIT,
      Number.parseInt,
      this.paginationDefaultLimit,
    );
    this.attachmentPaginationMaxLimit = mapOrElse(
      process.env.ATTACHMENT_PAGINATION_MAX_LIMIT,
      Number.parseInt,
      this.paginationMaxLimit,
    );
    this.fieldAttachmentPaginationDefaultLimit = mapOrElse(
      process.env.FIELD_ATTACHMENT_PAGINATION_DEFAULT_LIMIT,
      Number.parseInt,
      this.attachmentPaginationDefaultLimit,
    );
    this.fieldAttachmentPaginationMaxLimit = mapOrElse(
      process.env.FIELD_ATTACHMENT_PAGINATION_MAX_LIMIT,
      Number.parseInt,
      this.attachmentPaginationMaxLimit,
    );
  }

  //---------------------------------------
  // Default pagination limits.
  //---------------------------------------

  /**
   * For paginated operations, this limit defines the overridable default upper
   * bound on page size, i.e. the user can request larger pages (up to {@link paginationMaxLimit}).
   */
  readonly paginationDefaultLimit: number;
  /**
   * For paginated operations, this limit defines the upper bound on page size.
   */
  readonly paginationMaxLimit: number;

  //---------------------------------------
  // Attachment pagination limits.
  //---------------------------------------

  /**
   * Overridable default upper bound for attachment pagination.
   * @see {@link paginationDefaultLimit}
   */
  readonly attachmentPaginationDefaultLimit: number;
  /**
   * Hard upper bound for attachment pagination.
   * @see {@link paginationMaxLimit}
   */
  readonly attachmentPaginationMaxLimit: number;
  /**
   * Overridable default upper bound for field-level attachment pagination.
   * @see {@link attachmentPaginationDefaultLimit}
   */
  readonly fieldAttachmentPaginationDefaultLimit: number;
  /**
   * Hard upper bound for field-level attachment pagination.
   * @see {@link attachmentPaginationMaxLimit}
   */
  readonly fieldAttachmentPaginationMaxLimit: number;
}
