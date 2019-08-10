
/* скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы);
- выборка опыта работы
- выборка стажа 
- выборка ответов 
- выборка баллов (ответов) пользователей
*/

USE candidates;

-- выборка опыта работы

SELECT us.id, us.all_name, ex.company, ex.position, ex.start_date, 
       CASE WHEN ISNULL(ex.end_date) THEN NOW() ELSE ex.end_date END AS end_date
  FROM users_extended AS us
       LEFT JOIN experience AS ex 
              ON us.id = ex.user_id
 ORDER BY us.all_name, end_date;
 
 -- выборка стажа 

 SELECT exp_start.user_id, exp_start.start_stage, exp_end.end_stage, 
        DATEDIFF(exp_end.end_stage, exp_start.start_stage) AS days
   FROM
	    (SELECT user_id, min(start_date) AS start_stage
           FROM experience
          GROUP BY user_id) AS exp_start
	     LEFT JOIN (SELECT user_id, max(CASE WHEN ISNULL(end_date) THEN NOW() ELSE end_date END) AS end_stage
                      FROM experience
                     GROUP BY user_id) AS exp_end 
			    ON exp_start.user_id = exp_end.user_id;
                
-- выборка ответов пользователей

SELECT ua.user_id, sp.serial_number, sp.body, ac.serial_number AS answer_number, ac.answer
  FROM user_answers AS ua
       LEFT JOIN skills_points AS sp
              ON ua.point_id = sp.id
	   LEFT JOIN answer_choices AS ac ON ua.answer_id = ac.id
 ORDER BY ua.user_id, sp.serial_number;

-- выборка баллов пользователей

SELECT ua.user_id, COUNT(ua.answer_id) AS balls
  FROM user_answers AS ua
       LEFT JOIN skills_points AS sp
              ON ua.point_id = sp.id
	        JOIN right_answers AS ra ON ua.answer_id = ra.answer_id AND sp.id = ra.point_id
 GROUP BY ua.user_id
 ORDER BY balls;
 
