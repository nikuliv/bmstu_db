-- инструкция select, использующая предикат сравнения.
-- 1
select artist_name, fans_counter
from artist
where fans_counter > 100000;

-- инструкция select, использующая предикат between.
-- 2
select *
from concert
where concert_date between '12/31/2020 01:00 AM' and '12/31/2044 01:00 AM';

-- инструкция select, использующая предикат like.
-- 3
select artist_name, genre, viewer_discretion
from artist
where artist_name like '%$%';

-- инструкция select, использующая предикат in с вложенным подзапросом.
-- 4
select *
from concert
where artist_name in (select artist_name
				  from artist
				  where fans_counter > 200000);

-- инструкция select, использующая предикат exists с вложенным подзапросом.
-- 5
select firstname, surname
from fan
where exists (select 
			  from ticket
			  where fan.id = fan_id);

-- инструкция select, использующая предикат сравнения с квантором.
-- 6
select country, city, artist_name, discretion_advised
from concert
where discretion_advised > all(select discretion_advised
					   from concert
					   where country = 'Albania');

-- инструкция select, использующая агрегатные функции в выражениях столбцов.
-- 7
select avg(fans_counter) as avg_fans_counter
from artist
where genre = 'Pop';

-- инструкция select, использующая скалярные подзапросы в выражениях столбцов.
-- 8
select country, city, artist_name, (select max(fans_counter)
									  from artist) as max_fans 
from concert
WHERE discretion_advised = 18;

-- инструкция select, использующая простое выражение case.
-- 9
select artist_name,
case
when fans_counter > 100000000 then 'Superstar'
else cast (fans_counter as varchar)
end fans_counter
from artist;

-- инструкция select, использующая поисковое выражение case.
-- 10
select country, city, 
case
when discretion_advised = 18 then 'adults'
when discretion_advised = 6 then 'teens'
else 'kids'
end AS viewer
from concert;

-- создание новой временной локальной таблицы из результирующего набора данных инструкции select.
-- 11
--drop table superstars;
create temp table superstars as
select artist_name, genre, fans_counter
from artist
where fans_counter > 100000000;

-- инструкция select, использующая вложенные коррелированные подзапросы 
-- 12
select cn.country, cn.city, cn.artist_name, genre, fans_counter
from concert cn join (select artist_name, genre, fans_counter
						from artist
						where fans_counter > 100000000) as superstars
				on cn.artist_name = superstars.artist_name;

-- инструкция select, использующая вложенные подзапросы с уровнем вложенности 3.
-- 13
select firstname, fan_age
from fan
where id in (select fan_id
			  from ticket
			  where price > 50 and concert_id in (select id
			  			   						from concert
			  			   						where artist_name in (select artist_name
			  			   											from artist
			  			   											where genre = 'Pop'
			  			   						)
			  )
);

-- инструкция select, консолидирующая данные с помощью предложения group by, но без предложения having.
-- 14
select genre, avg(fans_counter)
from artist
group by genre;

-- инструкция select, консолидирующая данные с помощью предложения group by и предложения having.
-- 15
select *
from artist
group by artist_name
having viewer_discretion > 5;

-- однострочная инструкция insert, выполняющая вставку в таблицу одной строки значений.
-- 16
insert into artist (artist_name, genre, fans_counter, website, viewer_discretion)
values ('ЖЩ', 'Rock', 20000, 'https://vk.com/all_people_will_die', 18);

-- многострочная инструкция insert, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса.
-- 17
insert into concert (country, city, concert_date, artist_name, discretion_advised)
select 'Albania', city, concert_date, artist_name, discretion_advised
from concert
where country = 'Bahrain' AND city = 'Manama';

-- простая инструкция update.
-- 18
update artist
set fans_counter = fans_counter * 1.2
where genre = 'Rock';

-- инструкция update со скалярным подзапросом в предложении set.
-- 19
update ticket
set price = (select avg(price)
				from ticket
				where fan_id > avg(fan_id)
where concert_id = 714;

-- простая инструкция delete.
-- 20
delete
from fan
where fan_age <= 4;

-- инструкция delete с вложенным коррелированным подзапросом в предложении where.
-- 21
delete
from artist
where fans_counter in (select min(fans_counter)
						from artist
						where genre like 'Pop');

					

-- инструкция select, использующая простое обобщенное табличное выражение.
-- 22
with cte (genre, representers_count) as (select genre, count(artist_name)
										  from artist
										  group by genre
)
select avg(representers_count) as representers_count
from cte
WHERE genre = 'Rock';

-- инструкция select, использующая рекурсивное обобщенное табличное выражение.
-- 23
--Создание таблицы. 
drop table FamilyTree cascade;
CREATE TABLE FamilyTree ( 
        FamilyMemberID smallint NOT NULL, 
        FirstName text NOT NULL, 
        LastName text NOT NULL, 
        Title text NOT NULL, 
        GenID smallint NOT NULL, 
        ParentID int NULL, 
        CONSTRAINT PK_FamilyMemberID PRIMARY KEY (FamilyMemberID) 
);
-- Заполнение таблицы значениями. 
-- 
INSERT INTO FamilyTree 
VALUES (1, N'Илья', N'Семенов', N'Слесарь',16,NULL) ;
-- Определение ОТВ 
-- 
WITH recursive ElderReports (ParentID, FamilyMemberID, Title, GenID, Level) AS 
( 
        -- Определение закрепленного элемента 
        SELECT e.ParentID, e.FamilyMemberID, e.Title, e.GenID, 0 AS Level 
        FROM FamilyTree AS e 
        WHERE ParentID IS NULL 
        UNION ALL 
        -- Определение рекурсивного элемента 
       SELECT e.ParentID, e.FamilyMemberID, e.Title, e.GenID, Level + 1 
       FROM FamilyTree AS e INNER JOIN ElderReports AS d 
                   ON e.ParentID = d.FamilyMemberID 
) 
-- Инструкция, использующая ОТВ 

SELECT ParentID, FamilyMemberID, Title, GenID, Level 
FROM ElderReports;

-- оконные функции. использование конструкций min/max/avg over().
-- 24
select distinct artist_name, genre, avg(fans_counter)
over(partition by genre) as avg_fans
from artist;

-- оконные фнкции для устранения дублей.
-- 25
drop table doubling;
create table doubling as (
	select cn.artist_name, genre, fans_counter
	from concert cn join (select artist_name, genre, fans_counter
						from artist
						where fans_counter > 100000000) as superstars
				on cn.artist_name = superstars.artist_name
);
with doubling_copy as (delete
					   from doubling
					   returning *
),
doubling_with_rows as (select artist_name, genre, fans_counter, row_number()
					   over(partition by artist_name, genre, fans_counter
					   order by artist_name, genre, fans_counter) rownum
					   from doubling_copy)
insert into doubling
select artist_name, genre, fans_counter
from doubling_with_rows
where rownum = 1;