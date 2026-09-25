-- Анализ времени между последовательными этапами воронки.
-- Рассчитывается время от просмотра до корзины и от корзины до покупки.
-- Для сравнения используются среднее и медианное значения.


WITH user_paths AS (
    SELECT
        visitorid,
        itemid,
        minIf(timestamp, event = 'view') AS view_time,
        minIf(timestamp, event = 'addtocart') AS cart_time,
        minIf(timestamp, event = 'transaction') AS transaction_time
    FROM events_raw
    GROUP BY
        visitorid,
        itemid
),

successful_paths AS (
    SELECT
        dateDiff('second', view_time, cart_time) / 60.0
            AS view_to_cart_min,

        dateDiff('second', cart_time, transaction_time) / 60.0
            AS cart_to_transaction_min
    FROM user_paths
    WHERE
        view_time IS NOT NULL
        AND cart_time IS NOT NULL
        AND transaction_time IS NOT NULL
        AND view_time < cart_time
        AND cart_time < transaction_time
)

SELECT
    round(avg(view_to_cart_min), 2) AS avg_view_to_cart,
    round(median(view_to_cart_min), 2) AS median_view_to_cart,
    round(avg(cart_to_transaction_min), 2) AS avg_cart_to_transaction,
    round(median(cart_to_transaction_min), 2) AS median_cart_to_transaction
FROM successful_paths;