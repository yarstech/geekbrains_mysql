-- Задание 4-1
-- Подсчитайте средний возраст пользователей в таблице users
USE SHOP;
SELECT avg(timestampdiff(year,birthday_at, now())) AS aver_age FROM users;

-- Задание 4-2
-- Подсчитайте количество дней рождения, которые приходятся на каждую из дней недели. 
-- Следует учесть, что необходимы дни недели текущего года, а не года рождения.
USE SHOP;

SELECT IF(
			(dayofyear(birthday_at) % 7) + dayofweek('2019-01-01') - 1 > 7, 
            (dayofyear(birthday_at) % 7) + dayofweek('2019-01-01') - 8, 
            (dayofyear(birthday_at) % 7) + dayofweek('2019-01-01') - 1) AS day,
            COUNT(name)
FROM users group by day order by day;
