-- Анализ эффективности товарных категорий.
-- Сравниваются просмотры, добавления в корзину, покупки
-- и конверсия между этапами воронки.
-- Учитываются категории с достаточным объёмом трафика.


WITH item_categories AS (
    SELECT DISTINCT
        itemid,
        toInt64(value) AS categoryid
    FROM item_properties_raw
    WHERE property = 'categoryid'
),

category_metrics AS (
    SELECT
        c.categoryid,
        uniqExact(c.itemid) AS items,
        uniqExactIf(e.visitorid, e.event = 'view') AS view_users,
        uniqExactIf(e.visitorid, e.event = 'addtocart') AS cart_users,
        uniqExactIf(e.visitorid, e.event = 'transaction') AS transaction_users

    FROM events_raw AS e
    INNER JOIN item_categories AS c
        ON e.itemid = c.itemid

    GROUP BY c.categoryid
)

SELECT
    categoryid,
    items,
    view_users,
    cart_users,
    transaction_users,
    round(
        cart_users / nullIf(view_users, 0) * 100,
        2
    ) AS view_to_cart_rate,
    round(
        transaction_users / nullIf(cart_users, 0) * 100,
        2
    ) AS cart_to_transaction_rate,
    round(
        transaction_users / nullIf(view_users, 0) * 100,
        2
    ) AS view_to_transaction_rate

FROM category_metrics
WHERE view_users >= 1000
ORDER BY view_users DESC;
