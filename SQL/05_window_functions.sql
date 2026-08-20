-- # Identify the top 10 customers by revenue for each month in May and June 2026.
WITH customer_monthly_revenue AS (
    SELECT
        CASE
            WHEN o.OrderDate >= '2026-05-01'
             AND o.OrderDate < '2026-06-01'
                THEN 'MAY 2026'
            WHEN o.OrderDate >= '2026-06-01'
             AND o.OrderDate < '2026-07-01'
                THEN 'JUNE 2026'
        END AS month,
o.CustomerID,
SUM(od.UnitPrice * od.Quantity) AS revenue
FROM orders AS o
    INNER JOIN order_details AS od
        USING (OrderID)
        WHERE o.OrderDate >= '2026-05-01'
      AND o.OrderDate < '2026-07-01'
       GROUP BY
        month,
        o.CustomerID
),
ranked_customers AS (
    SELECT
        month,
        CustomerID,
        revenue,

        RANK() OVER (
            PARTITION BY month
            ORDER BY revenue DESC
        ) AS customer_rank

    FROM customer_monthly_revenue
    )
SELECT
    month,
    CustomerID,
    revenue,
    customer_rank
FROM ranked_customers
WHERE customer_rank <= 10
ORDER BY
    month,
    customer_rank;

-- # Display each customer's orders alongside the date of their previous order.
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    LAG(OrderDate) OVER(
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS previous_order
FROM orders
ORDER BY CustomerID, OrderDate;


-- # Calculate the time between each customer's current order and their previous order.
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    LAG(OrderDate) OVER(
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS previous_order,
    OrderDate -
    LAG(OrderDate) OVER(
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS days_between_orders
FROM orders;

-- # Calculate each customer's cumulative revenue over time after every order.
WITH total_revenue_each_customer AS (
    SELECT
        o.CustomerID,
        o.OrderID,
        o.OrderDate,
        SUM(od.UnitPrice * od.Quantity) AS order_revenue
    FROM orders AS o
    INNER JOIN order_details AS od
        USING (OrderID)
    GROUP BY
        o.CustomerID,
        o.OrderID,
        o.OrderDate
)
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    order_revenue,
    SUM(order_revenue) OVER (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS cumulative_revenue
FROM total_revenue_each_customer
ORDER BY
    CustomerID,
    OrderDate;


-- # Compare each customer's current order revenue with the revenue from their previous order.
    SELECT c.CustomerID,
       o.OrderID,
       o.OrderDate,
       SUM(od.UnitPrice * od.Quantity) AS current_order_revenue,
       LAG(SUM(od.UnitPrice * od.Quantity)) OVER(
       PARTITION BY c.CustomerID
       ORDER BY o.OrderDate
       ) AS previous_order_revenue
FROM customers AS c 
INNER JOIN orders AS o
USING(CustomerID) 
INNER JOIN order_details AS od
USING(OrderID)
GROUP BY c.CustomerID,o.OrderID, o.OrderDate;
    