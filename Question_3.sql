-- importing data 
--CREATE TABLE CustomerTransactions (
--    Cust_Id VARCHAR(50), 
--    Calendar_Dt DATE,
--    Amt_LE FLOAT
--);

------------------------------------------------------------------------------------------------
-- a- What is the maximum number of consecutive days a customer made purchases?

with cte1 as
(
    select cust_id, calendar_dt, 
    calendar_dt - row_number() over(partition by cust_id order by calendar_dt) grouping_date 
    from CustomerTransactions
),
cte2 as 
(
    select cust_id,
    count(*) consecutive_days 
    from cte1
    group by cust_id , grouping_date
)

select cust_id, max(consecutive_days) max_consecutive_days 
from cte2
group by cust_id


------------------------------------------------------------------------------------------------
-- On average, How many days/transactions does it take a customer to reach a 
-- spent threshold of 250 L.E?

with cte1 as
(
    select cust_id,
    sum(Amt_LE) over(partition by cust_id order by calendar_dt rows unbounded preceding) cumulative_sum,
    row_number() over(partition by cust_id order by calendar_dt) days_required
    from CustomerTransactions
),
cte2 as
(
    select cust_id, cumulative_sum, days_required
    from cte1
    where cumulative_sum >= 250
),
cte3 as
(
    select min(days_required) min_days
    from cte2
    group by cust_id 
)

select avg(min_days) average_days_required 
from cte3


