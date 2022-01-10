
-- Тема DDL = Date definition language (язык определения данных)
-- create, alter, drop 3 основные команды

-- удалить БД
drop database if exists vk;

-- создадим БД vk
create database vk;

use vk;

-- обратные кавычки если сомневаемся в том, что слово зарезервированное
-- создать таблицу users
drop table if exists users;
-- без отрицательных, не нулевое, авто инкремент, уникальное, первичный ключ (всегда в таблице один)
-- serial только один раз в таблице (не может быть несколько автоинкрементных полей)
create table users(
	id serial primary key, -- BIGINT unsigned not null auto_increment unique 
	firstname VARCHAR(100),
	lastname VARCHAR(100) COMMENT 'фАМИЛИЯ', -- COMMENT если не очевиден перевод
	email VARCHAR(120) unique,
	password_hash VARCHAR(100), -- хэш, чтобы был не виден
	phone BIGINT unsigned unique, -- можно и VARCHAR, но кто как введет (неудобно для хранения)
	index users_lastname_firstname_idx(lastname, firstname) -- на фамилию и имя, так как поиск чаще всего по ним
);

alter table users add column is_deleted bit default 0
-- индексы накладываем на поля для поиска, сокращают итерации (пример с бинарным деревом и сравнение индексов)
-- помним про первичный ключ

-- Таблица со связью 1-1 (одно значение соотв. одному). В реальном проекте лучше не делать
-- Создадим таблицу профилей
-- Поля ставим в зависимости от важности (структура)
-- photo_id - какая-то ссылка на таблицу с фото (_id - предпосылка для внешнего ключа)
-- нельзя ссылаться на несуществующие таблицы
drop table if exists `profiles`;
create table `profiles`(
	user_id serial primary key, -- так помечаем внешний ключ (с _id на конце) и тип такой же, как на который ссылаемся
	gender CHAR(1),
	birthday DATE,
	photo_id BIGINT unsigned,
	created_at DATETIME DEFAULT NOW() -- по умолчанию вернет текущее серверное время (не клиентское)
);

-- создадим внешний ключ (user_id была заготовкой)
-- cascade - ставим правила на обновление и удаление
-- в курсовой для всех внешних ключей on update on delete ставить (для udate cascade, для delete cascade или set null)
-- set null - удалить пользователя, но профиль оставить
alter table `profiles` add constraint fk_user_id -- создаем ключ fk_user_id
	foreign key (user_id) references users(id) on update cascade on delete cascade; -- указываем поле, от которого идти (user_id) и направление (связь на таблицу user на поле id)	
	
-- таблица сообщений
-- ТУТ создать еще для файла!!!
-- 1 - М (многим)
-- добавить on update on delete
drop table if exists messages;
create table messages (
	id serial primary key,
	from_user_id BIGINT unsigned not null, -- сможем ссылатся на id, так как формат с serial одинаковый
	to_user_id BIGINT unsigned not null,
	body TEXT,
	created_at DATETIME DEFAULT NOW(),
	foreign key (from_user_id) references users(id), -- так как все пользователи живут в таблице users
	foreign key (to_user_id) references users(id)
);

-- таблица хранения заявок на дружбу
-- составной первичный ключ, чтобы не было ошибки, когда с одним и тем же id повторно направляют заявку
drop table if exists friend_requests;
create table friend_requests (
	-- id serial,
	initiator_user_id BIGINT unsigned not null,
	target_user_id BIGINT unsigned not null,
	`status` ENUM('requested', 'approved', 'declined', 'unfriended'), -- нумерованный список, перечисление тех значений, которые можем использовать
	requested_at DATETIME default NOW(),
	updated_at DATETIME on update now(), -- записываем текущее время
	-- primary key (id),
	primary key (initiator_user_id, target_user_id), -- порядок имеет значение (1-2 не равен 2-1)
	foreign key (initiator_user_id) references users(id),
	foreign key (target_user_id) references users(id)
);


drop table if exists communities;
create table communities(
	id serial primary key,
	name VARCHAR(150)
);
	
-- M - M (разные пользователи в разных сообществах)
-- организуется через связующую таблицу (между users и communities)
drop table if exists users_communities;
create table users_communities(
	user_id BIGINT unsigned not null,
	community_id BIGINT unsigned not null,
	primary key (user_id, community_id), -- составной, чтобы не было 2-х записей в одном сообществе о пользователе
	foreign key (user_id) references users(id),
	foreign key (community_id) references communities(id)
);	

drop table if exists media_types;
create table media_types(
	id serial primary key,
	name VARCHAR(255)
);

-- собирательная таблица со всем медиа
drop table if exists media;
create table media(
	id serial primary key,
	user_id BIGINT unsigned not null,
	body TEXT,
	-- filename BLOB, -- хранение в БД (не рекомендуется, так как разрастается БД)
	filename VARCHAR(255), -- хранение ссылки (а сама информация на дисковом пространстве)
	`size` INT,
	metadata JSON,
	media_type_id BIGINT unsigned,
	created_at DATETIME default NOW(),
	updated_at DATETIME default current_timestamp on update current_timestamp,
	foreign key (user_id) references users(id),
	foreign key (media_type_id) references media_types(id) on update cascade on delete set null
);

