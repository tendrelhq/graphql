-- Revert graphql:engine0t from pg

BEGIN;

-- The following avoids 'notice' messages pertaining to cascading deletes.
set local client_min_messages = 'warning';

drop schema engine1 cascade;

COMMIT;
