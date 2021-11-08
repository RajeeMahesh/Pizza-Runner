First I am trying to clean the data. 
Trying to remove the null values from customer_orders 

with t_cust_orders as
( 
      SELECT order_id, customer_id, pizza_id,
             (case when exclusions is null or exclusions like '%null%' then ''
                  else exclusions 
             end) as exclusions,
             (case when extras is null or extras like '%null%' then '' 
                  else extras 
             end) as extras, 
             order_time 
      from pizza_runner.customer_orders
 ) 
 select * from t_cust_orders
 
 with t_runner_orders as 
( 
  select order_id, runner_id,
  		(case when pickup_time is null or pickup_time like '%null%' then '' 
         	  else pickup_time 
         end) as pickup_time,
  		 (case when distance is null or distance like '%null%' then ''
  			  when distance like '%km' then trim ('km' from distance)
  			  else distance
  	     end) as distance, 
         (case when duration is null or duration like '%null%' then '' 
         	  when duration like '%mins' then trim ('mins' from duration) 
              when duration like '%minute' then trim ('minute' from duration)
              when duration like '%minutes' then trim ('minutes' from duration)
              else duration 
         end) as duration,
         (case when cancellation is null or cancellation like '%null%' then '' 
         	  else cancellation 
         end) as cancellation
   from pizza_runner.runner_orders 
) 
select * from t_runner_orders