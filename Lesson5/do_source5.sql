
-- 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.

SELECT name FROM users WHERE users.id IN (SELECT user_id FROM orders);

-- 2. Выведите список товаров products и разделов catalogs, который соответствует товару.

SELECT products.name AS product, catalogs.name AS catalog FROM products
LEFT JOIN catalogs ON products.catalog_id = catalogs.id;

-- 3. (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
-- Поля from, to и label содержат английские названия городов, поле name — русское. 
-- Выведите список рейсов flights с русскими названиями городов.

SELECT id, cities_from.name, cities_to.name FROM flights
LEFT JOIN cities AS cities_from ON flights.from = cities_from.label
LEFT JOIN cities AS cities_to ON flights.to = cities_to.label;
