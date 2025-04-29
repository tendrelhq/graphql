-- Deploy graphql:workinstancenameid to pg

BEGIN;

set local client_min_messages to 'warning';

alter table public.workinstance
add column if not exists workinstancenameid text
  references public.languagemaster(languagemasteruuid);

COMMIT;
