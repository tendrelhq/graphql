-- Revert graphql:legacy0-compute-time-at-task from pg

BEGIN;

drop function if exists legacy0.compute_time_at_task;

COMMIT;
