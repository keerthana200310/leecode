# Write your MySQL query statement below
SELECT 
    product_id,
    COALESCE(new_price, 10) AS price
FROM (
    SELECT 
        product_id,
        new_price,
        ROW_NUMBER() OVER (
            PARTITION BY product_id 
            ORDER BY change_date DESC
        ) AS rn
    FROM Products
    WHERE change_date <= '2019-08-16'
) t
WHERE rn = 1

UNION

SELECT DISTINCT product_id, 10
FROM Products
WHERE product_id NOT IN (
    SELECT product_id
    FROM Products
    WHERE change_date <= '2019-08-16'
);