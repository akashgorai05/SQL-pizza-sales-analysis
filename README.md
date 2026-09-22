# 🍕 Pizza Sales Analysis - SQL Project

## 📌 Project Overview
This project analyzes transactional sales records for a pizza business using SQL. The goal is to uncover revenue trends, analyze customer ordering patterns, and evaluate pizza category performance to support data-driven business decisions.

---

## 🛠️ Tools & Technologies Used
- **Database Management System:** PostgreSQL
- **Query Tool/IDE:** pgAdmin 4
- **Language:** SQL (Window Functions, Aggregations, Date/Time Functions, CTEs, Joins)

---

## 📊 Business Questions Solved
- **Order & Revenue Metrics:** Calculated total orders placed, overall revenue, and average order value (AOV).
- **Menu Performance:** Identified the top 5 highest-revenue pizzas and the bottom-performing menu items.
- **Category & Size Analysis:** Determined order distribution across pizza categories (Classic, Veggie, Supreme, Chicken) and size variations.
- **Operational Rush Hours:** Extracted hourly and daily order distributions to pinpoint peak dining hours.
- **Cumulative Revenue:** Tracked daily revenue growth over time using SQL window functions.

---

## 💻 SQL Queries & solution
### Q1: Calculate the total revenue generated from pizza sales?
```sql
SELECT round(sum(od.quantity * p.price):: numeric, 2) AS total_revenue
FROM order_details AS od
JOIN pizzas AS p ON od.pizza_id=p.pizza_id;
```
### Q2: List the top 5 most ordered pizza types along with their quantities?
```sql
SELECT pt.name,
       sum(od.quantity)
FROM order_details AS od
JOIN pizzas AS p ON p.pizza_id=od.pizza_id
JOIN pizza_types AS pt ON pt.pizza_type_id=p.pizza_type_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```
### Q3: Determine the distribution of orders by hour of the day?
```sql
SELECT extract(HOUR
               FROM TIME) AS HOUR,
       count(order_id) AS order_count
FROM orders
GROUP BY 1
ORDER BY 1;
```
### Q4: Group the orders by date and calculate the average number of pizzas ordered per day?
```sql
SELECT round(avg(total_quantity), 0) AS avg_pizza_per_day
FROM
  (SELECT o.date AS date,
          sum(od.quantity) AS total_quantity
   FROM orders AS o
   JOIN order_details AS od ON o.order_id=od.order_id
   GROUP BY 1) AS daily_orders;
```
### Q5: Determine the top 3 most ordered pizza types based on revenue?
```sql
SELECT round(sum(od.quantity*p.price)::numeric, 2) AS revenue,
       pt.name
FROM order_details AS od
JOIN pizzas AS p ON od.pizza_id=p.pizza_id
JOIN pizza_types AS pt ON p.pizza_type_id=pt.pizza_type_id
GROUP BY 2
ORDER BY 1 DESC
LIMIT 3;
```
### Q6: Calculate the percentage contribution of each pizza type to total revenue?
```sql
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
```
### Q7: Determine the top 3 most ordered pizza types based on revenue for each pizza category?
```sql
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
```
---
## 🔍 Key Insights
1. Large-sized pizzas account for the majority of total sales revenue.
2. Order volumes peak noticeably during evening hours and weekend shifts.
3. The Classic category drives the highest overall customer order frequency.
