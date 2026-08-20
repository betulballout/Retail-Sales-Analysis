SELECT customerID,
       COUNT(orderID)
FROM orders
GROUP BY customerID;

-- # Identify customers who have never placed an order.
SELECT c.CustomerID,
       o.OrderID
FROM customers AS c
LEFT JOIN orders AS o
USING(CustomerID)
WHERE OrderID IS NULL;


-- # Identify customers who have placed more than five orders.
SELECT c.CustomerID,
       COUNT(o.OrderID) AS Order_num
FROM customers AS c
LEFT JOIN orders AS o
USING(CustomerID)
GROUP BY CustomerID
HAVING COUNT(o.OrderID) > 5;

-- # Identify the top five customers who generated the highest total revenue.
SELECT o.CustomerID,
       SUM(od.UnitPrice * od.Quantity) AS revenue
FROM orders AS o
INNER JOIN order_details AS od
USING(OrderID)
GROUP BY CustomerID
ORDER BY revenue DESC
LIMIT 5;

-- # Identify customers who placed at least five orders and generated more than $20,000 in total revenue, ranked by revenue.
SELECT c.CustomerID,
       COUNT(o.OrderID) AS total_orders,
       SUM(od.UnitPrice * od.Quantity) AS total_revenue
FROM customers AS c
INNER JOIN orders AS o
USING(CustomerID)
INNER JOIN order_details AS od
USING(OrderID)
GROUP BY c.CustomerID 
HAVING total_orders >=5
AND total_revenue > 20000
ORDER BY total_revenue DESC;

-- # Calculate each customer's total number of orders, total revenue, and average order value, ranked by average order value.
SELECT
    sub.CustomerID,
    COUNT(sub.OrderID) AS order_count,
    SUM(sub.OrderValue) AS total_revenue,
    AVG(sub.OrderValue) AS orders_value_average
FROM (
    SELECT
        o.CustomerID,
        o.OrderID,
        SUM(od.UnitPrice * od.Quantity) AS OrderValue
    FROM orders AS o
    INNER JOIN order_details AS od
        USING (OrderID)
    GROUP BY o.CustomerID, o.OrderID
) AS sub
GROUP BY sub.CustomerID
ORDER BY orders_value_average DESC;

-- # Identify customers who purchased products from at least three different categories, ranked by the number of categories purchased.
SELECT o.CustomerID,
       COUNT(DISTINCT c.CategoryID )AS category_num
FROM orders AS o
INNER JOIN order_details AS od
USING(OrderID)
INNER JOIN products AS p
USING(ProductID)
INNER JOIN categories AS c
USING(CategoryID)
GROUP BY CustomerID
HAVING category_num >= 3
ORDER BY category_num DESC ;

-- # Identify the top five customers with the highest average order revenue.
SELECT sub.CustomerID,
       AVG(sub.revenue) AS avg_order_revenue
FROM(
SELECT o.OrderID,
       c.CustomerID,
       SUM(od.UnitPrice * od.Quantity) AS revenue
FROM customers AS c 
INNER JOIN orders AS o
USING(CustomerID)
INNER JOIN order_details AS od
USING(OrderID)
GROUP BY o.OrderID,c.CustomerID) AS sub
INNER JOIN customers AS c
USING(CustomerID)
GROUP BY sub.CustomerID 
ORDER BY avg_order_revenue DESC
LIMIT 5;


-- # Identify customers who have purchased products from every available product category.
SELECT
    o.CustomerID,
    COUNT(DISTINCT p.CategoryID) AS categories_num
FROM orders AS o
INNER JOIN order_details AS od
    USING (OrderID)
INNER JOIN products AS p
    USING (ProductID)
GROUP BY o.CustomerID
HAVING COUNT(DISTINCT p.CategoryID) =
(
    SELECT COUNT(*)
    FROM categories
);

