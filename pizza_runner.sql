
-- I. CREATING TABLES

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);

INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);

INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);

INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);

INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

 -- II. DATA CLEANING

 -- A. Table customer_orders 

 -- Replacing blank rows and 'null' text values with proper NULL values 

	update customer_orders
	set exclusions = null
	where exclusions = 'null' or exclusions = ''

	update customer_orders
	set extras = null
	where extras = 'null' or extras = '' 
  
-- B. Table runner_orders

-- Removing 'km' from 'distance' column for easier aggregation (column contains numeric values)

  update runner_orders  
  set distance_km = replace(distance_km,'km','')

-- Replacing 'null' text values or blanks with proper NULL values 

  update runner_orders 
  set pickup_time = null
  where distance_km = 'null'

  update runner_orders 
  set distance_km = null
  where distance_km = 'null'

  update runner_orders 
  set duration = null
  where duration = 'null'

  update runner_orders
  set cancellation = null
  where cancellation = '' or cancellation = 'null'

  -- Removing 'min', 'minutes', 'minute' additions from 'duration' column

  update runner_orders 
  set duration = LEFT(duration,2)
  from runner_orders
  where duration like '%min%'

-- Changing data type in 'pickup_time' column to datetime type - to enable date/time manipulation

  alter table runner_orders
  alter column pickup_time datetime

-- Changing data type in 'distance_km' column to float type - to enable calculations etc.

alter table runner_orders
alter column distance_km float

-- Changing data type in 'duration_mins' to integer type - to enable calculations/aggregation etc.

alter table runner_orders
alter column duration_mins int

--- III. QUESTIONS AND DATABASE NORMALISATION 	

--1. How many pizzas were ordered?

select 
count(pizza_id) as pizza_quantity
from customer_orders

--2. How many unique customer orders were made?

select 
count (distinct order_id) as pizza_orders
from customer_orders

--3. How many successful orders were delivered by each runner?

select 
runner_id,
count(order_id) as order_count
from runner_orders
where cancellation is null
group by runner_id
order by runner_id

--4. How many of each type of pizza was delivered?
 
 select 
 pizza_id,
 count(pizza_id) as pizza_count
 from customer_orders c
 inner join runner_orders r
 on c.order_id = r.order_id
 where cancellation is null
 group by pizza_id

--5. How many Vegetarian and Meatlovers were ordered by each customer?

select
pizza_id,
customer_id,
count(pizza_id) as pizza_count
from customer_orders
group by rollup (pizza_id, customer_id)

--6. What was the maximum number of pizzas delivered in a single order?

with PizzaCountByOrderId as
(select 
c.order_id,
count(pizza_id) as pizza_count
from customer_orders c
inner join runner_orders r
on c.order_id = r.order_id
where cancellation is null
group by c.order_id)
select 
max(pizza_count) as max_pizza_order
from PizzaCountByOrderId

--7. For each customer, how many delivered pizzas had at least 1 change 
-- and how many had no changes?

with PizzaChanges as
(
select
distinct c.unique_id,
customer_id,
case 
	when exclusions is null AND extras is null then 'no changes'
	when exclusions is not null OR extras is not null then 'changed'
end as pizza_changes
from customer_orders as c
inner join exclusion_extra as e
on e.unique_id = c.unique_id
inner join runner_orders as r
on r.order_id = c.order_id
where cancellation is null
)
select
customer_id,
pizza_changes,
count(pizza_changes) as pizza_count
from PizzaChanges
group by customer_id, pizza_changes
order by customer_id

--9. What was the total volume of pizzas ordered for each hour of the day?

select 
convert(date,order_time) as order_day,
DATEPART(hour, order_time) as order_hour,
count(pizza_id) as pizza_volume
from customer_orders
group by DATEPART(hour,order_time), convert(date,order_time)

--10. What was the volume of orders for each day of the week?

select
DATENAME(weekday,order_time) as weekday,
count(pizza_id) as pizza_volume
from customer_orders
group by DATENAME(weekday,order_time)

