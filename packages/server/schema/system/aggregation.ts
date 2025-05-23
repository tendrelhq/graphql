/** @gqlType */
export type Aggregate = {
  /**
   * The group, or bucket, that uniquely identifies this aggregate.
   * For example, this will be one of the `overType`s passed to `chainAgg`.
   *
   * @gqlField
   */
  group: string;

  /**
   * The computed aggregate value.
   *
   * Currently, this will always be a string value representing a duration in
   * seconds, e.g. "360" -> 360 seconds. `null` will be returned when no such
   * aggregate can be computed, e.g. "time in planned downtime" when no "planned
   * downtime" events exist. Note also that `null` will be returned if a
   * duration cannot be computed, e.g. because there is no end date.
   *
   * @gqlField
   */
  value: string | null;
};
