-- # Identify all unique customers who placed an order in either May or June 2026.
SELECT DISTINCT CustomerID
FROM orders
WHERE OrderDate >= '2026-05-01'
  AND OrderDate < '2026-06-01'
UNION
SELECT DISTINCT CustomerID
FROM orders
WHERE OrderDate >= '2026-06-01'
  AND OrderDate < '2026-07-01'
ORDER BY CustomerID;


-- # Identify customers who placed orders in both May and June 2026.
SELECT CustomerID
FROM orders
WHERE OrderDate >= '2026-05-01'
  AND OrderDate < '2026-06-01'
INTERSECT
SELECT CustomerID
FROM orders
WHERE OrderDate >= '2026-06-01'
  AND OrderDate < '2026-07-01'
ORDER BY CustomerID;

-- # Identify customers who placed orders in June 2026 but did not place any orders in May 2026.
SELECT CustomerID
FROM orders
WHERE OrderDate >= '2026-06-01'
  AND OrderDate < '2026-07-01'
EXCEPT
SELECT CustomerID
FROM orders
WHERE OrderDate >= '2026-05-01'
  AND OrderDate < '2026-06-01';
