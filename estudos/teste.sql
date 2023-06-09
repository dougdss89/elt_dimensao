with pair as (

    select x, y,
        row_number() over (order by x) as rn
    from functions
)
select
    distinct(p1.x),
    p1.y
from pair as p1
    inner join
    pair as p2
on p1.x = p2.y
and p1.y = p2.x
where p1.rn <> p2.rn
and p1.x <= p1.y
order by p1.x asc;
