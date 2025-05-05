set @totalAmount = (select sum(dollars + freight) from vendorinvoices);
SELECT 
    vendorNumber,
    vendorName,
    SUM(dollars + Freight) AS totalAmount,
    round((SUM(dollars + Freight)/@totalAmount)*100,2) as '%_ofTotalSales',
    sum(quantity) as totalQuantity,
    min(dollars+Freight) min_purchases, 
    max(dollars+Freight) as Maximum_purchases,
    round(Avg(dollars + freight),2)  as Average_purchases,
    count(*) as count_of_purcheases
FROM
    vendorinvoices
GROUP BY vendorNumber,VendorName order by totalAmount desc limit 26;

-- On both tables
CREATE INDEX idx_inventoryid_beginning ON beginninginventory (inventoryid);
create index idx_inventoryid_sales on sales (inventoryid);

-- 1
create table temp
    (SELECT 
        b.inventoryid
    FROM
        beginninginventory b
    LEFT JOIN sales p ON b.inventoryid = p.inventoryid
    WHERE
        p.inventoryid IS NULL);
-- 2
select * from purchases p join temp t on t.inventoryid = p.inventoryid  where p.inventoryid = '34_PITMERDEN_13557' order by p.inventoryid ; 

-- Abc Analysis:-

set @total_sales_ = (select sum(salesdollars) from sales);
create  table ABC_table as(
with inventory_sales As (
SELECT 
    inventoryid, 
    SUM(salesdollars) AS total_sales
FROM
    sales
GROUP BY inventoryid),
cumulative_sales as (
select * , 
	sum(total_sales)  over (order by total_sales desc) as cumulative_sales
from inventory_sales)
select *,
round(((cumulative_sales/@total_sales_)* 100),2) as percent_contribution,

case 
	when ((cumulative_sales/@total_sales_)* 100) <= 70 then 'A'
    when ((cumulative_sales/@total_sales_)* 100) <= 90 then 'B'
    Else 'C'
end as category
from cumulative_sales); 


set @count_ = (select count(*) from abc_table);
select @count_;
select category , round((count(inventoryid)/@count_) *100,2) from abc_table group by category;

SELECT 
    e.inventoryid
FROM
    purchases p
        JOIN
    (SELECT 
       count(*)
    FROM
        endinginventory e
    LEFT JOIN beginninginventory b ON e.inventoryid = b.inventoryid
    WHERE
        b.inventoryid IS NULL) t ON p.inventoryid = t.inventoryid ;
with xyz as (
SELECT 
       b.inventoryid
    FROM
        endinginventory e
    right JOIN beginginventory b ON e.inventoryid = b.inventoryid
    WHERE
        e.inventoryid IS NULL)
select count(*)  from  xyz x join (select b.inventoryid from beginginventory b left  join sales s on b.inventoryid = s.inventoryid where s.inventoryid is null) t on x.inventoryid = t.inventoryid;


-- Sales performance of dropped inventory
create table dropped_inventory as(
with t1 as (
SELECT 
    b.inventoryid
FROM
    beginginventory b
        LEFT JOIN
    endinginventory e ON b.inventoryid = e.inventoryid
WHERE
    e.inventoryid IS NULL)
select t.inventoryid,sum(salesdollars) as total_sales from t1 t join sales s on t.inventoryid = s.inventoryid group by t.inventoryid);

-- From which category dropped inventory Belong (In ABC category)
SELECT 
    *
FROM
    abc_table abc
        JOIN
    dropped_inventory d ON abc.inventoryid = d.inventoryid
WHERE
    abc.category = 'A'  order by cast(substring_index(abc.inventoryid,'_',-1) as unsigned);
    
-- Checking dropped inventory from 'A' Category shop Status
SELECT
	abc.inventoryid,
    cast(substring_index(abc.inventoryid,'_',1) as unsigned) as shop_dropped_inventory
FROM
    abc_table abc
        JOIN
    dropped_inventory d ON abc.inventoryid = d.inventoryid
WHERE
    abc.category = 'A'  order by shop_dropped_inventory;
 

