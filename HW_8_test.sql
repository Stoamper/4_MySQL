-- Практическое задание по уроку №8 "Сложные запросы"

use vk_test;

-- 1.	Пусть задан некоторый пользователь. 
-- Из всех друзей этого пользователя найдите человека, который больше всех общался с выбранным пользователем 
-- (написал ему сообщений).
-- Для примера возьмем пользователя id=1
-- 1.1 Вывести всех друзей пользователя id=1, кто писал ему сообщения
select m.*
from messages m
join friend_requests fr on 
	(fr.initiator_user_id = m.from_user_id and fr.target_user_id = 1)
	or 
	(fr.target_user_id = m.from_user_id and fr.initiator_user_id = 1)
where fr.status = 'approved';

-- 1.2 Найти, кто больше всего из друзей написал сообщений
select 
	u.firstname,
	u.lastname,
	count(*) as total_messages
from messages m
join users u on (m.from_user_id = u.id)
join friend_requests fr on 
	(fr.initiator_user_id = m.from_user_id and fr.target_user_id = 1)
	or 
	(fr.target_user_id = m.from_user_id and fr.initiator_user_id = 1)
where fr.status = 'approved'
group by m.from_user_id
order by total_messages desc limit 1;


-- 2.	Подсчитать общее количество лайков, которые получили пользователи младше 10 лет.
select  
	count(*) as summary_likes_age_to_10
from likes l
join media m on (l.media_id = m.id)
join profiles p on (p.user_id = m.user_id and timestampdiff(year, p.birthday, now()) < 10);


-- 3.	Определить кто больше поставил лайков (всего): мужчины или женщины.
select  
	p.gender,
	count(*) as summary_likes_males
from likes l
join profiles p on 
	(p.user_id = l.user_id and p.gender = 'm')
	or 
	(p.user_id = l.user_id and p.gender = 'f')
group by p.gender
order by summary_likes_males desc limit 1;



_______________________________________________________________
-- TEST

-- 1. С union
select 
	m.from_user_id as user_id, 
	count(*) as cnt
from messages m
join friend_requests fr on m.from_user_id = fr.target_user_id 
join users u on fr.initiator_user_id = u.id
where u.id = 1 and fr.status = 'approved' and m.to_user_id = 1
union
select 
	m.from_user_id as user_id, 
	count(*) as cnt
from messages m
join friend_requests fr on m.from_user_id = fr.initiator_user_id 
join users u on fr.target_user_id = u.id
where u.id = 1 and fr.status = 'approved' and m.to_user_id = 1
order by cnt desc limit 1;

-- 1.2 Найти, кто больше всего из друзей написал сообщений
select 
	m.from_user_id as friend_number,
	count(*) as total_messages
from messages m
join friend_requests fr on 
	(fr.initiator_user_id = m.from_user_id and fr.target_user_id = 1)
	or 
	(fr.target_user_id = m.from_user_id and fr.initiator_user_id = 1)
where fr.status = 'approved'
group by m.from_user_id
order by total_messages desc limit 1;


-- 3.1 Определить сколько лайков поставили мужчины 
select  
	count(*) as summary_likes_males
from likes l
join profiles p on (p.user_id = l.user_id and p.gender = 'm');