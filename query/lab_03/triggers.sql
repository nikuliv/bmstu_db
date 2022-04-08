-- 9
drop function fans_check cascade;
create or replace function fans_check()
returns trigger as $$
declare
    fans int;
begin
	select a.fans_counter into fans
	from artist a
	where a.artist_name  = new.artist_name;
    if fans > 1000000 then
        raise notice 'Literally everyone talking about %.', new.artist_name;
    else
        raise notice 'Yet another musician.';
    end if;
   return new;
end;
$$ language plpgsql;

create trigger trg_fans_check 
after insert on concert
for each row
execute procedure fans_check();

delete
from concert
where id = 45000;

insert into concert (id, country, city, concert_date, artist_name, discretion_advised)
values (
	45000,
	'Russia',
	'Moscow',
	'04/11/2027 03:01 AM',
    'Chris Brown',
    0
);


-- 10
create or replace function make_mc_lose_fans()
returns trigger as $$
begin
    if lower(new.artist_name) like '%mc%' then
        insert into artist (artist_name, genre, fans_counter, website, viewer_discretion)
		values (new.artist_name, new.genre, (new.fans_counter - 1), new.website, new.viewer_discretion);
		raise notice 'Another MC...';
    else 
        insert into artist (artist_name, genre, fans_counter, website, viewer_discretion)
		values (new.artist_name, new.genre, new.fans_counter, new.website, new.viewer_discretion);
    end if;

    return new;
end;
$$ language plpgsql;

create or replace view artists as
select * from artist;

--drop trigger goods_insertion on goodsview;
create trigger trg_make_mc_lose_fans instead of
insert on artists
for each row execute procedure make_mc_lose_fans();

insert into artists (artist_name, genre, fans_counter, website, viewer_discretion)
values ('Antoha MC', 'Hip-Hop', 250000, 'https://www.antohamc.ru/', 16);

delete 
from artists
where artist_name = 'Antoha MC'