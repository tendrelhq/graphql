
-- Type: FUNCTION ; Name: engine0.compute_rrule_next_occurrence(text,numeric,timestamp with time zone); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.compute_rrule_next_occurrence(freq text, interval_v numeric, dtstart timestamp with time zone)
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
declare
  freq_type text := case when freq = 'quarter' then 'month' else freq end;
  base_freq interval := format('1 %s', freq_type)::interval;
begin
  if freq = 'quarter' then
    base_freq := '3 month'::interval;
  end if;

  return dtstart + (base_freq / interval_v);
end $function$;


REVOKE ALL ON FUNCTION engine0.compute_rrule_next_occurrence(text,numeric,timestamp with time zone) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.compute_rrule_next_occurrence(text,numeric,timestamp with time zone) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.compute_rrule_next_occurrence(text,numeric,timestamp with time zone) TO tendreladmin WITH GRANT OPTION;
