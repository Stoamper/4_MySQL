-- CRUD-операции

-- заполнение таблицы users

use vk;

insert ignore into users (id, firstname, lastname, email, password_hash, phone)
values ('1', 'Dean', 'Simpson', 'orin1988@example.com', 'adfsasdfadfwqef', '98754112336');

insert into users (firstname, lastname, email, phone)
values ('Sam', 'Known', 'orin1989@example.com', null);

insert into users (firstname, lastname, email)
values ('Jeff', 'Viper', 'orin1990@example.com');

insert ignore into users 
values ('6', 'John', 'Delan', 'orin1991@example.com', 'sfvvgfbdrdyb', '651982152323')

-- В КУРСОВОЙ ПАКЕТНУЮ ВСТАВКУ
insert into users (firstname, lastname, email, phone)
values
('Yar', 'Bush', 'orin1992@example.com', null),
('Kohen', 'Sing', 'orin1993@example.com', '98566471255'),
('Ron', 'Pich', 'orin1994@example.com', '4958885575'),
('Vasya', 'Pupkin', 'orin1995@example.com', null);

-- видно соответствие (что куда вставляем)
insert into users 
set
	firstname = 'Donald',
	lastname = 'Wattson';
	
-- с командой select 
insert into users (firstname, lastname, phone)
select '1', '2', '3'

insert into users (firstname, lastname, email)
select first_name, last_name, email from sakila.staff;

___________________________________________________________________________

select 1+10; -- математика
select '1'; -- вывод того, что в кавычках

select * from users; -- лучше в таком виде не использовать, дурной тон (включает в себя все поля из таблицы users)

select firstname, lastname from users; -- выведет все эти поля из users

select distinct firstname from users; -- только уникальные значения из полей указанной таблицы
select distinct firstname, lastname from users; -- смотрит уникальность пары значений (не уберет значения, если по одному полю есть повторы)

select *from users
where id=1; -- вывод по конкретному полю

select * from users
where id>2 and id<8; -- вывод по конкретному полю

select * from users
limit 5; -- первые 5 из таблицы 


select * from users
limit 5 offset 6; -- первые 5 из таблицы начиная с номера 6

select * from users
order by id desc
limit 5; -- за счет атрибута desc отсчет начинается с конца и берутся первые 5 именно с конца

select * from users
order by firstname; -- сортировка в алфавитном порядке

select * from users
where email is null; -- работа с null (обязательно пишем is null)

-- если ищем 0 или пустую строку пишем:
select * from users
where email = 0;

select * from users
where email = '';

___________________________________________________________________________


insert into vk.friend_requests (initiator_user_id, target_user_id, status)
values
(1, 2, 'requested'),
(1, 6, 'requested'),
(1, 7, 'requested'),
(1, 9, 'requested');

update friend_requests 
set
	status = 'approved'
where initiator_user_id  = 1 and target_user_id = 2;

update friend_requests 
set
	status = 'declined'
where initiator_user_id  = 1 and target_user_id = 6;


insert into vk.messages (from_user_id, to_user_id, body)
values
(1, 2, 'Hello'),
(6, 1, 'Everybody');

___________________________________________________________________________

delete from messages
where from_user_id = 1;

-- через сложный запрос

delete from messages 
where from_user_id in (
select id from users 
where lastname='Simpson');

___________________________________________________________________________

truncate messages;


