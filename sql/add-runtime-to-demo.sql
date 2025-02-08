begin
;

select t.*
from
    public.customer,
    runtime.add_demo_to_customer(
        customer_id := customer.customeruuid,
        language_type := 'en',
        modified_by := 895,
        timezone := 'America/Los_Angeles'
    ) as t
where customerid = 100
;

rollback
;
