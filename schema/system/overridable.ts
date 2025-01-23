/** @gqlType */
export type Overridable<T> = {
  /** @gqlField */
  override?: Override<T> | null;
  /** @gqlField */
  value: T;
};

/** @gqlType */
export type Override<T> = {
  /** @gqlField */
  overriddenAt?: string | null;
  /** @gqlField */
  overriddenBy?: string | null;
  /** @gqlField */
  previousValue: T;
};
