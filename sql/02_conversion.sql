-- Расчёт конверсии между основными этапами воронки.
-- Показывает, какая доля пользователей переходит
-- от просмотра к корзине и от корзины к покупке.


WITH funnel AS (
    SELECT
        uniqExactIf(visitorid, event = 'view') AS views,
        uniqExactIf(visitorid, event = 'addtocart') AS carts,
        uniqExactIf(visitorid, event = 'transaction') AS transactions
    FROM events_raw
)

SELECT
    'View → Add to Cart' AS conversion,
    round(carts / views * 100, 2) AS conversion_rate
FROM funnel

UNION ALL

SELECT
    'Add to Cart → Transaction' AS conversion,
    round(transactions / carts * 100, 2) AS conversion_rate
FROM funnel

UNION ALL

SELECT
    'View → Transaction' AS conversion,
    round(transactions / views * 100, 2) AS conversion_rate
FROM funnel;