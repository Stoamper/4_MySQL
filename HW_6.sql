-- Практическое задание по уроку №6 "Операторы, фильтрация, сортировка и ограничение. Агрегация данных"


-- 1.	Пусть задан некоторый пользователь. 
-- Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.

-- 1.1 Найти всех друзей пользователя id = 1
select initiator_user_id from friend_requests
where (target_user_id = 1) and status = 'APPROVED' -- id друзей, заявку которых я получил
union  -- объединение запросов (в каждом запросе должно быть равное количество выводимых полей)
select target_user_id from friend_requests
where (initiator_user_id = 1) and status = 'APPROVED'

-- 1.2 Посчитаем суммарное количество сообщений от каждого пользователя, с кем пользователь id = 1 общался (то есть кто ему писал)
-- Выполним сортировку по убыванию количества сообщений
select 
	from_user_id,
	count(*)
from messages 
where to_user_id = 1 
	group by from_user_id 
	order by count(*) desc;

-- 1.3 Объединим задачи 1.1 и 1.2 и определим, кто из друзей id = 1 больше всего писал ему
-- ВОПРОС: почему-то выводится id = 10, хотя у него не сообщений к id = 1 (без limit 1 в конце)
select 
	from_user_id as user_id, 
	(select firstname from users where id = messages.from_user_id) as firstname, -- добавляем вложенные запросы для отражения имени и фамилии
	(select lastname from users where id = messages.from_user_id) as lastname,
	count(*) as total_number_of_messages
from messages 
where 
	from_user_id in (select initiator_user_id from friend_requests
	where (target_user_id = 1) and status = 'APPROVED' 
	union  
	select target_user_id from friend_requests
	where (initiator_user_id = 1) and to_user_id = 1 and status = 'APPROVED')	
	group by from_user_id 
	order by count(*) desc limit 1;

______________________________________________________________________________________

-- 2.	Подсчитать общее количество лайков, которые получили пользователи младше 10 лет.
-- 2.1 Подсчитать общее количество лайков
select 
	count(*)
from likes

-- 2.2 Найти всех пользователей младше 10 лет
select 
	user_id,
	timestampdiff(year, birthday, now()) as user_age 
from profiles
where timestampdiff(year, birthday, now()) < 10;

-- 2.3 Объединим задачи 2.1 и 2.2 и подсчитаем общее количество лайков, которые получили пользователи младше 10 лет
-- если закомментировать count и раскомментировать user_id, то можно просмотреть id тех пользователей, которые получили лайки
select 
	count(*) as summary_likes_age_to_10
	-- user_id
from likes
where user_id in (select user_id from profiles 
				  where timestampdiff(year, birthday, now()) < 10);
-- 2.4 Изначально (2.3) решено неверно (посчитал, кто лайкает, а не кого). Ниже правильное решение
select 
	count(*) as summary_likes_age_to_10
from likes
where media_id in (select id from media where user_id in (select user_id from profiles
				  where timestampdiff(year, birthday, now()) < 10));				 

_____________________________________________________________________________________

-- 3.	Определить кто больше поставил лайков (всего): мужчины или женщины.
-- 3.1 Выведем суммарное количество мужчин и женщин
select sum(case(gender)
	   		when 'm' then 1
	   		else 0
	   		end) as males,
	   sum(case(gender)
	   		when 'f' then 1
	   		else 0
	   		end) as females
from profiles;

-- 3.2 Определим, кто поставил больше лайков: мужчины или женщины
-- Для наглядности первой строкой выведем общее количество лайков, поставленных мужчинами и женщинами
-- Во второй строке таблицы будет указан тот пол, с чьей стороны было больше лайков				 
select 
	'males and females together' as gender,
	count(*) as summary_likes
from likes
union
select 
	'males' as gender,
	count(*) as summary_likes
from likes
where user_id in (select user_id from profiles 
				  where gender like 'm')
union 
select 
	'females',
	count(*) as summary_likes
from likes
where user_id in (select user_id from profiles 
				  where gender like 'f')
order by summary_likes desc limit 2;

________________________
-- 3.3 Доработка, чтобы выводился именно поле тех, кто поставил больше лайков

select 
	count(*) 
from likes
where user_id in (select user_id from profiles 
				  where gender like 'm') into @a;
select 
	count(*)
	from likes
	where user_id in (select user_id from profiles 
				  where gender like 'f') into @b;
select 
case when @a > @b
		then 'MALES'
	 when @a < @b
		then 'FEMALES'
	 else 'EQUALLY'
end as gender_max_likes;



