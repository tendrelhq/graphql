/** @gqlType */
export type Diagnostic = {
  __typename: "Diagnostic";

  /** @gqlField */
  code: DiagnosticKind;

  /** @gqlField */
  message?: string | null;
};

/** @gqlEnum */
export enum DiagnosticKind {
  // This feels wrong. Presumably this implies a no-op.
  candidate_change_discarded = "candidate_change_discarded",
  // This maybe also feels wrong.
  candidate_choice_unavailable = "candidate_choice_unavailable",
  /**
   * Indicates that an operation expected a template type to be provided but
   * received an instance type.
   */
  expected_template_got_instance = "expected_template_got_instance",
  /**
   * Indicates that an operation expected an instance type to be provided but
   * received a template type.
   */
  expected_instance_got_template = "expected_instance_got_template",
  /*
   * Diagnostics of this kind indicate that a feature is being used that is not
   * yet available for public consumption.
   */
  feature_not_available = "feature_not_available",
  /**
   * Some operations accept an optional hash. This is misleading. You should
   * _always_ pass a hash for operations that accept them.
   */
  hash_is_required = "hash_is_required",
  /**
   * Diagnostics of this kind indicates that the requested operation is no longer
   * a valid operation due to a state change that has not yet been observed by
   * the client. Typically this is due to data staleness but may also occur for
   * the _loser_ of a race under concurrency.
   *
   * Hashes are opaque. Clients should not attempt to derive any meaning from them.
   */
  hash_mismatch_precludes_operation = "hash_mismatch_precludes_operation",
  /**
   * Indicates that an operation received a type that it is not allowed to
   * operate on.
   */
  invalid_type = "invalid_type",
  /**
   * When you operate on a StateMachine<T>, there must obviously be a state
   * machine to operate *on*. This diagnostic is returned when no such state
   * machine exists.
   */
  no_associated_fsm = "no_associated_fsm",
}
