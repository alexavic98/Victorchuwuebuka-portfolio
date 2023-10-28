CREATE SCHEMA dannys_diner;
use dannys_diner;
CREATE TABLE sales (customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

/*1. What is the total amount each customer spent at the restaurant?*/
SELECT customer_id, sum(price) as Amount_spent
FROM menu m JOIN sales ON m.product_id = sales.product_id 
GROUP BY customer_id;

/*2. How many days has each customer visited the restaurant?*/
SELECT customer_id, count(distinct order_date) AS no_of_days_visited
FROM sales
GROUP BY customer_id;

/*3. What was the first item from the menu purchased by each customer?*/
SELECT sales.customer_id, min(order_date) as first_date_visited, menu.product_name
FROM menu JOIN sales on menu.product_id = sales.product_id
GROUP BY customer_id, product_name
ORDER BY first_date_visited;

/* 4 What is the most purchased item on the menu and how many times was it purchased by all customers?*/
SELECT menu.product_name, count(sales.product_id) as no_of_times_purchased
FROM sales join menu on sales.product_id = menu.product_id
GROUP BY product_name
ORDER BY no_of_times_purchased DESC;

/* 5  Which item was the most popular for each customer?*/
SELECT customer_id, product_name, max(purchases) as purchase_count 
FROM 	(SELECT customer_id, product_name, count(sales.product_id) AS purchases
FROM sales join menu on sales.product_id = menu.product_id
GROUP BY product_name, customer_id) as subquery
GROUP BY customer_id,product_name
ORDER BY purchase_count desc;

/* 6 Which item was purchased first by the customer after they became a member?*/
SELECT sales.customer_id, product_name, members.join_date as date_joined
FROM sales join menu on sales.product_id = menu.product_id
join members on sales.customer_id = members.customer_id
WHERE order_date >= join_date
ORDER BY customer_id, join_date;

/* 7 Which item was purchased just before the customer became a member?*/
SELECT sales.customer_id, order_date, sales.product_id, product_name  
FROM members join sales on members.customer_id = sales.customer_id
join menu on menu.product_id = sales.product_id
WHERE sales.order_date < members.join_date;

/* 8 What is the total items and amount spent for each member before they became a member?*/
SELECT distinct sales.customer_id, count(sales.product_id) as products, sum(price) as amount_spent 
FROM members join sales on members.customer_id = sales.customer_id
join menu on menu.product_id = sales.product_id
WHERE sales.order_date < members.join_date
GROUP BY sales.customer_id;

/* 9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?*/
SELECT sales.customer_id, sum(case when product_name = "sushi" then 2 * price * 10 else price * 10 End) as points
FROM sales join menu on sales.product_id = menu.product_id
GROUP BY customer_id;
/* 10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?*/
WITH joined_and_joined_week AS (
  SELECT m.customer_id, m.join_date, DATE_ADD(m.join_date, INTERVAL 7 DAY) AS end_of_joined_week
  FROM members m
),
points_earned AS (
  SELECT s.customer_id, s.order_date, menu.product_name,
         CASE WHEN s.order_date BETWEEN j.join_date AND j.end_of_joined_week THEN 2 * menu.price * 10 ELSE menu.price * 10 END AS points_earned
  FROM sales s
  JOIN menu ON s.product_id = menu.product_id
  JOIN joined_and_joined_week j ON s.customer_id = j.customer_id
)
SELECT customer_id, SUM(points_earned) AS total_points_at_end_of_january
FROM points_earned
WHERE order_date <= '2021-01-31'
GROUP BY customer_id
ORDER BY customer_id;

