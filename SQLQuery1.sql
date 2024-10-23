-- Basic:
--Retrieve the total number of orders placed.
select count(order_id) as total_orders
from orders

--Calculate the total revenue generated from pizza sales.
select cast(sum(od.quantity * p.price) as decimal(10,2)) as total_revenue 
from order_details od left join pizzas p
on od.pizza_id = p.pizza_id


--Identify the highest-priced pizza.
select  top 1 pt.name, cast(max(p.price) as decimal(10,2)) as highest_priced
from pizza_types pt join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
group by pt.name
order by highest_priced desc 

--Identify the most common pizza size ordered.
select p.size , count(od.order_details_id) as no_of_orders
from order_details od left join pizzas p
on od.pizza_id = p.pizza_id
group by p.size
order by no_of_orders desc

--List the top 5 most ordered pizza types along with their quantities.
select top 5 pt.name,sum(od.quantity) as no_of_quantity
from pizza_types pt join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details od 
on od.pizza_id = p.pizza_id
group by pt.name
order by no_of_quantity desc


--Intermediate:
--Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category,sum(od.quantity) as no_of_quantity
from pizza_types pt join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details od 
on od.pizza_id = p.pizza_id
group by pt.category
order by no_of_quantity desc

--Determine the distribution of orders by hour of the day.
select datepart(hour,time) as order_hour, count(order_id) as order_count
from orders
group by datepart(hour,time)
order by order_count desc

--Join relevant tables to find the category-wise distribution of pizzas.
select category , count(name) as total
from pizza_types
group by category

--Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(quantity) as avg_pizza_per_day
from
(select o.date,sum(od.quantity) as quantity
from orders o join order_details od
on o.order_id = od.order_id
group by o.date ) as subquery


--Determine the top 3 most ordered pizza types based on revenue.
select top 3 pt.name , cast(sum(od.quantity * p.price)as decimal(10,2)) as revenue
from pizza_types pt join pizzas p
on pt.pizza_type_id = p.pizza_type_id join order_details od 
on p.pizza_id = od.pizza_id
group by pt.name
order by revenue desc

--Advanced:
--Calculate the percentage contribution of each pizza type to total revenue.
select pt.category , cast(cast(sum(od.quantity * p.price) as decimal(10,2)) / (select cast(sum(od.quantity * p.price) as decimal(10,2)) from order_details od join pizzas p on od.pizza_id = p.pizza_id)*100  as decimal(10,2)) as revenue
from pizza_types pt join pizzas p
on pt.pizza_type_id = p.pizza_type_id join order_details od 
on p.pizza_id = od.pizza_id
group by pt.category
order by revenue desc

--Analyze the cumulative revenue generated over time.
select date,cast(sum(revenue) over(order by date)as decimal(10,2)) as cumulative_revenue
from
(select o.date, sum(od.quantity * p.price) as revenue
from order_details od join pizzas p
on od.pizza_id = p.pizza_id join orders o
on o.order_id = od.order_id
group by o.date) as subquery

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue 
from
(select category,name,revenue, rank() over(partition by category order by revenue desc) as rn
from
(select pt.category, pt.name, cast(sum(od.quantity * p.price)as decimal(10,2)) as revenue
from pizza_types pt join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on od.pizza_id = p.pizza_id
group by pt.category,pt.name) as subquery) as query
where rn <= 3;