with dropped_inventory_all as (
SELECT
	abc.inventoryid,
    cast(substring_index(abc.inventoryid,'_',1) as unsigned) as shop_dropped_inventory,
    cast(substring_index(abc.inventoryid,'_',-1) as unsigned) as brand
FROM
    abc_table abc
        JOIN
    dropped_inventory d ON abc.inventoryid = d.inventoryid
WHERE
    abc.category = 'A'  order by shop_dropped_inventory)
SELECT 
    brand, COUNT(DISTINCT shop_dropped_inventory) AS count_
FROM
    dropped_inventory_all
GROUP BY brand
ORDER BY count_;
-- Total revenue by A Class dropped inventory
select sum(salesdollars) from sales s join (
SELECT 
    d.inventoryid
FROM
    dropped_inventory d
        JOIN
    abc_table a ON d.inventoryid = a.inventoryid
WHERE
    abc.category = 'A') t on s.inventoryid = t.inventoryid; 

-- Total Revenue by B class dropped Inentory
select sum(salesdollars) from sales s join (
SELECT 
    d.inventoryid
FROM
    dropped_inventory d
        JOIN
    abc_table a ON d.inventoryid = a.inventoryid
WHERE
    a.category = 'B') t on s.inventoryid = t.inventoryid; 
-- Total Revenue By C class dropped Inventory
select sum(salesdollars) from sales s join (
SELECT 
    d.inventoryid
FROM
    dropped_inventory d
        JOIN
    abc_table a ON d.inventoryid = a.inventoryid
WHERE
    a.category = 'C') t on s.inventoryid = t.inventoryid;
    
--  Brand from B category that Dropped By more than 50% of store
with dropped_inventory_all as (
SELECT
	abc.inventoryid,
    cast(substring_index(abc.inventoryid,'_',1) as unsigned) as shop_dropped_inventory,
    cast(substring_index(abc.inventoryid,'_',-1) as unsigned) as brand
FROM
    abc_table abc
        JOIN
    dropped_inventory d ON abc.inventoryid = d.inventoryid
WHERE
    abc.category = 'B')
SELECT 
    brand, COUNT(DISTINCT shop_dropped_inventory) AS count_
FROM
    dropped_inventory_all
GROUP BY brand
ORDER BY count_;

-- Brand from C category that Dropped By more than 50% of store
with dropped_inventory_all as (
SELECT
	abc.inventoryid,
    cast(substring_index(abc.inventoryid,'_',1) as unsigned) as shop_dropped_inventory,
    cast(substring_index(abc.inventoryid,'_',-1) as unsigned) as brand
FROM
    abc_table abc
        JOIN
    dropped_inventory d ON abc.inventoryid = d.inventoryid
WHERE
    abc.category = 'C')
SELECT 
    brand, COUNT(DISTINCT shop_dropped_inventory) AS count_
FROM
    dropped_inventory_all
GROUP BY brand
HAVING count_ > 39
ORDER BY count_;

-- > Newly introduced inventory with sales record
create table new_inventory (
SELECT 
    t.inventoryid, SUM(salesdollars) as total_sales
FROM
    sales s
        JOIN
    (SELECT 
        e.inventoryid
    FROM
        endinginventory e
    LEFT JOIN beginginventory b ON e.inventoryid = b.inventoryid
    WHERE
        b.inventoryid IS NULL) t ON s.inventoryid = t.inventoryid
GROUP BY t.inventoryid);

-- Newly added inventory belongs to A-category
SELECT 
    count(distinct a.inventoryid)
FROM
    abc_table a
        JOIN
    new_inventory n ON n.inventoryid = a.inventoryid
WHERE
    a.category = 'A';
-- Revenue ontribution Of newly added A-category item
 SELECT 
    sum(n.total_sales)
FROM
    abc_table a
        JOIN
    new_inventory n ON n.inventoryid = a.inventoryid
WHERE
    a.category = 'A';
-- Newly added inventory belongs to B-category
 SELECT 
    count(distinct a.inventoryid)
FROM
    abc_table a
        JOIN
    new_inventory n ON n.inventoryid = a.inventoryid
WHERE
    a.category = 'B';
-- Revenue ontribution Of newly added B-category item
 SELECT 
    sum(n.total_sales)
FROM
    abc_table a
        JOIN
    new_inventory n ON n.inventoryid = a.inventoryid
