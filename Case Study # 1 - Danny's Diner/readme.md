
/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

/* --------------------
   Case Study Answers
   --------------------*/
-- 1. What is the total amount each customer spent at the restaurant?
````sql
SELECT
  s.customer_id, 
  SUM(m.price) AS total_amount_spent
FROM sales s
JOIN menu m 
ON s.product_id = m.product_id
GROUP BY s.customer_id;
````

-- 2. How many days has each customer visited the restaurant?
````sql
SELECT 
	customer_id, 
    COUNT(DISTINCT order_date) AS days_visited
FROM sales
GROUP BY customer_id;
````

-- 3. What was the first item from the menu purchased by each customer?
````sql
SELECT 
	customer_id, 
	product_name
FROM (	  
	SELECT 
		sales.customer_id, 
		sales.order_date, 
		menu.product_name,
		DENSE_RANK() OVER (
		  PARTITION BY sales.customer_id 
		  ORDER BY sales.order_date
		) AS customer_rank
	FROM dannys_diner.sales
	INNER JOIN dannys_diner.menu
	ON sales.product_id = menu.product_id
) AS ordered_sales
WHERE customer_rank = 1
GROUP BY customer_id, product_name;
````
  
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
````sql
SELECT 
	m.product_id, 
    m.product_name, 
    COUNT(*) AS purchase_count
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_id, m.product_name
ORDER BY purchase_count DESC
LIMIT 1;
````

-- 5. Which item was the most popular for each customer?
````sql
SELECT 
	t.customer_id, 
    m.product_name, 
    t.purchase_count
FROM (
  SELECT s.customer_id, s.product_id, COUNT(*) AS purchase_count
  FROM sales s
  GROUP BY s.customer_id, s.product_id
) t
JOIN (
  SELECT
	customer_id, 
	MAX(purchase_count) AS max_purchase_count
  FROM (
    SELECT 
		s.customer_id, 
        s.product_id, COUNT(*) AS purchase_count
    FROM sales s
    GROUP BY s.customer_id, s.product_id
  ) subquery
  GROUP BY customer_id
) max_counts ON t.customer_id = max_counts.customer_id AND t.purchase_count = max_counts.max_purchase_count
JOIN menu m ON t.product_id = m.product_id
ORDER BY customer_id;
````

-- 6. Which item was purchased first by the customer after they became a member?
````sql
WITH member_purchase_cte AS (
  SELECT
    s.customer_id,
    s.product_id,
    s.order_date,
    m.product_name,
    ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS purchase_rank
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
  JOIN members mem ON s.customer_id = mem.customer_id
  WHERE s.order_date >= mem.join_date
)	
SELECT
  customer_id,
  product_name AS first_purchased_item
FROM member_purchase_cte
WHERE purchase_rank = 1;
````
	
-- 7. Which item was purchased just before the customer became a member?
````sql
# Create a temporary table (CTE)
WITH member_purchase_cte AS (
  SELECT
    s.customer_id,
    s.product_id,
    s.order_date,
    m.product_name,
    ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS purchase_rank
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
  JOIN members mem ON s.customer_id = mem.customer_id
  WHERE s.order_date < mem.join_date
)
SELECT
  customer_id,
  product_name AS purchased_before_membership
FROM member_purchase_cte
WHERE purchase_rank = 1;
````

-- 8. What is the total items and amount spent for each member before they became a member?
````sql
SELECT
  s.customer_id,
  COUNT(s.product_id) AS total_items,
  SUM(m.price) AS total_amount_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mem ON s.customer_id = mem.customer_id AND s.order_date >= mem.join_date
WHERE mem.customer_id IS NULL
GROUP BY s.customer_id;
````

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
````sql
SELECT
  s.customer_id,
  SUM(
    CASE
      WHEN m.product_name = 'sushi' THEN 20 * m.price  -- 2x multiplier for sushi
      ELSE 10 * m.price  -- 1x multiplier for other items
    END
  ) AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;
````

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
````sql
SELECT
  s.customer_id,
  SUM(
    CASE
      WHEN (s.order_date >= mem.join_date AND s.order_date <= DATE_ADD(mem.join_date, INTERVAL 1 WEEK))
      THEN 20 * m.price  -- 2x points multiplier for the first week after joining
      ELSE 10 * m.price  -- 1x points multiplier for other purchases
    END
  ) AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE (s.order_date >= '2021-01-01' AND s.order_date <= '2021-01-31') AND s.customer_id IN ('A', 'B') 
GROUP BY s.customer_id
ORDER BY s.customer_id;
````
