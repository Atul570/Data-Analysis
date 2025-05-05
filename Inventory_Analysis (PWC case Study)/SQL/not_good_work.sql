-- Analysis on Purchases slowor fast moving inventory
create table PurchasesAnalysis(
select inventoryid,
store,
brand,
receivingdate,
after_purchases,
quantity,
if(after_purchases is null , after_purchases,datediff(after_purchases,receivingdate)) as days_
from
(
SELECT 
    p.*,
    Lead(receivingdate) over(partition by inventoryid order by receivingdate) as after_purchases 
FROM
    purchases p) t
);

create index idx_inventoryid_purchasesanalysis on purchasesanalysis(inventoryid);

create temporary table purchasesanalysis_2(
with xyz as(
SELECT 
    inventoryid,
    COUNT(*) AS count_
FROM
    purchasesanalysis
GROUP BY inventoryid
ORDER BY count_),
xyz_2 as(
SELECT 
    *,
    CASE
        WHEN count_ <= 5 THEN 'Very Low'
        WHEN count_ <= 10 THEN 'Low'
        WHEN count_ <= 30 THEN 'Medium'
        WHEN count_ <= 60 THEN 'High'
        ELSE 'Very High'
    END AS activity_level
FROM
    xyz)
SELECT 
    p.*, activity_level
FROM
    Purchasesanalysis p
        JOIN
    xyz_2 x ON p.inventoryid = x.inventoryid);

with xyz_ as (
SELECT 
    activity_level, inventoryid, round(AVG(days_),2) as avg_days_next_order, AVG(quantity) as avg_quantity_ordered
FROM
    purchasesanalysis_2
GROUP BY activity_level , inventoryid)
select * ,
CASE
  -- Very High Activity
  WHEN activity_level = 'Very High' THEN 'Fast-Moving'

  -- High Activity
  WHEN activity_level = 'High' AND avg_days_next_order <= 12 THEN 'Fast-Moving'
  WHEN activity_level = 'High' AND avg_days_next_order > 12 THEN 'Medium-Moving'

  -- Medium Activity
  WHEN activity_level = 'Medium' AND avg_days_next_order <= 20 THEN 'Medium-Moving'
  WHEN activity_level = 'Medium' AND avg_days_next_order > 20 THEN 'Slow-Moving'

  -- Low Activity
  WHEN activity_level = 'Low' AND avg_days_next_order<= 30 THEN 'Medium-Moving'
  WHEN activity_level = 'Low' AND avg_days_next_order > 30 THEN 'Slow-Moving'

  -- Very Low Activity
  WHEN activity_level = 'Very Low' AND avg_days_next_order <= 15 THEN 'Medium-Moving'
  ELSE 'Slow-Moving'
END AS movement_category
from xyz_;

-- select activity_level  , min(avg_days_next_order), max(avg_days_next_order) from xyz_ group by activity_level;

create index idx_purchases_recivingdate on purchases(receivingdate);
select count(inventoryid) from (SELECT 
    inventoryid, datediff(MAX(receivingdate) , MIN(receivingdate)) as age_,
    sum(quantity) as unitPurchases,
    count(*) as times_,
    sum(case when month(salesdate)=1 then   1 else 0 end ) as jansold
FROM
    purchases
GROUP BY inventoryid
having 
times_ < 10
and
max(receivingdate) < DATE('2016-10-30')) t ;


