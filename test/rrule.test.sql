-- noqa: disable=AM04,LT06
begin
;

set local client_min_messages to 'notice'
;
set local search_path to tap
;

select plan(11)
;

select
    is (
        util.compute_rrule_next_occurrence(
            freq := 'millisecond',
            interval_v := 1,
            dtstart := '2025-01-13 12:00:00.000+00'
        ),
        '2025-01-13 12:00:00.001+00'::timestamptz,
        '"one per millisecond" (or: "every millisecond")'
    )
;

select
    is (
        util.compute_rrule_next_occurrence(
            freq := 'millisecond',
            interval_v := (1 / 100.0),
            dtstart := '2025-01-13 12:00:00.000+00'
        ),
        '2025-01-13 12:00:00.100+00'::timestamptz,
        '"0.01 per millisecond" (or: "every 100 milliseconds")'
    )
;

select
    is (
        util.compute_rrule_next_occurrence(
            freq := 'second', interval_v := 2, dtstart := '2025-01-13 12:00:00.000+00'
        ),
        '2025-01-13 12:00:00.500+00'::timestamptz,
        '"twice per second" (or: "every 500 milliseconds")'
    )
;

select
    is (
        util.compute_rrule_next_occurrence(
            freq := 'minute', interval_v := 4, dtstart := '2025-01-13 12:00:00.000+00'
        ),
        '2025-01-13 12:00:15.000+00'::timestamptz,
        '"four per minute" (or: "every 15 seconds")'
    )
;

select
    is (
        util.compute_rrule_next_occurrence(
            freq := 'hour', interval_v := 3, dtstart := '2025-01-13 12:00:00.000+00'
        ),
        '2025-01-13 12:20:00.000+00'::timestamptz,
        '"three per hour" (or: "every 20 minutes")'
    )
;

select
    is (
        util.compute_rrule_next_occurrence(
            freq := 'day', interval_v := 6, dtstart := '2025-01-13 12:00:00.000+00'
        ),
        '2025-01-13 16:00:00.000+00'::timestamptz,
        '"six per day" (or: "every four hours")'
    )
;

select
    is (
        util.compute_rrule_next_occurrence(
            freq := 'week', interval_v := 7, dtstart := '2025-01-13 12:00:00.000+00'
        ),
        '2025-01-14 12:00:00.000+00'::timestamptz,
        '"7 per week" (or: "every day")'
    )
;

select
    is (
        util.compute_rrule_next_occurrence(
            freq := 'month', interval_v := 4, dtstart := '2025-01-13 12:00:00.000+00'
        ),
        -- Postgres's definition of a "month" is 30 days.
        -- Therefore: "four per month" is every 7.5 days.
        '2025-01-21 00:00:00.000+00'::timestamptz,
        '"four per month" (or: "every week" sort of)'
    )
;

select
    is (
        util.compute_rrule_next_occurrence(
            freq := 'quarter', interval_v := 3, dtstart := '2025-01-13 12:00:00.000+00'
        ),
        '2025-02-13 12:00:00.000+00'::timestamptz,
        '"three per quarter" (or: "every month")'
    )
;

select
    is (
        util.compute_rrule_next_occurrence(
            freq := 'year', interval_v := 3, dtstart := '2025-01-13 12:00:00.000+00'
        ),
        '2025-05-13 12:00:00.000+00'::timestamptz,
        '"three per year" (or: "every four months")'
    )
;

select
    is (
        util.compute_rrule_next_occurrence(
            freq := 'week',
            interval_v := 7,
            dtstart := '2025-01-13 12:00:00.000-07',
            tzid := 'America/Denver'
        ),
        '2025-01-14 12:00:00.000+00'::timestamptz
    )
;

select *
from finish()
;

rollback
;
