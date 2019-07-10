-- Задание 3-1
-- Пусть в таблице users поля created_at и updated_at оказались незаполненными. 
-- Заполните их текущими датой и временем.
USE SHOP;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME,
  updated_at DATETIME
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');
  
  
UPDATE users SET created_at = NOW(),
					updated_at = NOW();
          
SELECT * FROM users;

-- Задание 3-2
-- Таблица users была неудачно спроектирована. 
-- Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате "20.10.2017 8:10". 
-- Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.

USE SHOP;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(255) DEFAULT '20.10.2017 8:10',
  updated_at VARCHAR(255) DEFAULT '20.10.2017 8:10'
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');   
  
UPDATE users set created_at = str_to_date(created_at, '%d.%m.%Y %h:%i'),
					updated_at = str_to_date(updated_at, '%d.%m.%Y %h:%i');
                    
ALTER TABLE users MODIFY created_at DATETIME;
ALTER TABLE users MODIFY updated_at DATETIME;

SELECT * FROM users;

-- Задание 3-3
-- В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 
-- 0, если товар закончился и выше нуля, если на складе имеются запасы. 
-- Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
-- Однако, нулевые запасы должны выводиться в конце, после всех записей.

USE SHOP;

SELECT * FROM storehouses_products; 

INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES
  (1, 1, 10),
  (1, 2, 0),
  (1, 3, 15),
  (1, 4, 7),
  (1, 5, 0),
  (2, 2, 12);
  
 SELECT * FROM  storehouses_products order by if(VALUE = 0, 9999999999, VALUE);

-- Задание 3-5
-- (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. 
-- SELECT * FROM catalogs WHERE id IN (5, 1, 2); 
-- Отсортируйте записи в порядке, заданном в списке IN.

SELECT * FROM catalogs WHERE id IN (5, 1, 2) 
			ORDER BY (CASE 
				WHEN id = 5 THEN 1 
                        	WHEN id = 1 THEN 2 
                        	WHEN id = 2 THEN 3 END); 