-- -----------------------------------------------------------------------------------------------------
use pwc_casestudy;	
create temporary table inventorySeason as
(
SELECT 
    inventoryid,
    COUNT(*) AS total_sales_transactions,
    SUM(salesquantity) AS quantity_sold,
    sum(salesdollars) as total_sales,
    MIN(salesdate) AS first_sale_date,
    MAX(salesdate) AS last_sale_date,
    SUM(CASE WHEN MONTH(salesdate) = 1 THEN salesquantity ELSE 0 END) AS jan_sold,
    SUM(CASE WHEN MONTH(salesdate) = 2 THEN salesquantity ELSE 0 END) AS feb_sold,
    SUM(CASE WHEN MONTH(salesdate) = 3 THEN salesquantity ELSE 0 END) AS mar_sold,
    SUM(CASE WHEN MONTH(salesdate) = 4 THEN salesquantity ELSE 0 END) AS apr_sold,
    SUM(CASE WHEN MONTH(salesdate) = 5 THEN salesquantity ELSE 0 END) AS may_sold,
    SUM(CASE WHEN MONTH(salesdate) = 6 THEN salesquantity ELSE 0 END) AS jun_sold,
    SUM(CASE WHEN MONTH(salesdate) = 7 THEN salesquantity ELSE 0 END) AS jul_sold,
    SUM(CASE WHEN MONTH(salesdate) = 8 THEN salesquantity ELSE 0 END) AS aug_sold,
    SUM(CASE WHEN MONTH(salesdate) = 9 THEN salesquantity ELSE 0 END) AS sep_sold,
    SUM(CASE WHEN MONTH(salesdate) = 10 THEN salesquantity ELSE 0 END) AS oct_sold,
    SUM(CASE WHEN MONTH(salesdate) = 11 THEN salesquantity ELSE 0 END) AS nov_sold,
    SUM(CASE WHEN MONTH(salesdate) = 12 THEN salesquantity ELSE 0 END) AS dec_sold

FROM
    sales
GROUP BY 
    inventoryid
ORDER BY 
    quantity_sold DESC);
    
with A_inventorySeason as (
SELECT 
    i.*
FROM
    inventoryseason i
        JOIN
    abc_table a on i.inventoryid = a.inventoryid
WHERE
    category = 'A'),
temp as(
select * , datediff(last_sale_date,first_sale_date) as age_ from A_inventoryseason having age_ < 330 order by age_ )
SELECT 
    SUM(jan_sold) AS january_total_sold,
    SUM(feb_sold) AS february_total_sold,
    SUM(mar_sold) AS march_total_sold,
    SUM(apr_sold) AS april_total_sold,
    SUM(may_sold) AS may_total_sold,
    SUM(jun_sold) AS june_total_sold,
    SUM(jul_sold) AS july_total_sold,
    SUM(aug_sold) AS august_total_sold,
    SUM(sep_sold) AS september_total_sold,
    SUM(oct_sold) AS october_total_sold,
    SUM(nov_sold) AS november_total_sold,
    SUM(dec_sold) AS december_total_sold
FROM 
    temp;

with temp as(
SELECT 
    *, DATEDIFF(last_sale_date, first_sale_date) AS age_
FROM
    inventoryseason),
temp1 as(
select * ,
case
	when age_ = 0 then 'onedaysold'
    when age_ between 1 and 30 then '1 to 30'
    when  age_ between 31 and 150 then '30 to 150'
    when age_ between 151 and 330 then '151 to 330'
    when age_ > 330 then 'almost all year sold'
end as bucket
from temp)
SELECT 
    bucket, COUNT(*) as sales_count, SUM(total_sales), SUM(quantity_sold)
FROM
    temp1
GROUP BY bucket;


create temporary table A_catgoryitem(
with temp as(
SELECT 
    *, DATEDIFF(last_sale_date, first_sale_date) AS age_
FROM
    inventoryseason)
select * ,
case
	when age_ = 0 then 'onedaysold'
    when age_ between 1 and 30 then '1 to 30'
    when  age_ between 31 and 150 then '30 to 150'
    when age_ between 151 and 330 then '151 to 330'
    when age_ > 330 then 'almost all year sold'
end as bucket
from temp);

/* Below we analyzed  that total inventory of A category that is one day sold  ------------ and we calculated revenue of every month
and in  june there is highest revenue as compare to other months and in june there is   2434 inventory from which we sold product which 
genrated revenue 406,677.83 in which 1232 inventory dropped  which genrated revenue of 
*/ 
SELECT 
    MONTH(first_sale_date) as month_,
    COUNT(DISTINCT inventoryid) as total_inventory,
    SUM(quantity_sold) as quantity,
    sum(total_sales) as revenue
FROM
    one_day_sold_A_cat
WHERE
    age_ = 'onedaysold'
group by month(first_sale_date);

with temp as(
SELECT 
    a.*
FROM
    one_day_sold_A_cat a
        JOIN
    endinginventory e ON a.inventoryid = e.inventoryid
WHERE
    MONTH(first_sale_date) = 6
        AND bucket = 'onedaysold'
	order by quantity_sold
        limit 2434)
	select sum(quantity_sold) , sum(total_sales) from temp;
    
select * from one_day_sold_A_cat;