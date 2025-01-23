/**
 * A language tag in the format of a BCP 47 (RFC 5646) standard string.
 *
 * @gqlScalar
 * @specifiedBy https://www.rfc-editor.org/rfc/rfc5646.html
 */
export type Locale = string;

/**
 * Plain text content that has been (potentially) translated into different
 * languages as specified by the user's configuration.
 *
 * @gqlType
 */
export type DynamicString = {
  /** @gqlField */
  locale: Locale;
  /** @gqlField */
  value: string;
};

/** @gqlInput */
export type DynamicStringInput = {
  locale: Locale;
  value: string;
};
