-- Практическое задание к уроку №11 по теме “Оптимизация запросов”



-- 1) Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, 
-- catalogs и products в таблицу logs помещается время и дата создания записи, название таблицы, 
-- идентификатор первичного ключа и содержимое поля name.
show engines;

-- Создание таблицы logs
use shop;
drop table if exists logs;
create table logs(
	`date` datetime,
	table_name varchar(255),
	id_PK bigint unsigned not null,
	information_name varchar(255)
) engine=archive;

-- select * from logs;

-- Создание триггера для добавления данных в таблицу logs при вставке в таблицу users
delimiter //
create trigger users_insert after insert on users
for each row
begin 
	insert into logs (`date`, table_name, id_PK, information_name) 
	values
		(new.created_at, 'users', new.id, new.name);
end//
delimiter ;

-- Создание триггера для добавления данных в таблицу logs при вставке в таблицу catalogs
delimiter //
create trigger catalogs_insert after insert on catalogs
for each row
begin 
	insert into logs (`date`, table_name, id_PK, information_name) 
	values
		(now(), 'catalogs', new.id, new.name);
end//
delimiter ;

-- Создание триггера для добавления данных в таблицу logs при вставке в таблицу products
delimiter //
create trigger products_insert after insert on products
for each row
begin 
	insert into logs (`date`, table_name, id_PK, information_name) 
	values
		(new.created_at, 'products', new.id, new.name);
end//
delimiter ;

-- Ввод дополнительной информации для проверки работы триггеров
insert into users (name, birthday_at)
values
	('Николай', '1997-12-12');

insert into catalogs (name)
values
	('Сетевые платы');

insert into products (name, description, price, catalog_id)
values
	('Ultrastar DC HC550', 'Жесткий диск Ultrastar DC HC550 18Tb SATA III', 38100, 4);



-- 2) Создайте SQL-запрос, который помещает в таблицу users миллион записей.
-- Создадим процедуру, добавляющую в таблицу users миллион записей
drop procedure if exists million_users;
delimiter //
create procedure million_users()
begin
	declare i bigint unsigned;
	declare j bigint unsigned;
	-- set i = 2; -- тестовое значение для проверки работы процедуры
	set i = 1000000; -- фиксированное значение (граница, общее количество пользователей)
	set j = 1; -- переменная-счетчик
	while j <= i do
		insert into users (name, birthday_at)
		values
			(concat('user_', j), (current_date - interval floor(rand() * 18250) day)); -- заполняем таблицу пользователями, дату рождения выбираем произвольную из последних 50 лет
		set j = j + 1; -- увеличиваем значение счетчика
	end while;
end//
delimiter ;

-- Вызываем процедуру для заполнения таблицы данными
call million_users(); 

 
