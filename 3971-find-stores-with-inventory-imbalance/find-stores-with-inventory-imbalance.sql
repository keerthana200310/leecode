WITH ranked AS (
    SELECT 
        s.store_id,
        s.store_name,
        s.location,
        i.product_name,
        i.quantity,
        i.price,
        ROW_NUMBER() OVER (PARTITION BY s.store_id ORDER BY i.price DESC) AS rn_exp,
        ROW_NUMBER() OVER (PARTITION BY s.store_id ORDER BY i.price ASC) AS rn_cheap,
        COUNT(*) OVER (PARTITION BY s.store_id) AS product_count
    FROM stores s
    JOIN inventory i 
        ON s.store_id = i.store_id
)
SELECT 
    store_id,
    store_name,
    location,
    MAX(CASE WHEN rn_exp = 1 THEN product_name END) AS most_exp_product,
    MAX(CASE WHEN rn_cheap = 1 THEN product_name END) AS cheapest_product,
    ROUND(
        MAX(CASE WHEN rn_cheap = 1 THEN quantity END) * 1.0 /
        MAX(CASE WHEN rn_exp = 1 THEN quantity END), 
        2
    ) AS imbalance_ratio
FROM ranked
GROUP BY store_id, store_name, location, product_count
HAVING 
    product_count >= 3
    AND MAX(CASE WHEN rn_exp = 1 THEN quantity END) 
        < MAX(CASE WHEN rn_cheap = 1 THEN quantity END)
ORDER BY imbalance_ratio DESC, store_name ASC;