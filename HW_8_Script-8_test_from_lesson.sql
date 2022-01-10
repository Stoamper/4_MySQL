-- 8 урок. Тестовые программы (JOIN, UNION, вложенные запросы)

use vk_test;


select * from users, messages; -- такое написание скрипта - это join

select * from users 
join messages;

-- вывести пользователей и отправленные ими сообщения
select * from users u
join messages m where u.id = m.from_user_id; -- inner join, хотя по всем признакам это cross join запрос

select * from users u
join messages m on u.id = m.from_user_id; -- а вот это точно inner join запрос, так как on. В условии только либо ключи или индексы

-- подсчитать количество сообщений, написанных каждым пользователем. Каждый - group by
select * from users u 
join messages m ON u.id=m.from_user_id 
group by u.id;

-- лучше писать псеводнимы при обращении к полю, чтобы потом не возникло ошибки
-- какой пользователь больше всех отправил сообщений
-- задача для собедесования: есть группировка, join, сортировка, подсчет (много функционала для простой задачи)
-- Псевдонимы для полей u.id AS 'name' ()
select 
	u.firstname,
	u.lastname,
	count(*) as cnt 
from users u 
join messages m ON u.id=m.from_user_id 
group by u.id
order by cnt desc;


-- LEFT JOIN
select * from users u 
left join messages m ON u.id=m.from_user_id
order by m.id; -- выведет сначала null у кого нет сообщений

-- right join (данный пример равносилен inner)
select * from users u 
right join messages m ON u.id=m.from_user_id
order by m.id; 

-- right join (данный пример равносилен inner)
select * from messages m
right join users u ON u.id=m.from_user_id
order by m.id; -- аналогичен left, так как поменяли местами таблицы

-- FULL join (как такового его нет в mysql, но если нужно, то с помощью union объединяем left и right join)
select * from users u 
left join messages m ON u.id=m.from_user_id
union 
select * from users u 
right join messages m ON u.id=m.from_user_id;

-- выбрать всех, у кого нет сообщений
select * from messages m
right join users u ON u.id=m.from_user_id
where m.id is null;

-- выбрать всех, у кого есть сообщения
select * from messages m
right join users u ON u.id=m.from_user_id
where m.id is not null;

_______________________________________________________________

-- Перепишем со вложенного запроса на join
-- Изначальный код (из предыдущего занятия)
select 
	firstname,
	lastname,
	(select hometown from profiles where user_id = 1) as city,
	(select filename from media where id = 
		(select photo_id from profiles where user_id = 1)
	) as main_photo
from users 
where id = 1;

-- Переделанный код c join (меньше, чем ранее)
select 
	u.firstname,
	u.lastname,
	p.hometown as city,
	m.filename as main_photo
from users u
join profiles p on u.id = p.user_id 
join media m on p.photo_id = m.id
where u.id = 1;
		
-- Получить всех пользователей (а во вложенном нам пришлось бы менять корреляцию)
select 
	u.firstname,
	u.lastname,
	p.hometown as city,
	m.filename as main_photo
from users u
join profiles p on u.id = p.user_id 
join media m on p.photo_id = m.id
-- where u.id = 1;

-- если у кого-то нет фотографии, то вывести его все равно надо. Используем LEFT для media
select 
	u.firstname,
	u.lastname,
	p.hometown as city,
	m.filename as main_photo
from users u
join profiles p on u.id = p.user_id 
left join media m on p.photo_id = m.id;

-- выбрать документы для пользователя с id = 1
select 
	m.user_id,
	m.body, 
	m.created_at 
from media m 
join users u on u.id = m.user_id 
where u.id = 1; -- можно тут написать m.user_id
-- тогда задача решиться следующим образом. Это лучше с точки зрения производительности (меньше программа - лучше)
select 
	m.user_id,
	m.body, 
	m.created_at 
from media m 
-- join users u on u.id = m.user_id 
where m.user_id = 1;

-- получить сообщения к пользователю (ВНИМАТЕЛЬНО К УСЛОВИЮ, отличие в одной переменной)
select m.body, u.firstname, u.lastname, m.created_at
from messages m 
join users u on u.id = m.to_user_id 
where u.id = 1;
-- получить сообщения от пользователя
select m.body, u.firstname, u.lastname, m.created_at
from messages m 
join users u on u.id = m.from_user_id 
where u.id = 1;

-- Посчитать количество друзей у каждого пользователя
select 
	u.firstname,
	u.lastname,
	count(*) as total_friends 
from users u 
join friend_requests fr on (u.id = fr.initiator_user_id or u.id = fr.target_user_id)
where fr.status = 'approved' -- заявки подтверждены. Вынесли отдельно, т.к. в on лучше использовать индексы, связи, ключи
group by u.id  -- то есть быстрее выполнится до where и потом с where, чем сразу фильтровать и по статусу
having total_friends>1 -- применение оператора having. total_friends сформировался на предыдущем этапе и к нему теперь можно обратиться
order by total_friends desc;

-- выбрать документы друзей с помощью join с пользователем id=1
select m.*
from media m 
join friend_requests fr on m.user_id = fr.target_user_id 
join users u on fr.initiator_user_id = u.id
where u.id = 1 and fr.status = 'approved'
union
select m.*
from media m 
join friend_requests fr on m.user_id = fr.initiator_user_id 
join users u on fr.target_user_id = u.id
where u.id = 1 and fr.status = 'approved';

-- решение той же задачи, но без union
select m.*
from media m 
join friend_requests fr on 
	(fr.initiator_user_id  = m.user_id and fr.target_user_id = 1)
	or 
	(fr.target_user_id = m.user_id and fr.initiator_user_id = 1)
where fr.status = 'approved';	


-- список медиафайлов и у каждого поставить количество лайков для пользователя с id = 1
select 
	m.filename,
	count(*) as total_likes,
	concat(u.firstname, ' ', u.lastname) as owner 
from media m 
join likes l on l.media_id = m.id 
join users u on u.id = m.user_id 
-- where u.id = 1 -- это условие для id=1. При комментировании выводится для всех пользователей
group by m.id; -- группируем для каждого медиафайла


-- количество групп у пользователей (у каждого - группируем по пользователю)
select
	u.firstname,
	u.lastname,
	count(*) as total_communities 
from users u 
join users_communities uc on u.id = uc.user_id 
group by u.id
order by total_communities desc;

-- среднее количество групп у пользователей (через вложенный запрос)
select 
	avg(total_communities) as average
from
(select
	u.firstname,
	u.lastname,
	count(*) as total_communities 
from users u 
join users_communities uc on u.id = uc.user_id 
group by u.id
order by total_communities desc) as list;


-- выбрать количество пользователей в каждой группе (количество пользователей в КАЖДОЙ группе - соответственно group by по сообществам)
select 
	c.name,
	count(*) as cnt
from users u 
	join users_communities uc on u.id = uc.user_id 
	join communities c on c.id = uc.community_id
group by c.id -- можно и по c.name если уверены, что названия сообществ не повторяются
order by cnt desc;
-- можно сделать проще
select 
	c.name,
	count(*) as cnt
from users_communities uc
	join communities c on c.id = uc.community_id
group by c.id -- можно и по c.name если уверены, что названия сообществ не повторяются
order by cnt desc;