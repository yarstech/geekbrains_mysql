
/*  1. общее текстовое описание БД и решаемых ею задач;

База данных (а затем приложение) для регистрации и анкетирования кандидатов 
и их оценки на групповых собеседованиях.

2. минимальное количество таблиц - 10;
3. скрипты создания структуры БД (с первичными ключами, индексами, внешними ключами);

4. представления (минимум 2);

5. хранимые процедуры / триггеры;

скрипты наполнения БД данными - отдельный файл SQL;
скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы) - отдельный  файл SQL;

создать ERDiagram для БД - отдельный файл;

---------------------------------------------------------------------------------------- */

DROP DATABASE IF EXISTS candidates;
CREATE DATABASE candidates;

USE candidates;

/*  Таблица пользователей */
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  firstname VARCHAR(50) NOT NULL,
  lastname VARCHAR(50) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  INDEX users_id_idx (id),
  INDEX users_firstname_lastname_idx (firstname, lastname),
  INDEX users_email_idx (email)
);

/*  Таблица паролей */
DROP TABLE IF EXISTS passwords;
CREATE TABLE passwords (
  user_id INT UNSIGNED NOT NULL PRIMARY KEY,
  password VARCHAR(50) NOT NULL,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT passwords_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id)
  );
  
/*  Таблица профилей */
DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
  user_id INT UNSIGNED NOT NULL PRIMARY KEY,
  sex CHAR(1) NOT NULL,
  birthday DATE,
  vk_link VARCHAR(250),
  fb_link VARCHAR(250),
  hh_link VARCHAR(250),
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT profiles_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id)
);

/*  Таблица опыта работы */
DROP TABLE IF EXISTS  experience;
CREATE TABLE experience (
  user_id INT UNSIGNED NOT NULL,
  company VARCHAR(100) NOT NULL,
  position VARCHAR(100) NOT NULL,
  recomendations VARCHAR(250),
  start_date DATE NOT NULL,
  end_date DATE,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT experience_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id)
);

/*  Таблица расширенной анкеты */
DROP TABLE IF EXISTS extraprofiles_points;
CREATE TABLE extraprofiles_points (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  serial_number INT NOT NULL UNIQUE COMMENT 'Порядковый номер в анкете',
  body VARCHAR(250) NOT NULL COMMENT 'Вопрос',
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

/*  Таблица данных анкет кандидатов */
DROP TABLE IF EXISTS extraprofiles;
CREATE TABLE extraprofiles (
  user_id INT UNSIGNED NOT NULL,
  point_id INT UNSIGNED NOT NULL,
  answer VARCHAR(250) COMMENT 'Ответ на вопрос',
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  PRIMARY KEY (user_id, point_id),
  CONSTRAINT extraprofiles_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT extraprofiles_point_id_fk FOREIGN KEY (point_id) REFERENCES extraprofiles_points(id)
);

/*  Таблица компетенций */
DROP TABLE IF EXISTS skills;
CREATE TABLE skills (
  id INT UNSIGNED NOT NULL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название компетенции',
  UNIQUE unique_name(name(25))
);

/* Таблица оценочных вопросов по компетенциям */
DROP TABLE IF EXISTS skills_points;
CREATE TABLE skills_points (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  serial_number INT NOT NULL UNIQUE COMMENT 'Порядковый номер в тесте',
  skill_id INT UNSIGNED NOT NULL,
  body VARCHAR(250) NOT NULL COMMENT 'Вопрос',
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT skills_points_skill_id_fk FOREIGN KEY (skill_id) REFERENCES skills(id)
);

/* Таблица вариантов ответов */
DROP TABLE IF EXISTS answer_choices;
CREATE TABLE answer_choices (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  point_id INT UNSIGNED NOT NULL,
  serial_number INT NOT NULL COMMENT 'Порядковый номер варианта ответа',
  answer VARCHAR(250) NOT NULL COMMENT 'Вариант ответа',
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT answer_choices_skill_id_fk FOREIGN KEY (point_id) REFERENCES skills_points(id)
);

/* Таблица правильных ответов */
DROP TABLE IF EXISTS right_answers;
CREATE TABLE right_answers (
  point_id INT UNSIGNED NOT NULL,
  answer_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (point_id, answer_id),
  CONSTRAINT answer_choices_point_id_fk FOREIGN KEY (point_id) REFERENCES skills_points(id),
  CONSTRAINT answer_choices_answer_id_fk FOREIGN KEY (answer_id) REFERENCES answer_choices(id)
);

/* Таблица ответов кандидатов */
DROP TABLE IF EXISTS user_answers;
CREATE TABLE user_answers (
  user_id INT UNSIGNED NOT NULL,
  point_id INT UNSIGNED NOT NULL,
  answer_id INT UNSIGNED NOT NULL,
  answer_date DATE NOT NULL,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  PRIMARY KEY (user_id, answer_date, point_id, answer_id),
  CONSTRAINT user_answers_point_id_fk FOREIGN KEY (point_id) REFERENCES skills_points(id),
  CONSTRAINT user_answers_answer_id_fk FOREIGN KEY (answer_id) REFERENCES answer_choices(id),
  CONSTRAINT user_answers_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id)
);

