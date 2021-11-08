For solving this section i am adding one more temp table by spliting extras and exclusions as ex1, ex2, exc1, exc2
t_cust_orders2 as
    (
    select order_id, customer_id, pizza_id, 
          split_part(extras,',',1) as ex1, split_part(extras,',',2) as ex2,
          split_part(exclusions,',',1) as exc1, split_part(exclusions,',',2) as exc2,
      	  order_time
    from t_cust_orders
    )  
    
2.What was the most commonly added extra?
select topping_name, max(count) as most_opted_extra
 from
       ((select extras, topping_name, count
       from
           (select cast(ex1 as int) as extras, count(ex1) as count 
           from t_cust_orders2
           where ex1 <> ''
           group by ex1)  extra_tab
       join pizza_runner.pizza_toppings pt 
       on pt.topping_id = extra_tab.extras
       union 
       select extras, topping_name, count
       from 
           ( select cast(ex2 as int) as extras, count(ex2) as count
           from t_cust_orders2
           where ex2 <> ''
           group by ex2) extra_tab2
       join pizza_runner.pizza_toppings pt
       on pt.topping_id = extra_tab2.extras)) max_table
group by topping_name

5.Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

To solve this I am creating one more temp table

with ext_exc_table as
      (
      select customer_id, pizza_name, pt1.topping_name as ex1, pt2.topping_name as ex2, pt3.topping_name as exc1, pt4.topping_name as exc2
      from 
          (select customer_id, pizza_name, 
                  (case when ex1 = '' then NULL 
                       else cast(ex1 as int) end) as ex1,
                  (case when ex2 = '' then NULL 
                       else cast(ex2 as int) end) as ex2,
                  (case when exc1 = '' then NULL 
                       else cast(exc1 as int) end) as exc1,
                  (case when exc2 = '' then NULL 
                       else cast(exc2 as int) end) as exc2
          from t_cust_orders2  c2
          join pizza_runner.pizza_names pn
          on c2.pizza_id = pn.pizza_id
          where c2.pizza_id = 1) t1
      left join pizza_runner.pizza_toppings pt1 
      on t1.ex1 = pt1.topping_id  
      left join pizza_runner.pizza_toppings pt2 
      on t1.ex2 = pt2.topping_id 
      left join pizza_runner.pizza_toppings pt3 
      on t1.ex2 = pt3.topping_id
      left join pizza_runner.pizza_toppings pt4 
      on t1.ex2 = pt4.topping_id
      )
select * from ext_exc_table

select 
	(case when pizza_name = 'Meatlovers' then customer_id end) as ML_1,
        (case when pizza_name = 'Meatlovers' and ((exc1 = 'Beef') or (exc2 = 'Beef')) then customer_id end) ML_excbeef,
        (case when pizza_name = 'Meatlovers' and ((ex1 = 'Bacon') or (ex2 = 'Bacon')) then customer_id end) ML_extbacon,
        (case when pizza_name = 'meatlovers' and (((exc1 = 'cheese') or (exc2 = 'cheese')) and ((exc1 = 'Bacon') or (exc2 = 'Bacon'))) and (((ex1 = 'Mushroom') or (ex2 = 'mushroom')) and ((ex1 = 'Pepper') or (ex2 = 'Pepper'))) then customer_id end) as ML_4 
from ext_exc_table

5.Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
/* my work still going on for this qn */
select order_id, customer_id, trim(leading '_' from toppings)
from 
        (select order_id, customer_id, concat(def,',',extras,'_',exclusions) as toppings
        from
              (select order_id, customer_id, toppings,
              regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(toppings, '1', 'Bacon'),'2','BBQ Sauce'),'3','Beef'),'4','Cheese'),'5','Chicken'),'6','mushrooms'),'7','onions'),'8','Pepperoni'),'9','Peppers'),'10','Salami'),'11','Tomatoes'),'12','tomato sauce') as def, 
              regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(extras, '1', 'Bacon'),'2','BBQ Sauce'),'3','Beef'),'4','Cheese'),'5','Chicken'),'6','mushrooms'),'7','onions'),'8','Pepperoni'),'9','Peppers'),'10','Salami'),'11','Tomatoes'),'12','tomato sauce') as extras,
              regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(exclusions, '1', 'Bacon'),'2','BBQ Sauce'),'3','Beef'),'4','Cheese'),'5','Chicken'),'6','mushrooms'),'7','onions'),'8','Pepperoni'),'9','Peppers'),'10','Salami'),'11','Tomatoes'),'12','tomato sauce') as exclusions
              from t_cust_orders co
              join pizza_runner.pizza_recipes pr
              on co.pizza_id = pr.pizza_id)t1)t2
order by customer_id

6.What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
/* working on it */

D. Pricing and Ratings
/*copy down all th temp tables we have created so far*/

1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
select sum(case when pizza_name = 'Meatlovers' then 12
			else 10 end) rate
from ext_exc_table

2.What if there was an additional $1 charge for any pizza extras?
select customer_id, pizza_name, ex1, ex2, exc1, exc2,
                (case when pizza_name = 'Meatlovers' and ex1 is not null and ex2 is not null then 14
                 when pizza_name = 'Meatlovers' and ex1 is not null and ex2 is null then 13
                 when pizza_name = 'Meatlevers' and ex1 is null then 12
                 when pizza_name = 'Vegetarian' and ex1 is not null and ex2 is not null then 12
                 when pizza_name = 'vegetarian' and ex1 is not null and ex2 is null then 11
                 when pizza_name = 'Vegetarian' and ex1 is null then 10
                 when pizza_name = 'Vegetarian' and ex1 is null then 12
                 when pizza_name = 'Vegetarian' and ex1 is not null and ex2 is null then 13
                 when pizza_name = 'Meatlevers' and ex1 is null then 12
                 end) rate 
    from ext_exc_table