describe superstore;
--total no of customer
select count(*)
from superstore;
--Sales and Profitability Analysis
select *
from superstore;
----------------------------------------
select sub_category,
    count(*) as total_orders,
    sum(quantity) as quantity_sold,
    round(sum(profit), 2) as profit
from superstore
group by sub_category
order by sum(profit) desc;
----------------------------------------------
select sum(
        case
            when total_profit <= 0 then 1
            else 0
        end
    ) as loss_making_city,
    sum(
        case
            when total_profit > 0 then 1
            else 0
        end
    ) as profit_making_city
from (
        select city,
            sum(profit) as total_profit
        from superstore
        group by city
    ) as t1;
----------------------------------------------
select state,
    city,
    sum(
        case
            when Profit <= 0 then 1
            else 0
        end
    ) as loss_making_orders,
    sum(
        case
            when Profit > 0 then 1
            else 0
        end
    ) as profit_mmaking_orders,
    count(*) as total_orders,
    format(
        sum(
            case
                when Profit < 0 then profit
                else 0
            end
        ),
        2
    ) as total_loss,
    format(
        sum(
            case
                when profit >= 0 then profit
                else 0
            end
        ),
        2
    ) as total_profit,
    FORMAT(sum(profit), 2) overall_profit
from superstore
group by state,
    City
order by sum(Profit);
------------------------------------------------------
select segment,
    count(*) as total_orders,
    round(sum(sales), 2) as total_sales,
    round(
        sum(
            case
                when profit <= 0 then profit
                else 0
            end
        ),
        2
    ) as total_loss,
    round(
        sum(
            case
                when profit > 0 then profit
                else 0
            end
        ),
        2
    ) as total_profit,
    round(sum(profit), 2) as overall_profit,
    round(avg(profit), 2) as average_profit
from superstore
group by segment;
------------------------------------------------
CREATE view temp as(
    select sub_category,
        product_name,
        sum(profit) as total_profit
    from superstore
    group by sub_category,
        product_name
);
select sub_category,
    sum(
        case
            when total_profit <= 0 then 1
            else 0
        end
    ) as loss_making_product,
    sum(
        case
            when total_profit > 0 then 1
            else 0
        end
    ) as profit_making_products
from temp
group by sub_category;
------------------------------------------------
create view temp2 as (
    select * from superstore where sub_category = 'Tables'
);

SELECT 
    (SUM((x - avg_x) * (y - avg_y)) / (COUNT(*) - 1)) / 
    (SQRT(SUM(POW(x - avg_x, 2)) / (COUNT(*) - 1)) * SQRT(SUM(POW(y - avg_y, 2)) / (COUNT(*) - 1))) AS correlation
FROM (select 
        discount as x,
        profit as y,
        (select avg(discount) from temp2) as avg_x,
        (select avg(profit) from temp2) as avg_y
        from temp2
     ) as subquery;
----------------------------------------------
create view temp3 as (
    select * from superstore where sub_category = 'Bookcases'
);

select segment , 
product_name , 
sum(case when profit <= 0 then 1 else 0 end ),
sum(case when profit >0 then 1 else 0 end),
sum(case when profit <= 0 then profit else 0 end ),
sum(case when profit > 0 then profit else 0 end),
sum(profit)
 from temp2  group by segment, product_name order by segment;

select segment , sum(profit),count(*) from temp3 group by segment;
----------------------------------------------
describe superstore;