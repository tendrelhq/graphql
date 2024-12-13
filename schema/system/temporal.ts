/** @gqlType */
export type Timestamp = {
  /** @gqlField */
  epochMilliseconds: string;
  /** @gqlField */
  timeZone: string;
};

/** @gqlInput */
export type TimestampInput = {
  epochMilliseconds: string;
  timeZone?: string | null;
};
