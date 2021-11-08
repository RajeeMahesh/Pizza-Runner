1.How many pizzas were ordered?
  select count(order_id) from t_cust_orders
  
2.How many unique customer orders were made?
select count(distinct order_id) from t_cust_orders

3.How many successful orders were delivered by each runner?
select runner_id, count(order_id) from t_runner_orders
where cancellation = ' '
group by runner_id

4.How many of each type of pizza was delivered?
select c.pizza_id, pizza_name, count(c.order_id) as no_of_p_delivered
from t_cust_orders c 
join t_runner_orders r 
on c.order_id = r.order_id
join pizza_runner.pizza_names p 
on c.pizza_id = p.pizza_id
where cancellation = ' '
group by c.pizza_id, pizza_name

5.How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id, c.pizza_id, pizza_name, count(c.pizza_id) 
from t_cust_orders c 
join pizza_runner.pizza_names p 
on c.pizza_id = p.pizza_id
group by customer_id, c.pizza_id, pizza_name
order by customer_id

6.What was the maximum number of pizzas delivered in a single order?
select max(count) as max_no_of_pizza_ordered
from 
      (select order_id, count(pizza_id) as count
      from t_cust_orders
      group by order_id
      order by order_id) t1
      
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
 select customer_id, 
 		  count(case when extras = '' and exclusions = '' then 1
              end) as no_change,
          count(case when extras <> '' or exclusions <> '' then 1
              end) as more_change
 from t_runner_orders r 
 join t_cust_orders c 
 on r.order_id = c.order_id
 where cancellation = ''
 group by customer_id
 order by customer_id
 
 8.How many pizzas were delivered that had both exclusions and extras?
 select sum(both_changed) as both_changed
from 
      (select customer_id, 
                count(case when extras <> '' and exclusions <> '' then 1
                    end) as both_changed
       from t_runner_orders r 
       join t_cust_orders c 
       on r.order_id = c.order_id
       where cancellation = ''
       group by customer_id
       order by customer_id)t1
 
 9.What was the total volume of pizzas ordered for each hour of the day?
 select extract(hour from order_time) as hour, count(order_id)
from t_cust_orders
group by extract(hour from order_time)
order by extract(hour from order_time)

10.What was the volume of orders for each day of the week?
select Day_of_week, count(order_id)
from
      (select order_id, order_time, 
             (case when extract(dow from order_time) = 0 then 'Sunday'
                  when extract(dow from order_time) = 1 then 'Monday'
                  when extract(dow from order_time) = 2 then 'Tuesday'
                  when extract(dow from order_time) = 3 then 'Wednesday'
                  when extract(dow from order_time) = 4 then 'Thursday'
                  when extract(dow from order_time) = 5 then 'Friday'
                  when extract(dow from order_time) = 6 then 'Saturday'
             end) Day_of_Week
      from t_cust_orders 
      )t
group by Day_of_week