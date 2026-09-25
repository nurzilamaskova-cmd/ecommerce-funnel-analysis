-- Анализ последовательного пути пользователя для конкретного товара.
-- Проверяется порядок действий: просмотр → корзина → покупка.
-- Это позволяет отделить реальные последовательные пути от отдельных событий. 


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
)

SELECT
    countIf(
        first_view IS NOT NULL
        AND first_cart IS NOT NULL
        AND first_cart > first_view
    ) AS view_to_cart_paths,

    countIf(
        first_view IS NOT NULL
        AND first_cart IS NOT NULL
        AND first_transaction IS NOT NULL
        AND first_cart > first_view
        AND first_transaction > first_cart
    ) AS successful_paths
FROM user_item_events;