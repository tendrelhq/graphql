-- Verify graphql:legacy0-compute-time-at-task on pg

BEGIN;

select pg_catalog.has_function_privilege('legacy0.compute_time_at_task'::regproc, 'execute');

ROLLBACK;
