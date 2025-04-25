
-- Type: FUNCTION ; Name: auth.set_actor(text,text,boolean); Owner: tendreladmin

CREATE OR REPLACE FUNCTION auth.set_actor(actor_id text, actor_locale text, is_local boolean DEFAULT true)
 RETURNS TABLE(id text, locale text)
 LANGUAGE plpgsql
AS $function$
declare
  user_id bigint;
begin
  select workerid into user_id
  from public.worker
  where workeridentityid = actor_id;
  --
  if not found then
    raise exception 'unauthenticated';
    return;
  end if;

  return query
    with
        user_locale as (
            select systagtype as locale
            from public.systag
            where systagid = (
                select workerlanguageid
                from public.worker
                where workerid = user_id
            )
        ),

        request_locale as (
            select systagtype as locale
            from public.systag
            where systagparentid = 2 and systagtype = actor_locale
        )

    select
        set_config('user.id', actor_id, is_local) as id,
        set_config('user.locale', coalesce(r.locale, u.locale), is_local) as locale
    from user_locale u, request_locale r
  ;

  if not found then
    raise exception 'invalid locale: %', actor_locale;
  end if;

  return;
end $function$;


REVOKE ALL ON FUNCTION auth.set_actor(text,text,boolean) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION auth.set_actor(text,text,boolean) TO PUBLIC;
GRANT EXECUTE ON FUNCTION auth.set_actor(text,text,boolean) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION auth.set_actor(text,text,boolean) TO graphql;