--11. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

select 
registration_date,
DATEPART(ISO_WEEK, registration_date) as week_number,
count(runner_id) as runner_count
from runners
group by DATEPART(ISO_WEEK, registration_date), registration_date

--12. Is there any relationship between the number of pizzas and how long the order takes to prepare?

-- Answer: Yes, in general, the more pizzas contain the order, the longer takes to prepare them.
-- But there are also exceptions - it took longer than usual to complete order no. 8 (only one pizza)

select 
c.order_id,
count(pizza_id) as pizza_count,
DATEDIFF(minute, order_time, pickup_time) as prep_time
from customer_orders c
inner join runner_orders r
on c.order_id = r.order_id
where cancellation is null
group by c.order_id, DATEDIFF(minute, order_time, pickup_time)
order by c.order_id

--13. What was the average distance travelled for each customer?

select 
customer_id,
avg(distance_km) as avg_distance_km
from runner_orders r
inner join customer_orders c
on r.order_id = c.order_id
group by customer_id

--14. What was the difference between the longest and shortest delivery times for all orders?

select 
max(duration_mins) - min(duration_mins) as delivery_difference
from runner_orders

--16. What was the average speed for each runner for each delivery and 
--    do you notice any trend for these values?

-- Answer: Average speed is calculated according to the following equation - V = s/t where:
-- V is average speed,
-- s is distance,
-- t is time.
-- Based on this, data provided in the table 'runner_orders' is inaccurate - average speed for 
-- every runner exceeds 35 km/h which is more than performance of professional marathon runners  

select  
order_id,
runner_id,
round(distance_km / (cast(duration_mins as decimal) / 60),2) as avg_speed
from runner_orders
where distance_km is not null

--17. What is the successful delivery percentage for each runner?

select 
runner_id,
format(cast(count(case when cancellation is null then 1 end) as float) / cast(count(order_id) as float),'p') as success_delivery
from runner_orders
group by runner_id

--18. What are the standard ingredients for each pizza?

-- First of all, table 'pizza_recipes' contained multiple values in 'toppings' column. 
-- So, according to database normalization standards, I decided to drop the table, 
-- removing rows containg multiple values and recreate it with single-value 'toppings' column.

DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  topping_id INTEGER
  )

insert into pizza_recipes (pizza_id, topping_id)
values	(1, 1), 
		(1, 2), 
		(1, 3), 
		(1, 4), 
		(1, 5),
		(1, 6),
		(1, 8),
		(1, 10),
		(2, 4), 
		(2, 6), 
		(2, 7), 
		(2, 9), 
		(2, 11),
		(2, 12);
	
select 
pizza_name,
topping_name
from pizza_names
inner join pizza_recipes
on pizza_names.pizza_id = pizza_recipes.pizza_id
inner join pizza_toppings
on pizza_toppings.topping_id = pizza_recipes.topping_id

-- 19. What was the most commonly added extra?

-- At the beginning, I decided to create new table containing extras and exclusions.
-- Again, table 'customer_orders' contained more than one value per row in columns: 'extras' 
-- and 'exclusions', so I removed them to avoid data duplication.
-- To draw a relationship between new table 'exclusion_extra' and 'customer_orders', 
-- adding to both tables new column called 'unique_id', uniquely identyfing every ordered pizza.

alter table customer_orders
add unique_id int IDENTITY(1,1) not null

create table exclusion_extra 
(unique_id int,
exclusions int,
extras int)

insert into exclusion_extra 
(unique_id, exclusions, extras)
values	(1, null, null),
		(2, null, null),
		(3, null, null),
		(4, null, null),
		(5, 4, null),
		(6, 4, null),
		(7, 4, null),
		(8, null, 1),
		(9, null, null),
		(10, null, 1),
		(11, null, null),
		(12, 4, 1),
		(12, null, 5),
		(13, null, null),
		(14, 2, 1),
		(14, 6, 4);

