### 1. How many pizzas were ordered?
SELECT count(order_id)
FROM pizza_runner.customer_orders; 

### 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_customer
FROM pizza_runner.customer_orders;

### 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS sucessful_delivery
FROM runner_orders 
WHERE distance != 0
GROUP BY runner_id;

### 4. How many of each type of pizza was delivered?
SELECT runner_id, COUNT(order_id) AS sucessful_delivery
FROM runner_orders 
WHERE distance != 0
GROUP BY runner_id



### 5. How many Vegetarian and Meatlovers were ordered by each customer?**
SELECT 
  co.customer_id,
  pn.pizza_name,
  COUNT(co.pizza_id) AS num_orders
FROM 
  customer_orders co
JOIN 
  pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY 
  co.customer_id, pn.pizza_name;




### 6. What was the maximum number of pizzas delivered in a single order?
SELECT 
  order_id,
  COUNT(pizza_id) AS num_pizzas
FROM 
  customer_orders
GROUP BY 
  order_id
ORDER BY 
  num_pizzas DESC
LIMIT 1;





### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
  co.customer_id,
  SUM(CASE WHEN ro.cancellation IS NULL THEN 0 ELSE 1 END) AS pizzas_with_changes,
  SUM(CASE WHEN ro.cancellation IS NULL THEN 1 ELSE 0 END) AS pizzas_with_no_changes
FROM 
  customer_orders co
JOIN 
  runner_orders ro ON co.order_id = ro.order_id
GROUP BY 
  co.customer_id;




### 8. How many pizzas were delivered that had both exclusions and extras?
SELECT 
  COUNT(DISTINCT co.order_id) AS pizzas_with_exclusions_and_extras
FROM 
  customer_orders co
JOIN 
  runner_orders ro ON co.order_id = ro.order_id
WHERE 
  co.exclusions IS NOT NULL AND co.extras IS NOT NULL;



### 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT 
  DATEPART(HOUR, [order_time]) AS hour_of_day, 
  COUNT(order_id) AS pizza_count
FROM #customer_orders
GROUP BY DATEPART(HOUR, [order_time]);

### 10. What was the volume of orders for each day of the week?