-- таблица лайков
drop table if exists likes;
create table likes(
	id serial primary key,
	user_id BIGINT unsigned not null,
	media_id BIGINT unsigned not null,
	created_at DATETIME default now(),
	foreign key (user_id) references users(id),
	foreign key (media_id) references media(id)
);

drop table if exists `photo_albums`;
create table `photo_albums`(
	`id` serial,
	`name` VARCHAR(255) default null,
	`user_id` BIGINT unsigned not null,
	
	foreign key (user_id) references users(id),
	primary key (`id`)

);

drop table if exists `photos`;
create table `photos`(
	id serial primary key,
	`album_id` BIGINT unsigned not null,
	`media_id` BIGINT unsigned not null,
	
	foreign key (album_id) references photo_albums(id)

);

-- домашнее задание (добавление нескольких таблиц)
-- 1-1 таблица настроек страницы пользователя (у одно пользователя одни настройки)
drop table if exists `settings`;
create table `settings`(
	user_id serial primary key,
	privacy_for_posts ENUM('all_friends', 'certain_friends', 'nobody'),
	notifications ENUM('likes', 'comments', 'posts', 'stories'),
	music_subscription CHAR(1),
	foreign key (user_id) references users(id) on update cascade on delete cascade
);

-- 1-M (скорректировано)
drop table if exists user_devices; -- у пользователя может быть несколько устройств, с которых он заходит, но аккаунт один
create table user_devices (
	id serial,
	device ENUM('computer', 'phone', 'tablet'),
	user_id BIGINT unsigned,
	-- device BIGINT unsigned not null, -- 1 - computer, 2 - phone, 3 - tablet
	primary key (id),
	foreign key (user_id) references users(id) on update cascade on delete set null
);

-- M - M (разные пользователи в разных сообществах)
-- организуется через связующую таблицу games (между users и users_games)

drop table if exists games;
create table games(
	id serial primary key,
	game_name VARCHAR(100)
);

drop table if exists users_games;
create table users_games(
	user_id BIGINT unsigned not null,
	game_id BIGINT unsigned not null,
	primary key (user_id, game_id), -- составной, чтобы не было 2-х записей в одной игре о пользователе
	foreign key (user_id) references users(id),
	foreign key (game_id) references games(id)
);	


-- Практическое задание по теме CRUD
-- 1.Заполнить все таблицы БД vk данными (по 10-100 записей в каждой таблице)
-- Имеется следующие таблицы в порядке их создания:
-- users, profiles, messages, friend_requests, communities, users_communities, media_types, media, likes, photo_albums, photos, settings, user_devices, games, users_games
-- Заполним все таблицы данными по порядку
-- users (частично заполнено на 4 уроке, остальные данные добавил здесь)


insert ignore into users (firstname, lastname, email, phone)
values
-- ('Max', 'Summer', 'orin2001@example.com', '455885621'),
-- ('Steve', 'Tram', 'test1212@example.com', '98566471274'),
-- ('Ron', 'Marin', 'gbuser1111@example.com', '4958885595'),
-- ('Dean', 'Carry', 'mysql987@example.com', null);
('Kevin', 'Smith', 'rrr1999@example.com', '8413153851'),
('Paul', 'Brown', 'fish@example.com', '3216812684'),
('Ethan', 'Bond', 'bondyye@example.com', '6516813213'),
('Robert', 'Sapple', 'soviet1991@example.com', '65168513235'),
('Wan', 'Blackstone', 'englishman@example.com', '65168312'),
('Samuel', 'Top', 'hyper@example.com', null);

-- заполнение таблицы profiles
-- по какой-то причине (видимо, из-за пропусков в id таблицы users) возникают проблемы с пакетной вставкой
-- решилось вставкой каждого значения по отдельности с последующим комментированием
-- truncate profiles;
truncate profiles;
insert into profiles (gender, birthday, photo_id, created_at)
values
('f', '1992-01-02', 13253445213, default),
('m', '1976-11-05', 54242245235, default),
('m', '1991-01-03', 78635321692, default),
('m', '1982-02-15', 11272544563, default),
('m', '1997-01-30', 15794521877, default),
('m', '1961-12-31', 78532212887, default),
('f', '1962-01-14', 23697523645, default),
('f', '1995-03-08', 12582975536, default),
('f', '1992-01-02', 78552152875, default),
('f', '1999-07-22', 25726361548, default);
-- ('m', '1992-06-13', 12333697589, default);
-- ('f', '1992-05-16', 45241236755, default);
-- ('f', '1992-01-17', 14527783542, default);
-- ('f', '1992-04-18', 52795321578, default);
-- ('f', '1992-03-19', 23575215348, default);
-- ('m', '1992-01-21', 76516841323, default);

select * from users;
select * from profiles;

