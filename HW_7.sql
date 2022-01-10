-- Практическое задание по уроку №7 "Сложные запросы"

use shop;

-- 1.	Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
-- 1.1 Заполним таблицу orders
INSERT INTO orders
  (user_id)
VALUES
  (1),
  (3),
  (5),
  (1),
  (3),
  (5),
  (1),
  (1),
  (4);

-- 1.2 С помощью вложенного запроса обратимся к таблице orders для вывода всех пользователей, которые в ней есть
-- Выведем имена без повтором используя атрибут distinct
select distinct 
	(select name from users where id=orders.user_id) as 'Have_1_and_more_purchases'	
from orders;


-- 2.	Выведите список товаров products и разделов catalogs, который соответствует товару.
select 
	products.id, products.name, catalogs.name 
from catalogs left join products -- left т.к. есть пустые каталоги. Их тоже желательно вывести
on catalogs.id = products.catalog_id
order by products.id;



-- 3.	(по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
-- Поля from, to и label содержат английские названия городов, поле name — русское. 
-- Выведите список рейсов flights с русскими названиями городов.

-- 3.1 Создадим таблицы flights и cities. Наполним их данными
DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
  id SERIAL PRIMARY KEY,
  `from` VARCHAR(255) not null,
  `to` VARCHAR(255) not null);

INSERT INTO flights
  (`from`, `to`)
VALUES
  ('moscow', 'omsk'),
  ('novgorod', 'kazan'),
  ('irkutsk', 'moscow'),
  ('omsk', 'irkutsk'),
  ('moscow', 'kazan');

DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
  label VARCHAR(255) not null,
  name VARCHAR(255) not null);

INSERT INTO cities
  (label, name)
VALUES
  ('moscow', 'Москва'),
  ('irkutsk', 'Иркутск'),
  ('novgorod', 'Новгород'),
  ('kazan', 'Казань'),
  ('omsk', 'Омск');

 
 -- 3.2 Выведем список рейсов с русскими названиями городов
select id, cities_from.name as 'from', cities_to.name as 'to'
from flights
join cities cities_from on cities_from.label = flights.from
join cities cities_to on cities_to.label = flights.`to` 
order by flights.id;



