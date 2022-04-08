-- 5
create or replace procedure update_fans_counter(aname text, new_cnt int)
as $$
begin
    update artist
    set fans_counter = new_cnt
    where artist_name = aname;
end;
$$ language plpgsql;

call update_fans_counter('Daft Punk', 700000000);
select *
from artist
where artist_name = 'Daft Punk';

drop procedure delete_artists;
create or replace procedure delete_artists(dgenr text, dcountry text)
as $$
begin
    create temp table artists_to_delete as
	select artist_name
	from artist
	where genre = dgenr and artist_name in (select artist_name 
											from concert
											where country = dcountry);
	delete
	from ticket
	where concert_id in (select id
							from concert
							where artist_name in (select *
													from artists_to_delete));									
	
	delete
	from concert
	where artist_name in (select *
								from artists_to_delete);
	delete
	from artist
	where artist_name in (select *
							from artists_to_delete);
						
end;
$$ language plpgsql;

drop table artists_to_delete;
create temp table artists_to_delete as
	select artist_name
	from artist
	where genre = 'Pop' and artist_name in (select artist_name 
											from concert
											where country = 'Russia');
	select *
	from ticket
	where concert_id in (select id
							from concert
							where artist_name in (select *
													from artists_to_delete));
	select *
	from concert
	where country = 'Russia' and artist_name in (select *
											from artists_to_delete);
	select *
	from artist
	where artist_name in (select *
							from artists_to_delete);

select *
from artist
where genre = 'Pop' and artist_name in (select artist_name 
										from concert
										where country = 'Russia');

call delete_artists('avsa', 'asfasf');




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
INSERT INTO FamilyTree 
VALUES (1, N'Илья', N'Семенов', N'Слесарь',1,null),
		(2, N'Виктор', N'Семенов', N'Плотник',2,1),
		(3, N'Александр', N'Семенов', N'Сварщик',2,1),
		(4, N'Зигмунд', N'Семенов', N'Слесарь',3,3);

---- 6
create or replace procedure find_elder(fid int4)
as $$
declare
    parent_id int;
    cur_par_id int;
begin
    select f.ParentID into parent_id
    from FamilyTree f
    where f.FamilyMemberID = fid;
    if parent_id is null then
        raise notice 'Elder';
    else
        select f.ParentID into cur_par_id
        from FamilyTree f
        where f.FamilyMemberID = fid;
        raise notice 'It is a kid - %', cur_par_id;
        call find_elder(cur_par_id);
    end if;
end;
$$ language plpgsql;

call find_elder(4);

-- 7
create or replace procedure fetch_concert_by_age(fage int)
as $$
declare
    reclist record;
    listcur cursor for
        select c.artist_name, c.country, c.city, c.concert_date
        from concert c
        where discretion_advised <= fage;
begin
    open listcur;
    loop
        fetch listcur into reclist;
        raise notice '% | % | % | % |', 
       			reclist.artist_name, reclist.country, reclist.city, reclist.concert_date;
        exit when not found;
    end loop;
    close listcur;
end;
$$ language plpgsql;

call fetch_concert_by_age(3);

-- 8
create or replace procedure get_db_metadata(dbname text)
as $$
declare
    dbid int;
    dbconnlimit int;
begin
    select pg.oid, pg.datconnlimit into dbid, dbconnlimit
    from pg_database pg
    where pg.datname = dbname;
    raise notice 'db: %, id: %, connection limit: %', dbname, dbid, dbconnlimit;
end;
$$ language plpgsql;

call get_db_metadata('db_music');


create or replace procedure find_concerts(fanid int)
as $$
declare
    reclist record;
    listcur cursor for
        select c.artist_name, c.country, c.city, c.concert_date
        from concert c
        where c.id in (select t.concert_id
       					from ticket t
       					where t.fan_id = fanid) and c.artist_name notnull
       											and c.country notnull;
begin
    open listcur;
    loop
        fetch listcur into reclist;
        raise notice '% | % | % | % |', 
       			reclist.artist_name, reclist.country, reclist.city, reclist.concert_date;
        exit when not found;
    end loop;
    close listcur;
end;
$$ language plpgsql;

call find_concerts(1241);