-- Динамика конверсии воронки по месяцам.
-- Позволяет сравнить эффективность переходов между этапами
-- и увидеть изменения показателей во времени.


WITH monthly_users AS (
    SELECT
        toStartOfMonth(timestamp) AS month,
        visitorid,
        max(event = 'view') AS has_view,
        max(event = 'addtocart') AS has_cart,
        max(event = 'transaction') AS has_transaction

    FROM events_raw
    GROUP BY
        month,
        visitorid
)

SELECT
    month,
    uniqExactIf(visitorid, has_view = 1) AS view_users,
    uniqExactIf(
        visitorid,
        has_view = 1 AND has_cart = 1
    ) AS cart_users,
    uniqExactIf(
        visitorid,
        has_view = 1 AND has_cart = 1 AND has_transaction = 1
    ) AS transaction_users,
    round(
        cart_users / view_users * 100,
        2
    ) AS view_to_cart_rate,
    round(
        transaction_users / cart_users * 100,
        2
    ) AS cart_to_transaction_rate,
    round(transaction_users / view_users * 100,2) AS view_to_transaction_rate

FROM monthly_users
GROUP BY month
ORDER BY month;