alter table customer_orders 
drop column exclusions, extras

select top 1
topping_name,
max(extras_count) as topping_count
from
(
select
extras,
convert(nvarchar, topping_name) as topping_name,
count(extras) as extras_count
from exclusion_extra 
inner join pizza_toppings
on pizza_toppings.topping_id = exclusion_extra.extras 
group by extras, convert(nvarchar, topping_name)
) as topping_count
group by topping_name 

--20. How many pizzas were delivered that had both exclusions and extras?

select 
count(distinct c.unique_id) as pizza_with_changes
from exclusion_extra as e
inner join customer_orders as c
on c.unique_id = e.unique_id
inner join runner_orders as r
on r.order_id = c.order_id
where (exclusions is not null
OR extras is not null)
AND cancellation is null

--21. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges 
-- for changes - how much money has Pizza Runner made so far if there are no delivery fees?

select 
sum(pizza_price) as pizza_income
from
(select 
c.pizza_id,
pizza_name,
case
		when pizza_name like 'Meatlovers' then 12
		else 10
end as pizza_price
from customer_orders as c
inner join pizza_names as p
on c.pizza_id = p.pizza_id
inner join runner_orders as r
on r.order_id = c.order_id
where cancellation is null)
as pizza_pricing
	
-- 22. What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra

select 
(sum(pizza_price) + sum(extras_pricing)) as full_pricing
from
(select 
c.pizza_id,
extras,
case pizza_id 
			when 1 then 12
			else 10
end as pizza_price,
case
			when extras =  4 then 2
			when extras is not null then 1
			else 0
end as extras_pricing
from customer_orders as c
inner join exclusion_extra as e
on e.unique_id = c.unique_id
inner join runner_orders as r
on r.order_id = c.order_id
where cancellation is null)
as pizza_pricing

-- 23. The Pizza Runner team now wants to add an additional ratings system that allows customers 
-- to rate their runner. 
-- Design an additional table for this new dataset - generate a schema for this 
-- new table and insert your own data for ratings for each successful customer order between 1 to 5.

create function dbo.CancelledOrNot (@OrderId int)
returns varchar(30)
as
begin
return 
		(select 
		cancellation
		from runner_orders
		where order_id = @OrderId)
end

create table order_rating
(order_id	int not null FOREIGN KEY REFERENCES dbo.runner_orders(order_id),
rating		int check (rating between 1 and 5), 
check (dbo.CancelledOrNot(order_id) is null)
) 

insert into order_rating (order_id, rating)
values	
		(1, 4),
		(2, 3),
		(3, 3),
		(4, 3),
		(5, 5),
		(7, 2),
		(8, 4),
		(10, 3)

-- 24. Using newly generated table - join all of the information together to form a table 
-- which has the following information for successful deliveries:
-- a.customer_id
-- b.order_id
-- c.runner_id
-- d.rating
-- e.order_time
-- f.pickup_time
-- g.time between order and pickup
-- h.delivery duration
-- i.total number of pizzas

select 
distinct r.order_id,
customer_id,
runner_id,
rating,
order_time,
pickup_time,
DATEDIFF(MINUTE,order_time,pickup_time) as order_pickup_diff_min,
duration_mins as delivery_time_min,
count(unique_id) over () as pizza_count
into custom_table
from runner_orders as r
inner join customer_orders as c
on c.order_id = r.order_id
left join order_rating as o
on r.order_id = o.order_id 

-- 25. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and 
-- each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner 
-- have left over after these deliveries?

select 
sum(pizza_price) - sum(runner_cost) as pizza_profit
from
(
select
unique_id,
case
	when pizza_name like 'Meatlovers' then 12
	else 10
end as pizza_price,
distance_km * 0.3 as runner_cost
from customer_orders as c
inner join pizza_names as p
on c.pizza_id = p.pizza_id
inner join runner_orders as r
on r.order_id = c.order_id
where distance_km is not null
) as pizza_income_cost

