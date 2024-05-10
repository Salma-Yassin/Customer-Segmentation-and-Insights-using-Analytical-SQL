with cte as
(
    select customer_id, invoice, sum(revenue) total_price 
    from tableretail
    group by invoice, customer_id 
),
cte2 as 
(
    select customer_id, 
    count(invoice) frequency, 
    sum(total_price) monetary,
    ntile(5) over(order by count(invoice)) f_score,
    ntile(5) over(order by sum(total_price)) m_score 
    from cte
    group by customer_id
),
cte3 as 
(
    select customer_id, frequency, monetary, f_score, m_score,
    round((f_score + m_score)/2,0) fm_score 
    from cte2
),
cte4 as
 (
     select customer_id ,
    round(((select max(to_date(invoicedate, 'MM/DD/YYYY HH24:MI'))
    from tableretail) - max(to_date(invoicedate,'MM/DD/YYYY HH24:MI'))),0)
    recency
    from tableretail
    group by customer_id
),
cte5 as
(
    select customer_id, recency,
    ntile(5) over(order by recency desc ) r_score 
    from cte4
),
cte6 as 
(
    select cte5.customer_id, cte5.recency, cte3.frequency, cte3.monetary, cte5.r_score, cte3.fm_score
    from cte5 join cte3 on cte5.customer_id = cte3.customer_id
)

select customer_id, recency, frequency,monetary,r_score,fm_score,
CASE
          WHEN  (r_score= 5 AND  fm_score= 5) OR 
                     (r_score= 5 AND  fm_score= 4) OR
                     (r_score= 4 AND  fm_score= 5) THEN 'Champions'
                     
          WHEN (r_score = 5 AND fm_score = 3) OR
                    (r_score = 4 AND fm_score = 4) OR
                    (r_score = 3 AND fm_score = 5) OR
                    (r_score = 3 AND fm_score = 4) THEN 'Loyal Customers'
                    
          WHEN (r_score = 5 AND fm_score = 2) OR
                    (r_score = 4 AND fm_score = 2) OR
                    (r_score = 3 AND fm_score = 3) OR
                    (r_score = 4 AND fm_score = 3) THEN 'Potential Loyalists'
                    
          WHEN (r_score = 5 AND fm_score = 1) THEN 'Recent Customers'
          
          WHEN (r_score = 4 AND fm_score = 1) OR
                    (r_score = 3 AND fm_score = 1) THEN 'Promising'
                    
          WHEN (r_score = 3 AND fm_score = 2) OR
                    (r_score = 2 AND fm_score = 3) OR
                    (r_score = 2 AND fm_score = 2) THEN 'Customers Needing Attention'
                    
          WHEN (r_score = 2 AND fm_score = 5) OR
                     (r_score = 2 AND fm_score = 4) OR
                     (r_score = 1 AND fm_score = 3) THEN 'At Risk'
                    
          WHEN (r_score = 1 AND fm_score = 5) OR
                     (r_score = 1 AND fm_score = 4) THEN 'Can not lose them'
                    
          WHEN (r_score = 1 AND fm_score = 2) THEN 'Hibernating'
          
          WHEN (r_score = 1 AND fm_score = 1) THEN 'Lost'
          
          ELSE 'Unclassified'
        END AS customer_segment
from cte6
order by customer_id 





