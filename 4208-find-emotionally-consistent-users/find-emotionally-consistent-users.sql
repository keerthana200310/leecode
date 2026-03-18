# Write your MySQL query statement below
WITH total AS (
    SELECT user_id, COUNT(*) AS total_count
    FROM reactions
    GROUP BY user_id
),
freq AS (
    SELECT user_id, reaction, COUNT(*) AS cnt
    FROM reactions
    GROUP BY user_id, reaction
),
ranked AS (
    SELECT 
        f.user_id,
        f.reaction,
        f.cnt,
        t.total_count,
        ROW_NUMBER() OVER (PARTITION BY f.user_id ORDER BY f.cnt DESC) AS rn
    FROM freq f
    JOIN total t ON f.user_id = t.user_id
)
SELECT 
    user_id,
    reaction AS dominant_reaction,
    ROUND(cnt * 1.0 / total_count, 2) AS reaction_ratio
FROM ranked
WHERE rn = 1
  AND total_count >= 5
  AND cnt * 1.0 / total_count >= 0.6
ORDER BY reaction_ratio DESC, user_id ASC;