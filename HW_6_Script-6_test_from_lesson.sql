-- Тестовое выполнение заданий с 6 видеоурока

use vk_test;

-- выбрать определенные данные пользователя из нескольких таблиц (сложный запрос)

select
	id,
	firstname, 
	lastname,
	'city',
	'main_photo'
from users
order by id;

-- просто выводим данные
select hometown from profiles where user_id=1

-- используем корреляцию со вложенным запросом
select
	id,
	firstname, 
	lastname,
	(select hometown from profiles where user_id=users.id) as 'city',
	(select filename from media where id=(select photo_id from profiles where user_id=users.id)) as 'main_photo'
from users
order by id;

-- если для одного пользователя, то сразу подставляем нужные значения
select
	-- id,
	firstname, 
	lastname,
	(select hometown from profiles where user_id=1) as 'city', -- as 'city' - псевдоним
	(select filename from media where id=(select photo_id from profiles where user_id=1)) as 'main_photo'
from users
where id=1
order by id;


-- получить все фотографии (не аватарку) определенного пользователя id=1
-- фотографии смотрим исходя из столбца media_type_id (1)
select * from media
where user_id = 1 and 
media_type_id = (select id from media_types
where name = 'photo'); -- или можно записать where name like 'photo' но если поле не индекс (с ними like плохо работает)

-- случай, когда есть вариации по количеству выводимых данных вложенного запроса (больше одного). Используем IN
select * from media
where user_id = 1 and 
media_type_id in (select id from media_types
where name like 'p%');


-- выбрать видеозаписи пользователя для id=1, но видео найти не по типу, а по расширению файла (avi, mp4)
select * from media
where user_id = 1 and (filename like '%avi' or filename like 'mp4');


-- посчитать (count) количество фотографий у пользователя с id=1
select 
	count(*)
from media
where user_id = 1 and media_type_id = 1;


-- подсчитать количество записей media КАЖДОГО типа
select 
	media_type_id,
	(select name from media_types where id=media.media_type_id) as 'media_type',
	count(*)
from media
group by media_type_id;


-- сколько в каждом месяце создано media
select 
	count(*) cnt,
	month(created_at) as month_num,
	monthname(created_at) as month_name 
from media
group by month_num
order by cnt desc; 


-- выбрать документы у каждого пользователя
select 
	(select email from users where id = media.user_id) as user,
	count(*)
from media
group by user_id;


-- просмотреть друзей пользователя с id = 1 (лучше вместо * указать конкретные поля, так как выводятся лишние данные)
select * from friend_requests
where 
	initiator_user_id = 1 -- мои заявки
	or target_user_id = 1 -- заявки ко мне
	and status = 'APPROVED'; -- только подтвержденные друзья


-- получить документы только моих друзей (пользователя с id = 1)
select * 
from media where user_id in (3, 10, 4);

-- другое решение данной задачи
-- select * 
-- from media where user_id = 1
-- union
select *
from media where user_id in (
-- (3, 10, 4);
	select initiator_user_id from friend_requests
	where (target_user_id = 1) and status = 'APPROVED' -- id друзей, заявку которых я получил
	union  -- объединение запросов (в каждом запросе должно быть равное количество выводимых полей)
	select target_user_id from friend_requests
	where (initiator_user_id = 1) and status = 'APPROVED'
) or user_id = 1;


-- посчитать like для каждого документа у пользователя с id = 1
select
	media_id,	
	count(*)
from likes
where media_id in (select id from media where user_id = 1)
group by media_id;


-- почитать сообщения от пользователя к пользователю
-- выбираем сообщения от пользователя к пользователю (мои и ко мне)
select * from messages
	where from_user_id = 1 -- от меня (я отправитель)
		or to_user_id = 1 -- ко мне (Я получатель)
	order by created_at desc; -- упорядочим по дате	

-- добавим колонку is_read DEFAULT 0
alter table messages 
add column is_read bit default b'0';

-- получить непрочитанные мною сообщения
select * from messages
	where 
		-- from_user_id = 1 -- от меня (я отправитель) так как не надо смотреть отправленные прочитанные мной, только входящие
		to_user_id = 1 -- ко мне (Я получатель)
		and is_read = b'0'
	order by created_at desc; -- упорядочим по дате	
	
update messages 
	set is_read = b'1'
	where created_at < date_sub(now(), interval 100 day); 
	

-- вывести друзей пользователя, но будем преобразовывать пол и возраст
select user_id, 
	   case(gender)
	   	when 'm' then 'мужской'
	   	when 'f' then 'женский'
	   	else 'не указан'
	   end as gender, 
	   timestampdiff(year, birthday, now()) as age -- разница между текущей датой и датой рождения
from profiles
where user_id in (
	select initiator_user_id from friend_requests where (target_user_id = 1)
	and status = 'APPROVED' -- id друзей, заявку которых я подтвердил
	union 
	select target_user_id from friend_requests where (initiator_user_id = 1)
	and status = 'APPROVED' -- id друзей, подтвердивших мою заявку
);


-- в группах кто состоит, кого нет, кто админ
alter table vk_test.communities add admin_user_id int default 1 not null;

select admin_user_id from communities where id = 5;
select 1 = (select admin_user_id from communities where id = 5) as 'is admin';  -- 1 - true, 0 - false


-- чтобы пользователь сам с обой не подружился
alter table friend_requests 
add check (initiator_user_id <> target_user_id);