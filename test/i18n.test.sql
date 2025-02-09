-- noqa: disable=AM04,LT06
begin
;

set local client_min_messages to 'notice'
;
set local search_path to tap
;

select plan(3)
;

-- fmt: off
select results_eq(
    $$
        select t.*
        from
            public.customer c,
            i18n.add_language_to_customer(
                customer_id := c.customeruuid,
                language_code := 'en',
                modified_by := 895
            ) t
        where c.customerid = 0
    $$,
    $$
        values (
            'crl_5bb8c1db-6aef-4652-a716-85decd67c818'
        )
    $$
);
-- fmt: on

select is_empty($$
    select t.*
    from
        public.customer c,
        i18n.add_language_to_customer(
            customer_id := c.customeruuid,
            language_code := 'not a real language',
            modified_by := 895
        ) t
    where c.customerid = 0
$$)
;

select is_empty($$
    select t.*
    from i18n.add_language_to_customer(
        customer_id := 'not a real uuid',
        language_code := 'en',
        modified_by := 895
    ) t
$$)
;

select *
from finish()
;

rollback
;
