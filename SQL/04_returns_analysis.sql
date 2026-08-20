-- # Compare the return rate between May and June 2026.
SELECT
    CASE
        WHEN o.OrderDate >= '2026-05-01'
         AND o.OrderDate < '2026-06-01'
        THEN 'MAY 2026'
 WHEN o.OrderDate >= '2026-06-01'
         AND o.OrderDate < '2026-07-01'
        THEN 'JUNE 2026'
    END AS month,
AVG(od.isReturned) AS return_rate
FROM orders AS o
INNER JOIN order_details AS od
USING (OrderID)
WHERE o.OrderDate >= '2026-05-01'
  AND o.OrderDate < '2026-07-01'
GROUP BY month
ORDER BY month;

-- # Identify products whose return rate increased from May to June 2026, ranked by the largest increase.
WITH returns_in_may AS (
    SELECT
        p.ProductID,
        p.ProductName,
        AVG(od.IsReturned) AS may_return_rate
    FROM products AS p
    INNER JOIN order_details AS od
        USING (ProductID)
    INNER JOIN orders AS o
        USING (OrderID)
    WHERE o.OrderDate >= '2026-05-01'
      AND o.OrderDate < '2026-06-01'
    GROUP BY
        p.ProductID,
        p.ProductName
),
returns_in_june AS (
    SELECT
        p.ProductID,
        AVG(od.IsReturned) AS june_return_rate
    FROM products AS p
    INNER JOIN order_details AS od
        USING (ProductID)
    INNER JOIN orders AS o
        USING (OrderID)
    WHERE o.OrderDate >= '2026-06-01'
      AND o.OrderDate < '2026-07-01'
    GROUP BY
        p.ProductID
)
SELECT
    m.ProductID,
    m.ProductName,
    m.may_return_rate,
    COALESCE(j.june_return_rate,0) AS june_return_rate,
    COALESCE(j.june_return_rate,0)
        - m.may_return_rate
        AS return_rate_change,
    CASE
        WHEN COALESCE(j.june_return_rate,0) > m.may_return_rate
            THEN 'Higher Return Rate'
        WHEN COALESCE(j.june_return_rate,0) < m.may_return_rate
            THEN 'Lower Return Rate'
        ELSE 'No Change'
    END AS performance
FROM returns_in_may AS m
LEFT JOIN returns_in_june AS j
USING (ProductID)
WHERE COALESCE(j.june_return_rate,0) > m.may_return_rate
ORDER BY return_rate_change DESC;
 