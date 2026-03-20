# Write your MySQL query statement below
WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_date DESC) AS rn
    FROM subscription_events
),
agg AS (
    SELECT 
        user_id,
        MIN(event_date) AS first_date,
        MAX(event_date) AS last_date,
        MAX(monthly_amount) AS max_amount,
        SUM(CASE WHEN event_type = 'downgrade' THEN 1 ELSE 0 END) AS downgrade_count
    FROM subscription_events
    GROUP BY user_id
)
SELECT 
    r.user_id,
    r.plan_name AS current_plan,
    r.monthly_amount AS current_monthly_amount,
    a.max_amount AS max_historical_amount,
    DATEDIFF(a.last_date, a.first_date) AS days_as_subscriber
FROM ranked r
JOIN agg a 
    ON r.user_id = a.user_id
WHERE r.rn = 1                          -- latest event
  AND r.event_type != 'cancel'          -- active
  AND a.downgrade_count > 0             -- has downgrade
  AND r.monthly_amount < 0.5 * a.max_amount
  AND DATEDIFF(a.last_date, a.first_date) >= 60
ORDER BY days_as_subscriber DESC, r.user_id ASC;