
-- Q1 Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_orders
FROM
    orders;

-- Q.2 Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM((quantity * price)), 2) AS Total_revenue
FROM
    pizzas AS p
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id;


-- Q.3 Identify the highest-priced pizza.

SELECT 
    a.price, b.name
FROM
    pizzas AS a
        JOIN
    pizza_types AS b ON a.pizza_type_id = b.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Q.4 Identify the most common pizza size ordered.


SELECT 
    p.size, COUNT(order_details_id) AS Counts
FROM
    pizzas AS p
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id
GROUP BY size
ORDER BY counts DESC;

-- Q.5 List the top 5 most ordered pizza types along with their quantities.

SELECT 
    name, SUM(quantity) AS Quantity
FROM
    order_details AS a
        JOIN
    pizzas AS b ON a.pizza_id = b.pizza_id
        JOIN
    pizza_types AS c ON b.pizza_type_id = c.pizza_type_id
GROUP BY name
ORDER BY quantity DESC
LIMIT 5;

-- Q.6 Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT category, sum(quantity) as Quantity
FROM
    order_details AS a
        JOIN
    pizzas AS b ON a.pizza_id = b.pizza_id
        JOIN
    pizza_types AS c ON b.pizza_type_id = c.pizza_type_id
    group by category
    order by quantity desc;

-- Q.7 Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Hours, COUNT(order_id) AS Order_Counts
FROM
    orders
GROUP BY HOUR(order_time);

-- Q.8 Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(pizza_type_id) AS Counts
FROM
    pizza_types
GROUP BY category;

-- Q.9 Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS Avg_pizza_ordered_perday
FROM
    (SELECT 
        order_date AS Days, SUM(quantity) AS quantity
    FROM
        orders AS a
    JOIN order_details AS b ON a.order_id = b.order_id
    GROUP BY order_date) AS X;
    
-- Q.10 Determine the top 3 most ordered pizza types based on revenue.

select name, sum(c.quantity *b.price) as revenue
 from pizza_types as a
join pizzas as b
on a.pizza_type_id = b.pizza_type_id
join order_details as c
on b.pizza_id = c.pizza_id
group by name
order by revenue desc
limit 3;


-- Q.11 Calculate the percentage contribution of each pizza type to total revenue.

select category, (sum(c.quantity *b.price)/ (SELECT 
    ROUND(SUM((quantity * price)), 2) AS Total_revenue
FROM
    pizzas AS p
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id) )*100 as Revenue
 from pizza_types as a
join pizzas as b
on a.pizza_type_id = b.pizza_type_id
join order_details as c
on b.pizza_id = c.pizza_id
group by category
order by revenue;


-- Q.12 Analyze the cumulative revenue generated over time.

select order_date, sum(revenue)  over (order by order_date) as Cum_revenue
from 
(select order_date, 
sum(quantity*price) as Revenue from orders as a
join order_details as b
on a.order_id = b.order_id
join 
pizzas as c
on b.pizza_id = c.pizza_id
group by order_date) as sales;

-- Q.13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,name, revenue from 
(select category, name, revenue,
rank() over (partition by category order by revenue desc)as rn from
(select category, name,sum(c.quantity *b.price) as revenue
	 from pizza_types as a
	join pizzas as b
	on a.pizza_type_id = b.pizza_type_id
	join order_details as c
	on b.pizza_id = c.pizza_id
	group by category,name) as a) as b
    where rn <=3;
