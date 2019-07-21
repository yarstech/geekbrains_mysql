use vk;

/* 
Запросы по БД vk
Запросы необходимо строить с использованием JOIN !*/

/* 1. Пусть задан некоторый пользователь. 
Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользоваетелем.*/

SELECT users.id AS friend, COUNT(inc.from_user_id) + COUNT(inc.to_user_id) AS mess 
  FROM users
       LEFT JOIN messages AS inc 
	      ON users.id = inc.from_user_id
	     AND inc.to_user_id = 1
       LEFT JOIN messages AS outc
	      ON users.id = outc.to_user_id
	     AND outc.from_user_id = 1 
 GROUP BY friend
 ORDER BY mess DESC
 LIMIT 1;


/* 2. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей. */

SELECT SUM(likes)
  FROM (SELECT profiles.user_id, profiles.birthday, COUNT(likes.to_subject_id) AS likes
	  FROM profiles
	       JOIN likes
		 ON likes.to_subject_id = profiles.user_id
	 GROUP BY profiles.user_id, profiles.birthday
	 ORDER BY profiles.birthday DESC
	 LIMIT 10) AS countlikes;

/* 3. Определить кто больше поставил лайков (всего) - мужчины или женщины? */

SELECT sex
  FROM profiles
       JOIN likes
         ON likes.from_user_id = profiles.user_id
 GROUP BY sex
 ORDER BY COUNT(from_user_id) DESC
 LIMIT 1;

/* 4. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети. */

SELECT users.id AS id, COUNT(media.user_id) + COUNT(likes.from_user_id) + COUNT(messages.from_user_id) AS acts
  FROM users
       LEFT JOIN media
              ON users.id = media.user_id
       LEFT JOIN likes
              ON users.id = likes.from_user_id
       LEFT JOIN messages
              ON users.id = messages.from_user_id
 GROUP BY id
 ORDER BY acts
 LIMIT 10;
 
