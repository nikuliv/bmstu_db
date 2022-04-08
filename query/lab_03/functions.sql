-- 1
create or replace function get_avg_fans(music_genre text)
returns integer as $$
    declare res integer;
begin
    select avg(fans_counter) into res
    from artist
    where genre = music_genre;
    return res;
end;
$$ language plpgsql;

select get_avg_fans('Rock');
select get_avg_fans('Pop');

select distinct artist_name, genre, avg(fans_counter)
over(partition by genre) as avg_fans
from artist;

select artist_name 
from artist
where fans_counter in (select max(fans_counter)
						from artist
						where genre = 'Rock');


-- 2
drop function get_concerts_by_age;
create or replace function get_concerts_by_age(fan_age integer)
returns table (artist_name text, country text, city text, concert_date text)
as $$
begin
    return query
        select concert.artist_name, concert.country, concert.city, concert.concert_date
        from concert
        where discretion_advised <= fan_age;
end
$$ language plpgsql;

select * from get_concerts_by_age(3);

-- 3
create or replace function find_concert_by_genre(music_genre text)
returns table (artist_name text, 
				country text, 
				city text, 
				concert_date text,
				discretion_advised int
) as $$
begin
	--drop table tbl;
    create temp table tbl (artist_name text, 
							country text, 
							city text, 
							concert_date text,
							discretion_advised int
	);
   
    insert into tbl (artist_name, country, city, concert_date, discretion_advised)
    select c.artist_name, c.country, c.city, c.concert_date, c.discretion_advised 
    from concert c
    where c.artist_name in (select artist.artist_name
   							from artist
   							where artist.genre like music_genre);
    return query
    select * from tbl;
end;
$$ language plpgsql;

select * from find_concert_by_genre('Rock');




drop table FamilyTree cascade;
CREATE TABLE FamilyTree ( 
        FamilyMemberID int NOT NULL, 
        FirstName text NOT NULL, 
        LastName text NOT NULL, 
        Title text NOT NULL, 
        GenID int NOT NULL, 
        ParentID int NULL, 
        CONSTRAINT PK_FamilyMemberID PRIMARY KEY (FamilyMemberID) 
);
-- Заполнение таблицы значениями. 
-- 
INSERT INTO FamilyTree 
VALUES (1, N'Илья', N'Семенов', N'Слесарь',1,null),
		(2, N'Виктор', N'Семенов', N'Плотник',2,1),
		(3, N'Александр', N'Семенов', N'Сварщик',2,1),
		(4, N'Семён', N'Сволов', N'Слесарь',3,2);
-- 4
--drop function get_family_member_by_generation;
create or replace function get_family_member_by_generation(gen int)
returns table (
    ParentID int,
	FirstName text,
    FamilyMemberID int,
    Title text,
    GenID int
) as $$
begin
    return query
    WITH recursive ElderReports (ParentID, FirstName, FamilyMemberID, Title, GenID, Level) AS 
	( 
        -- Определение закрепленного элемента 
	    SELECT e.ParentID, e.FirstName, e.FamilyMemberID, e.Title, e.GenID, 0 AS Level 
	    FROM FamilyTree AS e 
	    WHERE e.ParentID IS NULL 
	    UNION ALL 
	    -- Определение рекурсивного элемента 
       SELECT e.ParentID, e.FirstName, e.FamilyMemberID, e.Title, e.GenID, d.Level + 1 
       FROM FamilyTree AS e INNER JOIN ElderReports AS d 
	                   ON e.ParentID = d.FamilyMemberID 
	)
	SELECT e.ParentID, e.FirstName, e.FamilyMemberID, e.Title, e.GenID 
	FROM ElderReports e
	where e.Level = gen;
end;
$$ language plpgsql;

select * from get_family_member_by_generation(1);
drop table FamilyTree cascade;