# Write your MySQL query statement below
SELECT 
    ip,
    COUNT(*) AS invalid_count
FROM logs
WHERE 
    -- ❌ Not exactly 4 parts
    ip NOT REGEXP '^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$'

    OR

    -- ❌ Leading zeros (01, 001)
    ip REGEXP '(^|\\.)0[0-9]+'

    OR

    -- ❌ Any part > 255
    ip NOT REGEXP '^(25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})(\\.(25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})){3}$'

GROUP BY ip
ORDER BY invalid_count DESC, ip DESC;