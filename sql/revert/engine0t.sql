-- Revert graphql:engine0t from pg

BEGIN;

-- The following avoids 'notice' messages pertaining to cascading deletes.
set local client_min_messages = 'warning';

drop function engine0t.on_field_published;

drop schema engine0t cascade;

COMMIT;