WHERE
    a.category = 'B';
-- Newly added inventory belong to C-category
SELECT 
    count(distinct a.inventoryid)
FROM
    abc_table a
        JOIN
    new_inventory n ON n.inventoryid = a.inventoryid
WHERE
    a.category = 'C';
    -- Revenue ontribution Of newly added C-category item
 SELECT 
    sum(n.total_sales)
FROM
    abc_table a
        JOIN
    new_inventory n ON n.inventoryid = a.inventoryid
WHERE
    a.category = 'C';

use pwc_casestudy;
-- --u-------------------------------------------------------------------------------------------------------------------------
/*
inventory that not sold a single unit and introduced before October
*/
create temporary table beginginventory_not_in_sales(
SELECT 
    b.inventoryid
FROM
    beginginventory b
        LEFT JOIN
    sales s ON b.inventoryid = s.inventoryid
WHERE
    s.inventoryid IS NULL);

with temp as (
SELECT 
    distinct bns.inventoryid
FROM
    beginginventory_not_in_sales bns
        LEFT JOIN
    endinginventory e ON bns.inventoryid = e.inventoryid
WHERE
    e.inventoryid IS NOT NULL),
temp2 as(
SELECT 
    t.inventoryid, SUM(quantity) as total_quantity , SUM(dollars)  as total_purchases
FROM
    temp t
        JOIN
    purchases p ON t.inventoryid = p.inventoryid
GROUP BY t.inventoryid)
select sum(total_purchases) from temp2;


create temporary table new_not_in_sales(
SELECT 
    e.inventoryid
FROM
    endinginventory e
        LEFT JOIN
    sales s ON e.inventoryid = s.inventoryid
WHERE
    s.inventoryid IS NULL
and e.inventoryid not in (select inventoryid from beginginventory_not_in_sales)
limit 6000);

SELECT 
    COUNT(DISTINCT inventoryid)
FROM
    new_not_in_sales;
    
with temp as (
SELECT 
    nns.inventoryid,
    SUM(quantity) AS total_quantity,
    SUM(dollars) AS total_purchases
FROM
    new_not_in_sales nns
        JOIN
    purchases p ON nns.inventoryid = p.inventoryid
GROUP BY nns.inventoryid
HAVING MONTH(MIN(receivingdate)) <= 10)
select count(distinct inventoryid),sum(total_purchases) from temp;



/*
if you want to go more in this you can drop these inventory and 
add those inventory which is dropped from Begining inventory and fall in category 'A',and 'B'
*/
with temp as(
SELECT 
    a.*
FROM
    dropped_inventory d
        JOIN
    abc_table a ON d.inventoryid = a.inventoryid
ORDER BY d.total_sales DESC
LIMIT 3790)
select sum(total_sales) from temp;
-- ----------------------------------------------------------------------------------------------------------------------
/*
Purchases vs sale
*/use pwc_casestudy;

select count(s.inventoryid) from purchases p right join sales s on  p.inventoryid = s.inventoryid where p.inventoryid is NULL;



create table PurchasesAnalysis(
select inventoryid,
store,
brand,
receivingdate,
after_purchases,
quantity,
Dollars,
row_number() over() as row_number_
from
(
SELECT 
    p.*,
    Lead(receivingdate) over(partition by inventoryid order by receivingdate) as after_purchases 
FROM
    purchases p) t
);
SET SQL_SAFE_UPDATES = 0;

UPDATE purchasesanalysis 
SET after_purchases = DATE('2016-12-31') 
WHERE after_purchases IS NULL;

create temporary table purchases_vs_sales(
with temp as (SELECT 
    S.inventoryid as s_inventoryid,
    p.inventoryid as p_inventoryid,
    s.salesquantity,
    s.salesdollars,
    s.salesdate,
    p.receivingdate,
    p.after_purchases,
    p.quantity,
    p.dollars,
    p.row_number_
    
FROM
    sales s
        JOIN
    purchasesanalysis p ON s.salesdate BETWEEN p.receivingdate AND after_purchases
	AND s.inventoryid = p.inventoryid) 
SELECT 
    p_inventoryid,
    row_number_,
    min(quantity) as quantity_purchases,
    sum(salesquantity) as quantity_sold,
    min(receivingdate),
    min(after_purchases) 
FROM
    temp
group by p_inventoryid,row_number_
order by quantity_purchases desc);
 
