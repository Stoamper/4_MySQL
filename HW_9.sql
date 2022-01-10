-- Практическое задание по уроку №9 "Транзакции, переменные представления. Администрирование. Хранимые процедуры и функции, триггеры"

-- Часть 1. Практическое задание по теме “Транзакции, переменные, представления”

-- 1.	В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.
-- Примечание: изначально таблица users в БД sample была пустая. Поэтому воспользовался вставкой через insert.
start transaction;
use shop;
select @name_1 := name from users where id = 1;
use sample;
insert into users(name) values (@name_1);
commit;


-- 2.	Создайте представление, которое выводит название name товарной позиции из таблицы products и 
-- соответствующее название каталога name из таблицы catalogs.
use shop;
create or replace view products_data as select p.name as products, c.name as catalogs from products p join catalogs c
on p.catalog_id = c.id;
select * from products_data;



-- 3.	(по желанию) Пусть имеется таблица с календарным полем created_at. 
-- В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. 
-- Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, 
-- если дата присутствует в исходном таблице и 0, если она отсутствует.




-- 4.	(по желанию) Пусть имеется любая таблица с календарным полем created_at. 
-- Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.

-- Создадим таблицу с данными
use shop;
DROP TABLE IF EXISTS test_created_at_2;
CREATE TABLE test_created_at_2 (
  id SERIAL PRIMARY KEY,
  `date` DATE not null);

INSERT INTO test_created_at_2
  (`date`)
VALUES
  ('2018-08-01'),
  ('2018-08-04'),
  ('2018-08-06'),
  ('2018-08-07'),
  ('2018-08-09'),
  ('2018-08-10'),
  ('2018-08-13'),
  ('2018-08-16'),
  ('2018-08-17');

 -- Создадим представление, которое будет выводить 5 самых свежих дат
create or replace view fresh as
select * from test_created_at_2 order by `date` desc limit 5;

select * from fresh;

______________________________________________________________________
-- Часть 2. Практическое задание по теме “Администрирование MySQL”

-- 1.	Создайте двух пользователей которые имеют доступ к базе данных shop. 
-- Первому пользователю shop_read должны быть доступны только запросы на чтение данных, 
-- второму пользователю shop — любые операции в пределах базы данных shop.

-- Создадим пользователей 1 и 2
drop user 'test_user_1'@'localhost';
drop user 'test_user_2'@'localhost';

create user 'test_user_1'@'localhost';
create user 'test_user_2'@'localhost';

-- Убедимся, что пользователи были созданы
select host, user from mysql.user;

-- Назначим пользователю test_user_1 права на чтение из БД shop
grant select on shop.* to 'test_user_1'@'localhost';

-- Назначим пользователю test_user_2 права на любые операции в пределах БД shop
grant all  on shop.* to 'test_user_2'@'localhost';

-- Проверим, вступили ли привилегии в силу:
-- для пользователя test_user_1
show grants for 'test_user_1'@'localhost';

-- для пользователя test_user_2
show grants for 'test_user_2'@'localhost';




-- 2.	(по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, 
-- содержащие первичный ключ, имя пользователя и его пароль. 
-- Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name. 
-- Создайте пользователя user_read, который бы не имел доступа к таблице accounts, 
-- однако, мог бы извлекать записи из представления username.

-- Создадим тестовую таблицу accounts и заполним ее данными
use shop;
DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
  id SERIAL PRIMARY KEY,
  name varchar(255) not null,
  `password` varchar(255));

INSERT INTO accounts
  (name, `password`)
VALUES
  ('Will Koen', 'asdfrfVV11'),
  ('Lourence Bush', '4334ffsd'),
  ('Mike Somerset', 'werwer1'),
  ('Lili People', 'tguRR1119'),
  ('Rick Simons', '99gydhcvk54');

-- Создадим представление username таблицы accounts, предоставляющий доступ к столбца id и name
create or replace view username as select id, name from accounts;

-- Создадим пользователя user_read, который бы не имел доступа к таблице accounts, но мог бы извлекать записи из представления username.
drop user if exists 'user_read'@'localhost';
create user 'user_read'@'localhost';

-- Убедимся, что пользователь был создан
select host, user from mysql.user;

-- Назначим пользователю user_read права на чтение из представления username
grant select on username to 'user_read'@'localhost';

-- Проверим права для пользователя user_read
show grants for 'user_read'@'localhost';

______________________________________________________________________
-- Часть 3. Практическое задание по теме “Хранимые процедуры и функции, триггеры”
-- 1.	Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
-- с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".


