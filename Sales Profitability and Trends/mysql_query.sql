describe superstore;
--total no of customer
select count(*)
from superstore;
--Sales and Profitability Analysis
select *
from superstore;
----------------------------------------
/*Sales and Profitability Analysis by subcategories*/
select sub_category,
    count(*) as total_orders,
    sum(quantity) as quantity_sold,
    round(sum(profit), 2) as profit
from superstore
group by sub_category
order by sum(profit) desc;
------------------------------------------------------
/*Subcategories vs Segments*/
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
/*In Each Sub_Category How Many Product Is Loss Making and Profit Making*/
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
/*Correlattion Between Discount And Tables*/
create view temp2 as (
    select *
    from superstore
    where sub_category = 'Tables'
);
SELECT (SUM((x - avg_x) * (y - avg_y)) / (COUNT(*) - 1)) / (
        SQRT(SUM(POW(x - avg_x, 2)) / (COUNT(*) - 1)) * SQRT(SUM(POW(y - avg_y, 2)) / (COUNT(*) - 1))
    ) AS correlation
FROM (
        select discount as x,
            profit as y,
            (
                select avg(discount)
                from temp2
            ) as avg_x,
            (
                select avg(profit)
                from temp2
            ) as avg_y
        from temp2
    ) as subquery;
----------------------------------------------
/*Total profit by segemnt and product*/
select segment,
    product_name,
    sum(
        case
            when profit <= 0 then 1
            else 0
        end
    ),
    sum(
        case
            when profit > 0 then 1
            else 0
        end
    ),
    sum(
        case
            when profit <= 0 then profit
            else 0
        end
    ),
    sum(
        case
            when profit > 0 then profit
            else 0
        end
    ),
    sum(profit)
from superstore s
where sub_category = 'Bookcases'
group by segment,
    product_name
order by segment;
select segment,
    sum(profit),
    count(*)
from temp3
group by segment;
----------------------------------------------
/*Customer And Profit*/
select customer_id,
    sum(profit)
from superstore
group by customer_id
order by sum(profit);


select *
from superstore
where customer_id = 'LF-17185';
select *
from superstore
where product_name like 'Cubify CubeX 3D%';
Select product_name,
    sum(profit)
from superstore
where sub_category = 'Machines'
group by product_name
order by sum(profit);
----------------------------------------------------
/*Discount Vs Total_Orders vs Total profit*/
create view temp3 as (
    Select discount,
        count(*) as total_orders,
        round(sum(profit), 2) as total_profit
    from superstore
    group by discount
    order by sum(profit)
);
select *
from temp3;
SELECT (SUM((x - avg_x) * (y - avg_y)) / (COUNT(*) - 1)) / (
        SQRT(SUM(POW(x - avg_x, 2)) / (COUNT(*) - 1)) * SQRT(SUM(POW(y - avg_y, 2)) / (COUNT(*) - 1))
    ) AS correlation
FROM (
        select discount as x,
            total_profit as y,
            (
                select avg(discount)
                from temp3
            ) as avg_x,
            (
                select avg(total_profit)
                from temp3
            ) as avg_y
        from temp3
    ) as subquery;
---------------------------------------------------
/*Profitability By city*/
WITH t1 AS (
    SELECT state,
        city,
        SUM(profit) AS total_profit
    FROM superstore
    GROUP BY state,
        city
),
t2 AS (
    SELECT state,
        SUM(
            CASE
                WHEN total_profit <= 0 THEN 1
                ELSE 0
            END
        ) AS city_in_loss,
        SUM(
            CASE
                WHEN total_profit > 0 THEN 1
                ELSE 0
            END
        ) AS city_in_gain
    FROM t1
    GROUP BY state
)
SELECT s.state,
    ROUND(
        SUM(
            CASE
                WHEN s.profit <= 0 THEN s.profit
                ELSE 0
            END
        ),
        2
    ) AS total_loss,
    ROUND(
        SUM(
            CASE
                WHEN s.profit > 0 THEN s.profit
                ELSE 0
            END
        ),
        2
    ) AS total_gain,
    ROUND(SUM(s.profit), 2) AS overall_profit,
    t2.city_in_loss,
    t2.city_in_gain
FROM superstore s
    JOIN t2 ON s.state = t2.state
GROUP BY s.state,
    t2.city_in_loss,
    t2.city_in_gain
ORDER BY overall_profit;
---------------------------------------------------
/*Profitability By state*/
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
---------------------------------------------------
/*What are the top 10 most profitable products? */
create view temp4 as (
    select *
    from superstore s
        join (
            Select product_name as pn
            from superstore
            group by product_name
            having sum(profit) > 3344
            order by sum(profit) desc
        ) s1 on s.product_name = s1.pn
);
select product_name,
    round(sum(profit), 2)
from temp4
group by product_name;
select count(*),
    sum(profit)
from temp4;
select category,
    count(*),
    sum(profit)
from temp4
group by category;
select discount,
    count(*) as total_orders,
    round(sum(profit), 2) total_profit
from temp4
group by discount
order by count(*);
select count(*)
from superstore;
select count(distinct product_name)
from superstore;
-------------------------------------------------------------