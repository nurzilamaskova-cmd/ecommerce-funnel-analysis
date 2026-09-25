-- Общая воронка пользователей:
-- просмотр товара → добавление в корзину → покупка.
-- Считается количество уникальных пользователей на каждом этапе.


SELECT
    event AS stage,
    uniqExact(visitorid) AS users
FROM events_raw
WHERE event IN ('view', 'addtocart', 'transaction')
GROUP BY event
ORDER BY
    CASE event
        WHEN 'view' THEN 1
        WHEN 'addtocart' THEN 2
        WHEN 'transaction' THEN 3
    END;