drop function if exists hello_1;
delimiter // 
create function hello_1()
returns text deterministic
begin
	if hour(curtime()) >= 0 and hour(curtime()) < 6
		then return 'Доброе ночи';
	elseif hour(curtime()) >= 6 and hour(curtime()) < 12
		then return 'Доброе утро';
	elseif hour(curtime()) >= 12 and hour(curtime()) <= 18
		then return 'Добрый день';
	else return 'Добрый вечер';
	end if;
end//
delimiter ;
select hello_1();



-- 2.	В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
-- Допустимо присутствие обоих полей или одно из них. 
-- Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.

-- Запишем триггер. Генерируем в нем пользовательскую ошибку когда оба поля (name, description) принимают значение NULL
use shop;
drop trigger if exists not_null_value;
delimiter //
create trigger not_null_value before update on products 
for each row 
begin 
	if (new.name is null and new.description is null) or (old.name is null and new.description is null) or (new.name is null and old.description is null)
	then signal sqlstate '45000' set message_text = 'Delete canceled (обе ячейки не могут быть NULL)';
	end if;
end//
delimiter ;

-- Добавим новые данные в таблицу products для их редактирования
insert into products (name, description, price, catalog_id)
values ('Caviar Blue WD10EZEX 1Tb', 'Жесткий диск Caviar Blue WD10EZEX 1Tb SATA III', 3000, 4);

-- Заменим одно значение на NULL. Ошибок не возникает
update products 
SET 
	name = NULL 
WHERE 
	id = 13;
select id, name, price, catalog_id FROM products;

-- попробуем заменить описание у id=13 на NULL. Выйдет ошибка. При ручной замене значения на NULL в таблице также выходит ошибка
update products 
SET 
	description = NULL 
WHERE 
	id = 13;



-- 3.	(по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
-- Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. 
-- Вызов функции FIBONACCI(10) должен возвращать число 55.

drop function if exists fibonacci;
delimiter //
create function fibonacci(user_number INT)
returns int deterministic
begin
	declare i_1, i_2, i_3 int;
	set i_1 = 0; -- переменная для сложения (одно из двух предыдущих чисел)
	set i_2 = 1; -- переменная для сложения (одно из двух предыдущих чисел)
	set i_3 = 2; -- переменная-счетчик
	if user_number = 0
	then return 0;
	elseif user_number = 1
	then return 1;
	else while i_3 <= user_number do
			set i_2 = i_2 + i_1;
			set i_1 = i_2 - i_1;
			set i_3 = i_3 + 1;
		 end while;
	end if;
	return i_2;
end//
delimiter ;

-- Проверим работу функции (результат 55)
select fibonacci(10);






_________________TEST_________________________________________TEST____________________

-- Часть 1, задача 2 
-- каталоги выводятся цифрами
use shop;
create or replace view products_data as select name, catalog_id from products;
select * from products_data;


-- ПРИКИДКИ ПО ТРЕТЬЕЙ ЗАДАЧЕ (ДО КОНЦА НЕ ДОДЕЛАНА)
-- 3.	(по желанию) Пусть имеется таблица с календарным полем created_at. 
-- В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. 
-- Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, 
-- если дата присутствует в исходном таблице и 0, если она отсутствует.

-- Создадим  и заполним таблицу с исходными данными created_at
use shop;
DROP TABLE IF EXISTS test_created_at;
CREATE TABLE test_created_at (
  id SERIAL PRIMARY KEY,
  `date` DATE not null);

INSERT INTO test_created_at
  (`date`)
VALUES
  ('2018-08-01'),
  ('2018-08-04'),
  ('2018-08-16'),
  ('2018-08-17');
  

-- Создание таблицы с заполнением всеми днями из августа
DROP TABLE IF EXISTS august_compare;
CREATE TABLE august_compare (
  id SERIAL PRIMARY KEY,
  `date` DATE not null,
  repeat_day tinyint);

drop procedure if exists filldates;
delimiter // 
create procedure filldates(date_start DATE, date_end DATE)
begin
	while date_start <= date_end DO
		insert into august_compare 
			(`date`) 
		values
			(date_start);
		set date_start = date_add(date_start, interval 1 day);
	end while;
end;
delimiter ;
call filldates('2018-08-01', '2018-08-31');


-- Запрос, который выводит полный список дат за август 2018
create or replace view august as select * from august_compare
with check option;

select * from august;

if august.date = test_created_at.date
then insert into august.repeat_day values (0);


