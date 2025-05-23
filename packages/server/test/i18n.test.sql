begin;
set local client_min_messages to 'notice';
set local search_path to tap;

select plan(8);

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
$$);

select is_empty($$
    select t.*
    from i18n.add_language_to_customer(
        customer_id := 'not a real uuid',
        language_code := 'en',
        modified_by := 895
    ) t
$$);

select results_eq(
  $$
    select *
    from _api.parse_accept_language(null::text)
  $$,
  $$
    values (
        'en',
        1.0::float
    )
  $$
);

select results_eq(
  $$
    select *
    from _api.parse_accept_language('')
  $$,
  $$
    values (
        'en',
        1.0::float
    )
  $$
);

select results_eq(
  $$
    select *
    from _api.parse_accept_language('en-US')
  $$,
  $$
    values (
        'en-us',
        1.0::float
    )
  $$
);

select results_eq(
  $$
    select *
    from _api.parse_accept_language('en-US;q=0.9')
  $$,
  $$
    values (
        'en-us',
        0.9::float
    )
  $$
);

select results_eq(
  $$
    select *
    from _api.parse_accept_language('en-US,en;q=0.9,fr;q=0.8,de;q=0.7')
    order by quality desc
  $$,
  $$
    values
      ('en-us', 1.0::float),
      ('en', 0.9),
      ('fr', 0.8),
      ('de', 0.7)
  $$
);

select * from finish();
rollback;
