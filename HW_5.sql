-- Практическое задание по теме "Операторы, фильтрация, сортировка и ограничение"

-- 1.	Пусть в таблице users поля created_at и updated_at оказались незаполненными. 
-- Заполните их текущими датой и временем.

-- Данные поля находятся в таблице profiles, заполним там
use vk;
alter table `profiles` add column updated_at DATETIME DEFAULT NOW(); -- добавляем отсутствующий стоблец

update profiles set created_at = now(), updated_at = now(); -- заполняем текущими датой и временем


-- 2.	Таблица users была неудачно спроектирована. 
-- Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате 20.10.2017 8:10. 
-- Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.

-- Поскольку информация изначально хранится в таблице profiles, все действия будем производить с ней
-- Добавим в нее столбцы с типом VARCHAR для последющего редактирования
use vk;

select * from profiles;

-- добавим столбец для данных в формате VARCHAT
alter table `profiles` add column created_at_test VARCHAR(255);


-- добавление данных в тестовый столбец с данными в формате VARCHAR
update profiles set created_at_test = '20.10.2017 08:10' where user_id = 1;
update profiles set created_at_test = '15.10.2018 17:15' where user_id = 2;
update profiles set created_at_test = '11.11.2019 12:15' where user_id = 3;
update profiles set created_at_test = '12.12.2017 13:15' where user_id = 4;
update profiles set created_at_test = '13.01.2018 14:15' where user_id = 5;
update profiles set created_at_test = '20.02.2019 15:15' where user_id = 6;
update profiles set created_at_test = '23.03.2017 16:15' where user_id = 7;
update profiles set created_at_test = '25.04.2018 17:15' where user_id = 8;
update profiles set created_at_test = '27.05.2019 18:15' where user_id = 9;
update profiles set created_at_test = '30.06.2018 19:15' where user_id = 10;

-- По какой-то причине не удается вставить данные с помощью пакетной вставки (код ниже)
-- insert into profiles (created_at_test)
-- values
-- ('2020-01-02 18:10'),
-- ('2020-11-05 12:10'),
-- ('2020-01-03 08:17'),
-- ('2020-02-15 15:10'),
-- ('2020-01-30 17:10'),
-- ('2020-12-31 19:10'),
-- ('2020-01-14 01:10'),
-- ('2020-03-08 08:10'),
-- ('2020-01-02 05:25'),
-- ('2020-07-22 11:10');

-- Перевод данных к формату DATETIME осуществляем с помощью функции STR_TO_DATE
update profiles set created_at_test = (select STR_TO_DATE(created_at_test , '%d.%m.%Y %H:%i')) where user_id = 1;
update profiles set created_at_test = (select STR_TO_DATE(created_at_test , '%d.%m.%Y %H:%i')) where user_id = 2;
update profiles set created_at_test = (select STR_TO_DATE(created_at_test , '%d.%m.%Y %H:%i')) where user_id = 3;
update profiles set created_at_test = (select STR_TO_DATE(created_at_test , '%d.%m.%Y %H:%i')) where user_id = 4;
update profiles set created_at_test = (select STR_TO_DATE(created_at_test , '%d.%m.%Y %H:%i')) where user_id = 5;
update profiles set created_at_test = (select STR_TO_DATE(created_at_test , '%d.%m.%Y %H:%i')) where user_id = 6;
update profiles set created_at_test = (select STR_TO_DATE(created_at_test , '%d.%m.%Y %H:%i')) where user_id = 7;
update profiles set created_at_test = (select STR_TO_DATE(created_at_test , '%d.%m.%Y %H:%i')) where user_id = 8;
update profiles set created_at_test = (select STR_TO_DATE(created_at_test , '%d.%m.%Y %H:%i')) where user_id = 9;
update profiles set created_at_test = (select STR_TO_DATE(created_at_test , '%d.%m.%Y %H:%i')) where user_id = 10;


-- 3.	В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 
-- 0, если товар закончился и выше нуля, если на складе имеются запасы. 
-- Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
-- Однако нулевые запасы должны выводиться в конце, после всех записей.
use gb;
create table storehouses_products (
	id serial,
	value INT
);

insert into storehouses_products (value)
values
(5),
(0),
(44),
(8),
(1),
(10),
(154),
(0),
(77),
(83),
(62);

-- для разделения значений используем функцию case совместно с order by
select value from storehouses_products 
order by case 
	when value = 0 
		then 1000 
	else value 
end



-- 4.	(по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
-- Месяцы заданы в виде списка английских названий (may, august)

-- так как родившихся в мае и в августе по таблице нет, то месяца для вывода были изменены на январь и июль
use vk;

select user_id, monthname(birthday) as `month` from profiles where month(birthday) = 1 or month(birthday) = 7;


-- 5.	(по желанию) Из таблицы catalogs извлекаются записи при помощи запроса 
-- SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.
-- Так как таблицы catalogs среди имеющихся БД нет, то отсортируем аналогичные даныне из таблицы storehouses_products
use gb;

select * from storehouses_products where id in (5, 1, 2) order by field (id, '5', '1', '2');


_______________________________________________________________________________________________________________
-- Практическое задание по теме "Агрегация данных"

-- 1.	Подсчитайте средний возраст пользователей в таблице users.
-- данные по возрасту содержатся в таблице profiles

use vk;
-- вычисление возраста всех пользователей с помощью математики
select user_id, floor((to_days(now()) - to_days(birthday)) / 365.25) from profiles;

-- вычисление возраста всех пользователей с помощью специальной фукнции timestampdiff
select user_id, timestampdiff(year, birthday, now()) as user_age from profiles;

-- вычисление среднего возраста всех пользователей
select floor(avg(timestampdiff(year, birthday, now()))) as users_average_age from profiles;


-- 2.	Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
-- Следует учесть, что необходимы дни недели текущего года, а не года рождения.

select user_id, dayname(date_format(birthday, '2021-%m-%d')) from profiles; 

-- 3.	(по желанию) Подсчитайте произведение чисел в столбце таблицы.

use gb;
drop table if exists numbers;
create table numbers(
	id serial,
	value INT
);

insert into numbers (value)
values
(1),
(2),
(3),
(4),
(5);

-- select sum(value) from numbers;
-- для расчета произведения воспользуемся следующей комбинацией функций: 
select exp(sum(ln(value))) from numbers;

-- ln - берется натуральный логариф (по основанию e) из значения в таблице
-- sum - считаем сумму всех полученных логарифмов
-- exp - возводим экспаненту в степень, которая равна посчитанной сумме

	






