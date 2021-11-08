1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select extract(week from registration_date) as week, count(runner_id) as no_of_runner_registered
from pizza_runner.runners
group by extract(week from registration_date)

2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select runner_id, extract(minutes from avg(time_taken)) as time_taken
from 
      (select runner_id, to_timestamp(pickup_time, 'yyyy-mm-dd HH24:MI:SS'), order_time, (to_timestamp(pickup_time, 'yyyy-mm-dd HH24:MI:SS') - order_time) as time_taken
      from t_runner_orders r
      join t_cust_orders c 
      on r.order_id = c.order_id
      where cancellation = '') t1
group by runner_id
order by runner_id

3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
select pizza_count, extract(minutes from avg(prep_time)) as prep_time
from                                
      (select c.order_id, count(pizza_id) as Pizza_count, avg(to_timestamp(pickup_time, 'yyyy-mm-dd HH24:MI:SS') - order_time) as prep_time
      from t_runner_orders r
      join t_cust_orders c 
      on r.order_id = c.order_id
      where cancellation =''
      group by c.order_id)t1
group by pizza_count
order by pizza_count

4.What was the average distance travelled for each customer?
select customer_id, round(avg(cast(distance as numeric)),2) as avg_distance
from t_runner_orders r
join t_cust_orders c 
on r.order_id = c.order_id
where cancellation =''
group by customer_id 
order by avg_distance                              

5.What was the difference between the longest and shortest delivery times for all orders?
select (Max(cast(duration as int)) - Min(cast(duration as int))) as diff 
from t_runner_orders r
join t_cust_orders c 
on r.order_id = c.order_id
where cancellation =''

6.What was the average speed for each runner for each delivery and do you notice any trend for these values?
select runner_id, round(avg((cast(distance as numeric)/cast(duration as int))),2) as avg_speed
from t_runner_orders  
where cancellation = ''
group by runner_id
order by avg_speed 

/* Fastest is runner 2 */

7.What is the successful delivery percentage for each runner?
select runner_id, succ, tot, ((succ*100)/tot) as succ_per
from 
    (select runner_id, 
           sum(case when duration <> '' then 1 
               else 0 end) as succ, count(order_id) as tot 
    from t_runner_orders 
    group by runner_id) t