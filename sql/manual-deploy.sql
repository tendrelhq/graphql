--
-- Manual deployment script.
-- I use this to keep the production database up to date.
-- Run it with `psql -f sql/manual-deploy.sql`
--

\ir revert/engine0.sql
\ir revert/mft.sql
\ir revert/worker.sql
\ir revert/template.sql
\ir revert/location.sql
\ir revert/name.sql
\ir revert/udt.sql
\ir revert/inspect.sql

\ir deploy/inspect.sql
\ir deploy/udt.sql
\ir deploy/name.sql
\ir deploy/location.sql
\ir deploy/template.sql
\ir deploy/worker.sql
\ir deploy/mft.sql
\ir deploy/engine0.sql

\ir verify/inspect.sql
\ir verify/udt.sql
\ir verify/name.sql
\ir verify/location.sql
\ir verify/template.sql
\ir verify/worker.sql
\ir verify/mft.sql
\ir verify/engine0.sql
