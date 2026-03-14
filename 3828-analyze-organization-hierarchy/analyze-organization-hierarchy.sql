# Write your MySQL query statement below
WITH RECURSIVE hierarchy AS (
    -- Step 1: CEO level
    SELECT 
        employee_id,
        employee_name,
        manager_id,
        salary,
        1 AS level
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Step 2: find next levels
    SELECT 
        e.employee_id,
        e.employee_name,
        e.manager_id,
        e.salary,
        h.level + 1
    FROM Employees e
    JOIN hierarchy h
    ON e.manager_id = h.employee_id
),

subordinates AS (
    -- find all subordinates recursively
    SELECT 
        manager_id AS manager,
        employee_id,
        salary
    FROM Employees
    WHERE manager_id IS NOT NULL

    UNION ALL

    SELECT 
        s.manager,
        e.employee_id,
        e.salary
    FROM subordinates s
    JOIN Employees e
    ON e.manager_id = s.employee_id
)

SELECT
    h.employee_id,
    h.employee_name,
    h.level,
    COUNT(s.employee_id) AS team_size,
    h.salary + COALESCE(SUM(s.salary),0) AS budget
FROM hierarchy h
LEFT JOIN subordinates s
ON h.employee_id = s.manager
GROUP BY h.employee_id, h.employee_name, h.level, h.salary
ORDER BY level ASC, budget DESC, employee_name ASC;