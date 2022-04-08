-- Выполнить скалярный запрос.
-- Вывести среднее количество фанатов у исполнителей в жанре "Pop".
SELECT AVG(FANS_COUNTER) AS avg_fans_counter
FROM artist
WHERE genre = 'Pop';

-- Выполнить запрос с несколькими соединениями (JOIN).
-- Вывести сведения о концертах и билетах.
SELECT *
FROM concert c JOIN (select price, concert_id
					 from ticket t2) t
					ON t.concert_id = c.id;

-- Выполнить запрос с ОТВ(CTE) и оконными функциями.
-- Создать таблицу с концертами самых популярных исполнителей.
-- Вывести таблицу концертов с усредненной ценой билетов по странам.
WITH concerts_of_popular_artists (id, country, city, concert_date, artist_name, discretion_advised, price) AS (
	select id, country, city, concert_date, artist_name, discretion_advised, price
	from 
    (SELECT id, country, city, concert_date, artist_name, discretion_advised
    FROM concert c
    WHERE artist_name in (select artist_name
    						from artist
    						where fans_counter > 10000000)) c
    left join
    (select price, concert_id
	from ticket) t on c.id = t.concert_id 					
)
SELECT DISTINCT id, country, city, concert_date, artist_name, discretion_advised, AVG(price) OVER(PARTITION BY country) AS avg_price FROM concerts_of_popular_artists;

-- Выполнить запрос к метаданным.
-- Вывести id и лимит подключений к текущей базе данных.
SELECT pg.oid, pg.datconnlimit FROM pg_database pg WHERE pg.datname = 'db_music';

-- Вызвать скалярную функцию (написанную в третьей лабораторной работе).
/*create or replace function get_avg_fans(music_genre text)
returns integer as $$
    declare res integer;
begin
    select avg(fans_counter) into res
    from artist
    where genre = music_genre;
    return res;
end;
$$ language plpgsql;
*/
select get_avg_fans('Rock');

-- Вызвать многооператорную или табличную функцию (написанную в третьей лабораторной работе).
select * from find_concert_by_genre('Rock');

-- Вызвать хранимую процедуру (написанную в третьей лабораторной работе).
call update_fans_counter('Daft Punk', 700000000);
select *
from artist
where artist_name = 'Daft Punk';

-- Вызвать системную функцию или процедуру.
-- Вывести имя текущей базы данных.
SELECT * FROM current_database();

-- Создать таблицу в базе данных, соответствующую тематике БД.
-- Создать таблицу доступного в данном жилье транспорта.
drop table merch cascade;
create table if not exists merch (
	id serial primary key,
	artist text,
	foreign key (artist) references artist(artist_name),
	m_type text,
	price DECIMAL(6,2) CHECK (price >= 0)
);

-- Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY.
-- Вставить транспорт в таблицу.
drop table merch cascade;
INSERT INTO merch (id, artist, m_type, price)
VALUES (113, 'Eminem', 't-shirt', 30);