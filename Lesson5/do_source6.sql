use shop;

-- 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

-- delete from sample.users;

START transaction;
INSERT INTO sample.users
SELECT * FROM shop.users WHERE id = 1;
DELETE FROM shop.users WHERE id = 1;
-- ROLLBACK; 
COMMIT;

SELECT * from shop.users;
SELECT * from sample.users;

-- 2. Создайте представление, которое выводит название name товарной позиции из таблицы products 
-- и соответствующее название каталога name из таблицы catalogs.

CREATE VIEW prod_description AS SELECT products.name AS product, catalogs.name AS catalog FROM products
LEFT JOIN catalogs ON products.catalog_id = catalogs.id;

SELECT * FROM prod_description;

-- 3. (по желанию) Пусть имеется таблица с календарным полем created_at. 
-- В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. 
-- Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, 
-- если дата присутствует в исходном таблице и 0, если она отсутствует.

DROP TABLE IF EXISTS task3;
create table task3 (
  id SERIAL PRIMARY KEY,
  created_at date);
INSERT INTO task3 VALUES
  (NULL, '2018-08-01'), (NULL, '2018-08-04'), (NULL, '2018-08-16'), (NULL, '2018-08-17');

CREATE TEMPORARY TABLE days_aug (days int);

INSERT INTO days_aug VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), 
							(11), (12),(13),(14), (15), (16), (17), (18), (19), (20),
                            (21), (22), (23), (24), (25), (26), (27), (28), (29), (30), (31);
-- Можно ли даты месяца в цикле заполнить?
                            
SET @start_aug = '2018-07-31';

SELECT @start_aug + interval days day AS date_aug,
	   CASE WHEN task3.created_at is NULL THEN 0 ELSE 1 END AS v1 FROM days_aug
LEFT JOIN task3 ON @start_aug + interval days day = task3.created_at
ORDER BY date_aug;

-- 4. (по желанию) Пусть имеется любая таблица с календарным полем created_at. 
-- Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.
use sample;

PREPARE del_prod from "DELETE FROM products ORDER BY created_at LIMIT ?";
SET @ROWS = (SELECT COUNT(*)-5 FROM products);
EXECUTE del_prod USING @ROWS;

SELECT * FROM products;
