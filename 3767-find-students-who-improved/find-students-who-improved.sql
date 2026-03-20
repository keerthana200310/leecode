# Write your MySQL query statement below
WITH ranked AS (
    SELECT 
        student_id,
        subject,
        score,
        exam_date,
        ROW_NUMBER() OVER (PARTITION BY student_id, subject ORDER BY exam_date) AS rn_first,
        ROW_NUMBER() OVER (PARTITION BY student_id, subject ORDER BY exam_date DESC) AS rn_last,
        COUNT(*) OVER (PARTITION BY student_id, subject) AS cnt
    FROM Scores
)
SELECT 
    f.student_id,
    f.subject,
    f.score AS first_score,
    l.score AS latest_score
FROM ranked f
JOIN ranked l
ON f.student_id = l.student_id AND f.subject = l.subject
WHERE f.rn_first = 1
  AND l.rn_last = 1
  AND f.cnt >= 2
  AND l.score > f.score
ORDER BY f.student_id, f.subject;