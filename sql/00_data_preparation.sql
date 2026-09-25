-- Подготовка таблиц ClickHouse для дальнейшего анализа.
-- Используются данные о событиях пользователей, товарах
-- и категориях из датасета RetailRocket.


CREATE TABLE events_raw
(
    timestamp DateTime64(3),
    visitorid UInt64,
    event String,
    itemid UInt64,
)
ENGINE = MergeTree
ORDER BY (visitorid, timestamp);


CREATE TABLE item_properties_raw
(
    timestamp DateTime64(3),
    itemid UInt64,
    property String,
    value String
)
ENGINE = MergeTree
ORDER BY (itemid, timestamp);


CREATE TABLE category_tree_raw
(
    categoryid Int64,
    parentid Int64
)
ENGINE = MergeTree
ORDER BY categoryid;


SELECT
    property,
    count() AS rows
FROM item_properties_raw
GROUP BY property
ORDER BY rows DESC;


SELECT
    itemid,
    value AS categoryid
FROM item_properties_raw
WHERE property = 'categoryid'
LIMIT 20;