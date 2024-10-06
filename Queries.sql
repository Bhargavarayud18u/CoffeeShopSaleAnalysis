create database Coffe_Shop_sales;
select * from coffee_shop;
update coffee_shop
set transaction_date = str_to_date(transaction_date,'%d-%m-%Y');
Alter table coffee_shop
modify column transaction_date date;
select * from coffee_shop
where
month(transaction_date)=5;
update coffee_shop
set transaction_time = str_to_date(transaction_time,'%H:%i:%s');
Alter table coffee_shop
modify column transaction_time time;
describe coffee_shop;
Alter table coffee_shop
change column ï»¿transaction_id transaction_id int;
select concat((round(sum(unit_price*transaction_qty)))/1000,'K') AS total_Sales from coffee_shop
where month(transaction_date)=3; -- march month

-- Query for Total Sales-MOM difference and MOM Growth
select
month(transaction_date) as month,
round(sum(unit_price * transaction_qty)) as total_sales,
(sum(unit_price*transaction_qty)-lag(sum(unit_price*transaction_qty),1)
over (order by month(transaction_date)))/lag(sum(unit_price*transaction_qty),1)
over(order by month(transaction_date))*100 as mom_increase_percentage
from
coffee_shop
where
month(transaction_date)in(4,5)
group by
month(transaction_date)
order by
month(transaction_date);

-- Query for total orders in a month

select count(transaction_id) as Total_Orders
from coffee_shop
where month(transaction_date)=3;

-- Query for Total Orders-MOM difference and MOM Growth
select
month(transaction_date) as month,
(count(transaction_id))as total_sales,
(count(transaction_id)-lag(count(transaction_id),1)
over (order by month(transaction_date)))/lag(count(transaction_id))
over(order by month(transaction_date))*100 as mom_increase_percentage
from
coffee_shop
where
month(transaction_date)in(4,5)
group by
month(transaction_date)
order by
month(transaction_date);

-- Query for total quantity sold in month
select sum(transaction_qty) as Total_Quantity
from coffee_shop
where month(transaction_date)=3;

-- Query for total quantity sold MOM difference and MOM Growth
select
month(transaction_date) as month,
(sum(transaction_qty))as total_Quantity,
(sum(transaction_qty)-lag(sum(transaction_qty),1)
over (order by month(transaction_date)))/lag(sum(transaction_qty))
over(order by month(transaction_date))*100 as mom_increase_percentage
from
coffee_shop
where
month(transaction_date)in(4,5)
group by
month(transaction_date)
order by
month(transaction_date);

-- Going to calander on the dashboard
select
concat(round(sum(unit_price*transaction_qty)/1000,1),'k') as Total_Sales,
concat(round(sum(transaction_qty)/1000,1),'k') as Total_quantity_sold,
concat(round(count(transaction_id)/1000,1),'k') as Total_Orders
from
coffee_shop
where 
transaction_date='2023-05-18';

-- Query to get Sale analysis for weekdays and weekends

SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    concat(ROUND(SUM(unit_price * transaction_qty)/1000,1),'k') AS total_sales
FROM 
    coffee_shop
WHERE 
    MONTH(transaction_date) = 5  
GROUP BY 
   day_type;
   
   -- Query to get sale analysis with store location
   
   SELECT 
	store_location,
	concat(round(SUM(unit_price * transaction_qty)/1000,1),'k') as Total_Sales
FROM coffee_shop
WHERE
	MONTH(transaction_date) =5 
GROUP BY store_location
ORDER BY 	SUM(unit_price * transaction_qty) DESC;

-- Average sale and daily sale in month
SELECT concat(round(AVG(total_sales)/1000,1),'k') AS average_sales
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        coffee_shop
	WHERE 
        MONTH(transaction_date) = 5
    GROUP BY 
        transaction_date
) AS internal_query;

-- Daily sales in a month
SELECT 
    DAY(transaction_date) AS day_of_month,
    concat(ROUND(SUM(unit_price * transaction_qty)/1000,1),'k') AS total_sales
FROM 
    coffee_shop
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);
    
    -- Comparing sales as below average and above average according to average sales of month
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        concat(round(SUM(unit_price * transaction_qty)/1000,1),'k') AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
    -- Sales by product category
    SELECT 
	product_category,
	concat(ROUND(SUM(unit_price * transaction_qty)/1000,1),'k') as Total_Sales
FROM coffee_shop
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC

-- Top 10 products by sales
SELECT 
	product_type,
	concat(ROUND(SUM(unit_price * transaction_qty)/1000,1),'k') as Total_Sales
FROM coffee_shop
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;

-- Sales by days and hours
SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    coffee_shop
WHERE 
    DAYOFWEEK(transaction_date) = 1
    AND HOUR(transaction_time) = 14 
    AND MONTH(transaction_date) = 5; 
    
    -- Sale in hours
    SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop
WHERE 
    MONTH(transaction_date) = 5 
GROUP BY 
    Hour_of_day
ORDER BY 
    Hour_of_day;
    
    -- Sales in particular day of the week in a month
    SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    Day_of_week;