create table c2_purchases_vs_sold
with temp as(
SELECT 
    *,
    ROUND(((quantity_sold) / (quantity_purchases)) * 100,
            2) AS percentage_sold
FROM
    purchases_vs_sales)
Select * ,
CASE
    WHEN percentage_sold >= 130 THEN "Critically Understocked"
    WHEN percentage_sold > 105 THEN "Understocked"
    WHEN percentage_sold < 70 THEN "Severely Overstocked"
    WHEN percentage_sold < 95 THEN "Overstocked"
    ELSE "Stocked Properly"
END as stocked_status
from temp;

/*
	Cheking seasonality of brands then classification is showing wines and wisky and we also see thrends of these two
*/
create index idx_brands_sales on sales(brand);

create temporary table seasonality(
select
brand,
count(distinct inventoryid) as total_inventory ,
sum(salesquantity) as total_quantity,
sum(salesdollars)  as total_sales,
SUM(CASE WHEN MONTH(salesdate) = 1 THEN salesquantity ELSE 0 END) AS jan,
SUM(CASE WHEN MONTH(salesdate) = 2 THEN salesquantity ELSE 0 END) AS feb,
SUM(CASE WHEN MONTH(salesdate) = 3 THEN salesquantity ELSE 0 END) AS mar,
SUM(CASE WHEN MONTH(salesdate) = 4 THEN salesquantity ELSE 0 END) AS apr,
SUM(CASE WHEN MONTH(salesdate) = 5 THEN salesquantity ELSE 0 END) AS may,
SUM(CASE WHEN MONTH(salesdate) = 6 THEN salesquantity ELSE 0 END) AS jun,
SUM(CASE WHEN MONTH(salesdate) = 7 THEN salesquantity ELSE 0 END) AS jul,
SUM(CASE WHEN MONTH(salesdate) = 8 THEN salesquantity ELSE 0 END) AS aug,
SUM(CASE WHEN MONTH(salesdate) = 9 THEN salesquantity ELSE 0 END) AS sep,
SUM(CASE WHEN MONTH(salesdate) = 10 THEN salesquantity ELSE 0 END) AS oct_,
SUM(CASE WHEN MONTH(salesdate) = 11 THEN salesquantity ELSE 0 END) AS nov,
SUM(CASE WHEN MONTH(salesdate) = 12 THEN salesquantity ELSE 0 END) AS dec_
 from sales group by brand);


create temporary table seasonality_clustering(
with temp as (
SELECT 
    brand,
    ROUND(jan / total_quantity, 2) AS jan_ratio,
    ROUND(feb / total_quantity, 2) AS feb_ratio,
    ROUND(mar / total_quantity, 2) AS mar_ratio,
    ROUND(apr / total_quantity, 2) AS apr_ratio,
    ROUND(may / total_quantity, 2) AS may_ratio,
    ROUND(jun / total_quantity, 2) AS jun_ratio,
    ROUND(jul / total_quantity, 2) AS jul_ratio,
    ROUND(aug / total_quantity, 2) AS aug_ratio,
    ROUND(sep / total_quantity, 2) AS sep_ratio,
    ROUND(oct_ / total_quantity, 2) AS oct_ratio,
    ROUND(nov / total_quantity, 2) AS nov_ratio,
    ROUND(dec_ / total_quantity, 2) AS decm_ratio
FROM 
    seasonality),
temp2 as (
select * ,
greatest(jan_ratio , feb_ratio , mar_ratio , apr_ratio , may_ratio , jun_ratio , jul_ratio,aug_ratio , sep_ratio , oct_ratio , nov_ratio , decm_ratio) as max_ratio
from temp)
SELECT 
    brand,max_ratio,
    CASE 
        WHEN max_ratio >= 0.5 THEN 'Single_Month_Dominant'
        WHEN jan_ratio + feb_ratio + mar_ratio >= 0.7 THEN 'Early_Year_Focused'
        WHEN oct_ratio + nov_ratio + decm_ratio >= 0.5 THEN 'Holiday_Focused'
        WHEN jun_ratio + jul_ratio + aug_ratio >= 0.5 THEN 'Summer_Focused'
        WHEN apr_ratio + may_ratio >= 0.4 THEN 'Spring_Focused'
        WHEN max_ratio <= 0.15 THEN 'Steady_Performer'
        ELSE 'Other_Pattern'
    END AS seasonality_cluster
FROM temp2
ORDER BY seasonality_cluster);


