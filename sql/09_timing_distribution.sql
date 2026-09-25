-- Распределение времени между этапами последовательной воронки.
-- Пользователи разделяются на временные интервалы,
-- чтобы оценить, как быстро происходят переходы между этапами.


WITH user_item_events AS (
    SELECT
        visitorid,
        itemid,
        minIf(timestamp, event = 'view') AS first_view,
        minIf(timestamp, event = 'addtocart') AS first_cart,
        minIf(timestamp, event = 'transaction') AS first_transaction
    FROM events_raw
    GROUP BY
        visitorid,
        itemid
),

timing AS (
    SELECT
        dateDiff('minute', first_view, first_cart) AS view_to_cart_minutes,
        dateDiff('minute', first_cart, first_transaction) AS cart_to_transaction_minutes
    FROM user_item_events
    WHERE
        first_view IS NOT NULL
        AND first_cart IS NOT NULL
        AND first_transaction IS NOT NULL
        AND first_cart > first_view
        AND first_transaction > first_cart
),

bucketed AS (
    SELECT
        'View -> Cart' AS metric,
        multiIf(
            view_to_cart_minutes < 1, '0-1 min',
            view_to_cart_minutes < 5, '1-5 min',
            view_to_cart_minutes < 15, '5-15 min',
            view_to_cart_minutes < 60, '15-60 min',
            view_to_cart_minutes < 360, '1-6 h',
            view_to_cart_minutes < 1440, '6-24 h',
            '1+ day'
        ) AS time_bucket,
        multiIf(
            view_to_cart_minutes < 1, 1,
            view_to_cart_minutes < 5, 2,
            view_to_cart_minutes < 15, 3,
            view_to_cart_minutes < 60, 4,
            view_to_cart_minutes < 360, 5,
            view_to_cart_minutes < 1440, 6,
            7
        ) AS bucket_order
    FROM timing

    UNION ALL

    SELECT
        'Cart -> Transaction' AS metric,
        multiIf(
            cart_to_transaction_minutes < 1, '0-1 min',
            cart_to_transaction_minutes < 5, '1-5 min',
            cart_to_transaction_minutes < 15, '5-15 min',
            cart_to_transaction_minutes < 60, '15-60 min',
            cart_to_transaction_minutes < 360, '1-6 h',
            cart_to_transaction_minutes < 1440, '6-24 h',
            '1+ day'
        ) AS time_bucket,
        multiIf(
            cart_to_transaction_minutes < 1, 1,
            cart_to_transaction_minutes < 5, 2,
            cart_to_transaction_minutes < 15, 3,
            cart_to_transaction_minutes < 60, 4,
            cart_to_transaction_minutes < 360, 5,
            cart_to_transaction_minutes < 1440, 6,
            7
        ) AS bucket_order
    FROM timing
)

SELECT
    metric,
    time_bucket,
    bucket_order,
    count() AS paths,
    round(count() * 100.0 / sum(count()) OVER (PARTITION BY metric), 2) AS pct_of_metric
FROM bucketed
GROUP BY
    metric,
    time_bucket,
    bucket_order
ORDER BY
    metric,
    bucket_order;