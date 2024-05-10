-- Add a column for Revenue 

ALTER TABLE tableRetail
ADD revenue FLOAT AS (price * quantity);
------------------------------------------------------------------------------------------------
-- 1. What are the top 5 most popular products (by quantity sold) and their total revenue?
with cte as
( 
        select stockcode, 
        sum(quantity) quantity_,
        sum(revenue) revenue_,
        rank() over(order by sum(quantity) DESC) rank_
        from tableretail
        group by stockcode 
)

select stockcode "PRODUCT", 
quantity_ "QUANTITY",
revenue_ "REVENUE"
from cte 
where rank_ < 6
-----------------------------------------------------------------------------------------------
-- 2. Who are the top 10 customers who have made most purchases?

with cte as
(
    select customer_id, invoice 
    from tableretail
    group by invoice, customer_id 
),
cte2 as 
(
    select customer_id "CUSTOMER",
    count(invoice) "# OF Purchases",
    rank() over(order by count(invoice) desc) rank_
    from cte 
    group by customer_id
    order by count(invoice) DESC
)

select  "CUSTOMER",  "# OF Purchases"
from cte2
where rank_ < 11 
-----------------------------------------------------------------------------------------------
-- 3. What is the average order value (total price) per customer
with cte as
(
select customer_id, sum(revenue) total_price 
from tableretail
group by invoice, customer_id 
)

select customer_id "CUSTOMER",
round(avg(total_price),0)"AVERAGE ORDER VALUE"
from cte 
group by customer_id
order by customer_id 
------------------------------------------------------------------------------------------------
-- 4. what is the date of the last purchase for each customer?
select customer_id "CUSTOMER",
 to_char(max(to_date(invoicedate,'MM/DD/YYYY HH24:MI')),'MM-DD-YYYY') "Last Purchase Date"
from tableretail
group by customer_id

------------------------------------------------------------------------------------------------
-- 5. Which customers have not made any purchases recently, 
-- last purchase more than 3 months ago?
select customer_id "CUSTOMER",
 to_char(max(to_date(invoicedate,'MM/DD/YYYY HH24:MI')),'MM-DD-YYYY') "Last Purchase Date"
from tableretail
where to_date(invoicedate, 'MM/DD/YYYY HH24:MI')  < ADD_MONTHS(SYSDATE, -3 )
group by customer_id
order by max(to_date(invoicedate,'MM/DD/YYYY HH24:MI')) 
------------------------------------------------------------------------------------------------
-- 6. what is the total revenue per month over years ? 
with cte as 
( 
    select revenue, 
    to_char(to_date(invoicedate, 'MM/DD/YYYY HH24:MI'), 'YYYY-MM') month_year
    from tableretail  
)

select month_year , sum(revenue)
from cte 
group by month_year
order by month_year



