begin
;

drop index temp_wtc_idx;

create unique index temp_wtc_with_result_idx on public.worktemplateconstraint (
    worktemplateconstraintcustomerid,
    worktemplateconstrainttemplateid,
    worktemplateconstraintresultid,
    worktemplateconstraintconstrainedtypeid,
    worktemplateconstraintconstraintid
) where worktemplateconstraintresultid is not null;

create unique index temp_wtc_without_result_idx on public.worktemplateconstraint (
    worktemplateconstraintcustomerid,
    worktemplateconstrainttemplateid,
    worktemplateconstraintconstrainedtypeid,
    worktemplateconstraintconstraintid
) where worktemplateconstraintresultid is null;

commit
;