create table c2_seasonality_brands(
select s.*,
greatest(jan , feb, mar , apr , may , jun , jul,aug , sep , oct_ , nov , dec_) as max_sale,
max_ratio,
seasonality_cluster
 from seasonality s join seasonality_clustering c on s.brand = c.brand);
 
 
 /*
	Seasonality of wines and others classification is showing it is wine or it is otheres
 */
 create temporary table c2_seasonaliry_of_wines_others(
 select classification,
 sum(salesquantity) as total_quantity_sold,
 sum(salesdollars) as total_sale,
SUM(CASE WHEN MONTH(salesdate) = 1 THEN salesquantity ELSE 0 END) AS jan,
SUM(CASE WHEN MONTH(salesdate) = 2 THEN salesquantity ELSE 0 END) AS feb,
SUM(CASE WHEN MONTH(salesdate) = 3 THEN salesquantity ELSE 0 END) AS mar,
SUM(CASE WHEN MONTH(salesdate) = 4 THEN salesquantity ELSE 0 END) AS apr,
SUM(CASE WHEN MONTH(salesdate) = 5 THEN salesquantity ELSE 0 END) AS may,
SUM(CASE WHEN MONTH(salesdate) = 6 THEN salesquantity ELSE 0 END) AS jun,
SUM(CASE WHEN MONTH(salesdate) = 7 THEN salesquantity ELSE 0 END) AS jul,
SUM(CASE WHEN MONTH(salesdate) = 8 THEN salesquantity ELSE 0 END) AS aug,
SUM(CASE WHEN MONTH(salesdate) = 9 THEN salesquantity ELSE 0 END) AS sep,
SUM(CASE WHEN MONTH(salesdate) = 10 THEN salesquantity ELSE 0 END) AS oct_,
SUM(CASE WHEN MONTH(salesdate) = 11 THEN salesquantity ELSE 0 END) AS nov,
SUM(CASE WHEN MONTH(salesdate) = 12 THEN salesquantity ELSE 0 END) AS dec_
 from sales group by classification);
 
 select * from c2_seasonaliry_of_wines_others;
 
 
 /*Creating table for Power BI*/
 create table c1_sales_by_month(
 select classification,month(salesdate) as month_,
 sum(salesdollars) total_sales,
 sum(salesQuantity) as total_quantity
 from sales group by classification,month(salesdate));
 
 

 create table c1_sales_by_city(
 with temp as(
 Select store , sum(salesdollars) as total_sales ,  sum(salesquantity) as total_quantity from sales group by  store)
 select t.*,city from temp  t join ((select store,city from beginginventory
 union
 select store,city from endinginventory)) as t2 on t.store = t2.store order by city);
 
 
CREATE TABLE c2_hidden_inventory (
SELECT DISTINCT t.inventoryid FROM
    (SELECT DISTINCT
        s.inventoryid
    FROM
        sales s
    LEFT JOIN beginginventory b ON s.InventoryId = b.InventoryId
    WHERE
        b.inventoryid IS NULL) t
        LEFT JOIN
    endinginventory e ON t.inventoryid = e.InventoryId
WHERE
    e.inventoryid IS NULL);
 
/*
	Now working on Vendors 
*/
create table c3_vendors(
SELECT 
    vendornumber, 
    vendorname, 
    COUNT(DISTINCT inventoryid)  as inventory_counts,
    sum(Quantity) as total_quantity,
    SUM(dollars) as dollars,
    count(distinct store) as stores_count,
    min(Podate) as first_purcases,
    max(podate) as last_purchases,
    min(purchaseprice) as lowest_priced_inventory,
    max(purchaseprice) as highest_priced_inventory,
    avg(purchaseprice) as avg_price
FROM
    Purchases
GROUP BY vendornumber , vendorname
order by dollars desc);

select * from purchases;