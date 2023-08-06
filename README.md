# 8-Week-SQL-Challenge

# 🍜 Case Study #1: Danny's Diner 
<img src="https://user-images.githubusercontent.com/81607668/127727503-9d9e7a25-93cb-4f95-8bd0-20b87cb4b459.png" alt="Image" width="500" height="520">

1. What is the total amount each customer spent at the restaurant?
````sql
SELECT
  s.customer_id, 
  SUM(m.price) AS total_amount_spent
FROM sales s
JOIN menu m 
ON s.product_id = m.product_id
GROUP BY s.customer_id;
````
Answer:

![week1_question1](https://github.com/Chuntim0303/8-Week-SQL-Challenge/assets/126696701/ff4065fd-2019-4407-a686-5e59bb91b140)

***
2. How many days has each customer visited the restaurant?
````sql
SELECT
  customer_id, 
  COUNT(DISTINCT order_date) AS days_visited
FROM sales
GROUP BY customer_id;
````
Answer:

![week1_question2](https://github.com/Chuntim0303/8-Week-SQL-Challenge/assets/126696701/d538c99c-68e4-4044-b59e-101d4dd8d700)
***
3. What was the first item from the menu purchased by each customer?

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
Answer:

![week1_question3](https://github.com/Chuntim0303/8-Week-SQL-Challenge/assets/126696701/2a173c48-9d86-4ff8-8368-e769d62ca6bd)
***
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
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
Answer:

![week1_question4](https://github.com/Chuntim0303/8-Week-SQL-Challenge/assets/126696701/cebb1a65-111e-454e-82c5-2d1b3bf38268)

***
5. Which item was the most popular for each customer?
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
Answer:

![week1_question5](https://github.com/Chuntim0303/8-Week-SQL-Challenge/assets/126696701/70319a2b-2f87-4abf-9dc6-b0b2a6dd3daf)

***
6. Which item was purchased first by the customer after they became a member?
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
Answer:

![week1_question6](https://github.com/Chuntim0303/8-Week-SQL-Challenge/assets/126696701/8cef69e4-352a-4480-838f-5b1423cde114)
***
7. Which item was purchased just before the customer became a member?
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
Answer:

![week1_question7](https://github.com/Chuntim0303/8-Week-SQL-Challenge/assets/126696701/0082082e-b36c-4667-852d-0061af69b365)


***
8. What is the total items and amount spent for each member before they became a member?
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
Answer:

![week1_question8](https://github.com/Chuntim0303/8-Week-SQL-Challenge/assets/126696701/d412b886-2c5c-4284-8e29-a844a6bf4cbb)

***
9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
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

Answer:

![week1_question9](https://github.com/Chuntim0303/8-Week-SQL-Challenge/assets/126696701/7da662ba-780d-43bf-bcf3-4df15a289460)

***
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
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
Answer:

![week1_question10](https://github.com/Chuntim0303/8-Week-SQL-Challenge/assets/126696701/5f6737ed-57a2-4121-a5a4-b40f1aa6e484)
