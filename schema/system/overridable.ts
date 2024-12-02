/** @gqlType */
export type Overridable<T> = {
  /** @gqlField */
  override: Override<T>;
  /** @gqlField */
  value: T;
};

/** @gqlType */
export type Override<T> = {
  /** @gqlField */
  overriddenAt: string;
  /** @gqlField */
  overriddenBy: string;
  /** @gqlField */
  previousValue: T;
};