/* представления (минимум 2) */

-- Таблица профилей

DROP VIEW IF EXISTS users_extended;
CREATE VIEW users_extended AS 
SELECT users.id AS id, users.firstname, users.lastname, CONCAT(users.firstname, ' ', users.lastname) AS all_name, users.email, 
	   profiles.sex, profiles.birthday, profiles.vk_link, profiles.fb_link, profiles.hh_link
  FROM users
	   LEFT JOIN profiles ON users.id = profiles.user_id;

SELECT * FROM users_extended;

-- Таблица правильных ответов

DROP VIEW IF EXISTS questions_and_answers;
CREATE VIEW questions_and_answers AS 
SELECT sp.serial_number, s.name, sp.body, ac.serial_number AS answer_number, ac.answer
 FROM skills_points AS sp
      LEFT JOIN skills AS s ON sp.skill_id = s.id
      LEFT JOIN right_answers AS ra ON sp.id = ra.point_id
      LEFT JOIN answer_choices AS ac ON ra.answer_id = ac.id
      
ORDER BY sp.serial_number;

SELECT * FROM questions_and_answers;


/* Тригерры */

-- контроль стажа и опыта

DELIMITER //
DROP TRIGGER IF EXISTS experience_control_insert//

CREATE TRIGGER experience_control_insert BEFORE INSERT ON experience
FOR EACH ROW
BEGIN
    IF NEW.start_date IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Start date cannot be NULL';
	END IF;
    
    IF NEW.end_date IS NOT NULL AND NEW.start_date > NEW.end_date THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Start date cannot be more than End date';
	END IF;
    
END//

-- проверка пароля 

DROP TRIGGER IF EXISTS password_control_insert//
CREATE TRIGGER password_control_insert BEFORE INSERT ON passwords
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.password) < 5 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Too short password. It must be more than 5 chars';
	END IF;
END//

DROP TRIGGER IF EXISTS password_control_update//
CREATE TRIGGER password_control_update BEFORE update ON passwords
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.password) < 5 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Too short password. It must be more than 5 chars';
	END IF;
END//

DELIMITER ;

/* triggers check */
INSERT INTO experience VALUES ('17','Wolff, Schmitt and Emard','totam',NULL, NULL,'1999-11-28', DEFAULT, DEFAULT);
INSERT INTO experience VALUES ('17','Wolff, Schmitt and Emard','totam',NULL,'1996-07-31', '1993-07-31', DEFAULT, DEFAULT);

UPDATE passwords SET password = '1234' WHERE user_id = 17;

/* Хранимые процедуры */

DELIMITER //

-- возраст кандидата

DROP FUNCTION IF EXISTS AGE//
CREATE FUNCTION AGE(id INT)
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE Y INT;
    SET Y = (SELECT timestampdiff(year,birthday, now()) FROM profiles WHERE user_id = id);
	RETURN Y;  
END//

SELECT AGE(1)//

-- баллы кандидата

DROP FUNCTION IF EXISTS BALLS//
CREATE FUNCTION BALLS(id INT)
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE Y INT;
    SET Y = (SELECT COUNT(ua.answer_id)
			   FROM user_answers AS ua
				    LEFT JOIN skills_points AS sp
						   ON ua.point_id = sp.id
					     JOIN right_answers AS ra 
                           ON ua.answer_id = ra.answer_id AND sp.id = ra.point_id
 
			  WHERE user_id = id 
	          GROUP BY ua.user_id);
	RETURN Y;  
END//

SELECT BALLS(1)//