-- заполнение таблицы messages
insert into vk.messages (from_user_id, to_user_id, body)
values
(1, 2, 'Hello, Sam. This is Dean'),
(6, 1, 'Everybody clap your hands'),
(7, 9, 'Yar, it is Jeff. Please call me as soon as possible'),
(10, 11, 'Ron, i could not go out this weekend'),
(12, 13, 'Have a nice day'),
(15, 16, 'I have not time for meeting this evening'),
(20, 21, 'Hello, Dean. Lets go to the pool'),
(24, 25, 'It is raining'),
(25, 15, 'Mike, you need more practice'),
(16, 24, 'Hello, Steve. Your keys in my jacket');

select * from messages;

-- заполнение таблицы friend_requests
-- частично заполнено на 4 уроке, остальные данные добавил здесь
insert into friend_requests (initiator_user_id, target_user_id, status)
values
(7, 2, 'approved'),
(7, 6, 'declined'),
(10, 7, 'requested'),
(21, 7, 'requested'),
(25, 16, 'declined'),
(7, 9, 'approved');

-- заполнение таблицы communities
truncate communities;

insert into communities (name)
values
('sports'),
('news'),
('cars'),
('art'),
('gb'),
('wiki'),
('Arthur Schopenhauer'),
('travel'),
('music'),
('science');


-- заполнение таблицы users_communities
insert into users_communities (user_id, community_id)
values
(1, 1),
(2, 7),
(6, 10),
(7, 5),
(9, 3),
(10, 4),
(11, 12),
(12, 1),
(24, 8),
(25, 10);

-- заполнение таблицы media_types
insert into media_types (name)
values
('audio'),
('video'),
('ad'),
('gif'),
('podcasts'),
('vlog');

-- заполнение таблицы media
insert into media (user_id, body, filename, `size`, metadata, media_type_id, created_at, updated_at)
values
(1, 'TEXT', 'Big bag book', 50, null, 1, default, default),
(2, 'MUSIC', 'Sting - shape of my heart', 255, null, 1, default, default),
(24, 'FILM', 'Terminator', 5000, null, 2, default, default),
(6, 'TEXT', 'Big bag book', 50, null, 1, default, default),
(7, 'MUSIC', 'Disgusting men', 128, null, 5, default, default),
(9, 'MUSIC', 'The prodigy - one man army', 100, null, 1, default, default),
(10, 'TEXT', 'Week', 50, null, 1, default, default),
(11, 'TEXT', 'Lucky summer days', 50, null, 4, default, default),
(12, 'TEXT', 'Times', 50, null, 4, default, default),
(13, 'TEXT', 'Used cars', 50, null, 3, default, default);


-- заполнение таблицы likes
insert into likes (user_id, media_id, created_at)
values
(1, 1, default),
(2, 119, default),
(6, 120, default),
(7, 121, default),
(9, 122, default),
(10, 123, default),
(11, 124, default),
(12, 125, default),
(13, 126, default),
(14, 127, default);

-- заполнение таблицы photo_albums
insert into photo_albums (name, user_id)
values
('Album #1', 1),
('Album #1', 2),
('Album #1', 6),
('Album #1', 7),
('Album #1', 9),
('Album #1', 10),
('Album #1', 11),
('Album #1', 12),
('Album #1', 13);

-- заполнение таблицы photos
insert into photos (album_id, media_id)
values
(1, 1),
(2, 119),
(3, 120),
(5, 121),
(4, 122),
(6, 123),
(7, 124),
(8, 125),
(9, 126);

-- заполнение таблицы settings
-- почему-то выходит ошибка при выполнении
/*insert into `settings` (user_id, privacy_for_posts, notifications)
(24, 'certain_friends', 'likes', 'y'),
(21, 'nobody', 'comments', '0'),
(20, 'all_friends', 'comments', '0'),
(16, 'certain_friends', 'posts', 't'),
(15, 'all_friends', 'stories', '0'),
(14, 'all_friends', 'comments', 'b'),
(13, 'certain_friends', 'stories', '0'),
(12, 'nobody', 'likes', '2');*/


-- заполнение таблицы user_devices
insert into user_devices (device, user_id)
values
('computer', 1),
('phone', 2),
('computer', 6),
('tablet', 7),
('phone', 9),
('computer', 10),
('phone', 11),
('phone', 12),
('tablet', 13);

-- заполнение таблицы games
insert into games (game_name)
values
('computer'),
('GTA'),
('Night hunter'),
('Zen ninja'),
('Rambo'),
('Drifts'),
('Pocker'),
('Sims'),
('Trains'),
('LA');

-- заполнение таблицы users_games
insert into users_games
values
-- (24, 2);
-- (2, 1);
-- (6, 4);
-- (7, 3);
-- (10, 9);
-- (11, 8);
-- (22, 7);
-- (13, 6);
-- (14, 5);
(16, 2);

-- 2.	Написать скрипт, возвращающий список имен (только firstname) пользователей без повторений в алфавитном порядке.
-- используем оператор union для объединения запросов
select distinct firstname from users
union
select firstname from users
order by firstname; 

-- 3.	Первые пять пользователей пометить как удаленные.
update users 
set
	is_deleted = 1
where id < 10;

-- 4.	Написать скрипт, удаляющий сообщения «из будущего» (дата больше сегодняшней).
delete from messages
where created_at > current_timestamp;

--

