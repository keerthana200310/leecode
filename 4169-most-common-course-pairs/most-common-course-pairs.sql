WITH top_users AS (
    SELECT user_id
    FROM course_completions
    GROUP BY user_id
    HAVING COUNT(*) >= 5 AND AVG(course_rating) >= 4
),
ordered AS (
    SELECT 
        user_id,
        course_name,
        completion_date,
        LEAD(course_name) OVER (
            PARTITION BY user_id 
            ORDER BY completion_date
        ) AS next_course
    FROM course_completions
    WHERE user_id IN (SELECT user_id FROM top_users)
)
SELECT 
    course_name AS first_course,
    next_course AS second_course,
    COUNT(*) AS transition_count
FROM ordered
WHERE next_course IS NOT NULL
GROUP BY course_name, next_course
ORDER BY transition_count DESC, first_course ASC, second_course ASC;