-- Когортный анализ пользователей по месяцу первой активности.
-- Retention показывает долю пользователей когорты,
-- которые возвращались и проявляли активность в последующие месяцы.


WITH first_activity AS (
    SELECT
        visitorid,
        toStartOfMonth(min(timestamp)) AS cohort_month
    FROM events_raw
    GROUP BY visitorid
),

cohort_size AS (
    SELECT
        cohort_month,
        uniqExact(visitorid) AS cohort_users
    FROM first_activity
    GROUP BY cohort_month
),

user_activity AS (
    SELECT DISTINCT
        visitorid,
        toStartOfMonth(timestamp) AS activity_month
    FROM events_raw
),

cohort_activity AS (
    SELECT
        fa.cohort_month,
        dateDiff(
            'month',
            fa.cohort_month,
            ua.activity_month
        ) AS month_number,
        uniqExact(fa.visitorid) AS active_users
    FROM first_activity AS fa
    JOIN user_activity AS ua
        ON fa.visitorid = ua.visitorid
    GROUP BY
        fa.cohort_month,
        month_number
)

SELECT
    ca.cohort_month,
    ca.month_number,
    cs.cohort_users,
    ca.active_users,
    round(
        ca.active_users / cs.cohort_users * 100,
        2
    ) AS retention_rate
FROM cohort_activity AS ca
JOIN cohort_size AS cs
    ON ca.cohort_month = cs.cohort_month
ORDER BY
    ca.cohort_month,
    ca.month_number;