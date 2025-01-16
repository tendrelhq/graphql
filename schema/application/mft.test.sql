begin
;

select *
from
    mft.create_demo(
        customer_name := 'Frozen Tendy Factory',
        admins := array[
            'worker_d3ebf472-606c-4d26-9a19-d99f187e9c92',
            'worker_a5d1d16f-4264-45e7-97c6-1ef534b8875f'
        ]
    )
;

rollback
;
