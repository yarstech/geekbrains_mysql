USE SHOP;

/* 1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, 
catalogs и products в таблицу logs помещается время и дата создания записи, название таблицы, 
идентификатор первичного ключа и содержимое поля name. */

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
  table_id INT,
  table_name VARCHAR(20),
  name VARCHAR(255),
  created_ad TIMESTAMP
  
) COMMENT = 'Логи' ENGINE=Archive;

DELIMITER //
CREATE PROCEDURE write_log(IN table_id INT, table_name VARCHAR(20), name VARCHAR(255))
BEGIN
    INSERT INTO logs(table_id, table_name, name, created_ad) VALUES (table_id, table_name, name, NOW());
END//

DROP TRIGGER IF EXISTS users_log//
CREATE TRIGGER users_log AFTER INSERT ON users
FOR EACH ROW
BEGIN
    CALL write_log(NEW.id, "users", NEW.name);
END//

DROP TRIGGER IF EXISTS catalogs_log//
CREATE TRIGGER catalogs_log AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
    CALL write_log(NEW.id, "catalogs", NEW.name);
END//

DROP TRIGGER IF EXISTS products_log//
CREATE TRIGGER products_log AFTER INSERT ON products
FOR EACH ROW
BEGIN
    CALL write_log(NEW.id, "products", NEW.name);
END//

DELIMITER ;


INSERT INTO users (name) VALUES ('Yaroslav');
INSERT INTO catalogs (name) VALUES ('Books');
INSERT INTO products (name) VALUES ('Star wars');

SELECT * FROM logs;

/* 2. (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей. */
DELIMITER //
DROP PROCEDURE IF EXISTS insert_many//
CREATE PROCEDURE insert_many(IN Q INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    
    WHILE i < Q DO
	INSERT INTO users (name) VALUES (concat('user', i));
        SET i = i + 1;
    END WHILE;
    
END//
  
CALL insert_many(1000000)//
/* Для 1000000 запрос выдает ошибку, 
спустя 30 секунд Error Code: 2013. Lost connection to MySQL server during query 
при этом, записи в таблице создаются */

SELECT * FROM USERS LIMIT 1000000//