-- # Identify customers who purchased from more product categories than the average customer.
WITH customer_categories AS (
    SELECT c.CustomerID,
           COUNT(DISTINCT p.CategoryID) AS category_count
    FROM customers AS c
    INNER JOIN orders AS o
        ON c.CustomerID = o.CustomerID
    INNER JOIN order_details AS od
        ON o.OrderID = od.OrderID
    INNER JOIN products AS p
        ON od.ProductID = p.ProductID
    GROUP BY c.CustomerID
)
SELECT CustomerID,
       category_count
FROM customer_categories
WHERE category_count > (
    SELECT AVG(category_count)
    FROM customer_categories
);

-- # Identify customers who have purchased from all but one of the available product categories.
SELECT c.CustomerID,
       COUNT(DISTINCT p.CategoryID) AS categories
FROM customers AS c
INNER JOIN orders AS o 
USING(CustomerID)
INNER JOIN order_details AS od
USING(OrderID)
INNER JOIN products AS p
USING(ProductID)
GROUP BY c.CustomerID 
HAVING categories + 1 = (
SELECT COUNT(*)
FROM categories);


-- # Compare customer sign-ups and order activity across May and June 2026.
SELECT
    c.CustomerID,
    c.SignUpDate,
    o.OrderDate,
    CASE
        WHEN c.SignUpDate >= '2026-06-01'
             AND c.SignUpDate < '2026-07-01'
            THEN 'JUNE NEW CUSTOMER'
        WHEN c.SignUpDate >= '2026-05-01'
             AND c.SignUpDate < '2026-06-01'
            THEN 'MAY NEW CUSTOMER'
    END AS signup_month,
 CASE
        WHEN o.OrderDate >= '2026-06-01'
             AND o.OrderDate < '2026-07-01'
            THEN 'JUNE ORDER'
        WHEN o.OrderDate >= '2026-05-01'
             AND o.OrderDate < '2026-06-01'
            THEN 'MAY ORDER'
    END AS order_month
FROM customers AS c
LEFT JOIN orders AS o
    USING (CustomerID)
WHERE
      (c.SignUpDate >= '2026-05-01' AND c.SignUpDate < '2026-07-01')
   OR (o.OrderDate  >= '2026-05-01' AND o.OrderDate  < '2026-07-01')
ORDER BY o.OrderDate, c.SignUpDate DESC;


-- # Compare the number of active customers between May and June 2026.
SELECT
    CASE
        WHEN OrderDate >= '2026-05-01'
             AND OrderDate < '2026-06-01'
            THEN 'MAY 2026'
        WHEN OrderDate >= '2026-06-01'
             AND OrderDate < '2026-07-01'
            THEN 'JUNE 2026'
    END AS month,
    COUNT(DISTINCT CustomerID) AS active_customers
FROM orders
WHERE OrderDate >= '2026-05-01'
  AND OrderDate < '2026-07-01'
GROUP BY month
ORDER BY month;

-- # Identify customers whose revenue decreased from May to June 2026.
WITH revenue_in_may AS (
 SELECT
        c.CustomerID,
        SUM(od.UnitPrice * Quantity) AS may_revenue
    FROM customers AS c
    INNER JOIN orders AS o
        USING (CustomerID)
    INNER JOIN order_details AS od
        USING (OrderID)
    WHERE o.OrderDate >= '2026-05-01'
      AND o.OrderDate < '2026-06-01'
    GROUP BY CustomerID  
),
revenue_in_june AS (
SELECT
           c.CustomerID,
        SUM(od.UnitPrice * Quantity) AS june_revenue
    FROM customers AS c
    INNER JOIN orders AS o
        USING (CustomerID)
    INNER JOIN order_details AS od
        USING (OrderID)
    WHERE o.OrderDate >= '2026-06-01'
      AND o.OrderDate < '2026-07-01'
    GROUP BY CustomerID  
)
SELECT
    m.CustomerID,
    m.may_revenue,
    j.june_revenue
FROM revenue_in_may AS m
INNER JOIN revenue_in_june AS j
    USING (CustomerID)
WHERE m.may_revenue >j.june_revenue;

