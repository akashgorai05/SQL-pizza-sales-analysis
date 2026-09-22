CREATE TABLE pizzas(pizza_id varchar(30) PRIMARY KEY,
				   pizza_type_id varchar(30),
				   SIZE text, price float);
CREATE TABLE pizza_types(pizza_type_id text PRIMARY KEY,
						name text, category text, ingredients text);
CREATE TABLE orders(order_id int PRIMARY KEY, date date, TIME TIME);
CREATE TABLE order_details(order_details_id int PRIMARY KEY,
							order_id int, pizza_id varchar(30),
					       	quantity int);
SELECT *
FROM pizza_types;

SELECT *
FROM pizzas;

SELECT *
FROM orders;

SELECT *
FROM order_details;

--Q1: Retrieve the total number of orders placed?

SELECT count(order_id) AS total_orders
FROM orders;

--Q2: Calculate the total revenue generated from pizza sales?

SELECT round(sum(od.quantity * p.price):: numeric, 2) AS total_revenue
FROM order_details AS od
JOIN pizzas AS p ON od.pizza_id=p.pizza_id;

--Q3: Identify the highest-priced pizza?

SELECT pt.name,
       p.size,
       p.price
FROM pizzas AS p
JOIN pizza_types AS pt ON p.pizza_type_id=pt.pizza_type_id
ORDER BY 3 DESC
LIMIT 1;

--Q4: Identify the most common pizza size ordered?

SELECT p.size,
       count(od.quantity)
FROM order_details AS od
JOIN pizzas AS p ON p.pizza_id=od.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

--Q5: List the top 5 most ordered pizza types along with their quantities?

SELECT pt.name,
       sum(od.quantity)
FROM order_details AS od
JOIN pizzas AS p ON p.pizza_id=od.pizza_id
JOIN pizza_types AS pt ON pt.pizza_type_id=p.pizza_type_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--Q6: Join the necessary tables to find the total quantity of each pizza category ordered?

SELECT pt.category,
       sum(od.quantity)
FROM order_details AS od
JOIN pizzas AS p ON p.pizza_id=od.pizza_id
JOIN pizza_types AS pt ON pt.pizza_type_id=p.pizza_type_id
GROUP BY 1
ORDER BY 2 DESC;

--Q7: Determine the distribution of orders by hour of the day?

SELECT extract(HOUR
               FROM TIME) AS HOUR,
       count(order_id) AS order_count
FROM orders
GROUP BY 1
ORDER BY 1;

--Q8: Join relevant tables to find the category-wise distribution of pizzas?

SELECT category,
       count(name) AS types_of_pizza
FROM pizza_types
GROUP BY 1
ORDER BY 2 DESC;

--Q9: Group the orders by date and calculate the average number of pizzas ordered per day?

SELECT round(avg(total_quantity), 0) AS avg_pizza_per_day
FROM
  (SELECT o.date AS date,
          sum(od.quantity) AS total_quantity
   FROM orders AS o
   JOIN order_details AS od ON o.order_id=od.order_id
   GROUP BY 1) AS daily_orders;

--Q10: Determine the top 3 most ordered pizza types based on revenue?

SELECT round(sum(od.quantity*p.price)::numeric, 2) AS revenue,
       pt.name
FROM order_details AS od
JOIN pizzas AS p ON od.pizza_id=p.pizza_id
JOIN pizza_types AS pt ON p.pizza_type_id=pt.pizza_type_id
GROUP BY 2
ORDER BY 1 DESC
LIMIT 3;

--Q11: Calculate the percentage contribution of each pizza type to total revenue?

SELECT pt.name,
       round((sum(p.price*od.quantity) * 100 /
                (SELECT sum(p.price*od.quantity)
                 FROM order_details AS od
                 JOIN pizzas AS p ON p.pizza_id=od.pizza_id))::numeric, 2) AS percentage_contribution
FROM order_details AS od
JOIN pizzas AS p ON p.pizza_id=od.pizza_id
JOIN pizza_types AS pt ON p.pizza_type_id=pt.pizza_type_id
GROUP BY 1
ORDER BY 2 DESC;

--Q12: Analyze the cumulative revenue generated over time?

SELECT date, round(sum(revenue) OVER (
                                      ORDER BY date):: numeric, 2) AS cum_revenue
FROM
  (SELECT o.date,
          sum(od.quantity*p.price) AS revenue
   FROM order_details AS od
   JOIN pizzas AS p ON p.pizza_id=od.pizza_id
   JOIN orders AS o ON o.order_id=od.order_id
   GROUP BY 1) AS daily_sales;

--Q13: Determine the top 3 most ordered pizza types based on revenue for each pizza category?
 WITH ranked_pizzas AS
  (SELECT pt.category,
          pt.name,
          round(sum(od.quantity*p.price)::numeric, 2) AS revenue,
          rank() over(PARTITION BY pt.category
                      ORDER BY sum(od.quantity*p.price)DESC)AS rn
   FROM order_details AS od
   JOIN pizzas AS p ON p.pizza_id=od.pizza_id
   JOIN pizza_types AS pt ON pt.pizza_type_id=p.pizza_type_id
   GROUP BY 1,
            2)
SELECT category,
       name,
       revenue
FROM ranked_pizzas
WHERE rn=1;