create extension if not exists plpython3u;
-- 1
create or replace function get_fan_birth_year(fage int)
returns int4
as $$
    return extract(year from current_date) - fage;
$$ language plpython3u;

select fan.id, fan.firstname, fan.surname, get_fan_birth_year(fan.fan_age)
from fan;

-- 2
create or replace function get_latest_fan_birth_year()
returns decimal
as $$
    query = 'select get_fan_birth_year(fan_age) from fan;'
    result = plpy.execute(query)
    qlatest = 0
    for elem in result:
    	cur = elem['get_fan_birth_year']
    	if cur > qlatest:
    		qlatest = cur
    return qlatest
$$ language plpython3u;

select get_latest_fan_birth_year();

-- 3
create or replace function find_superstars(criteria int)
returns table (artist_name text, 
				genre text, 
				fans_counter int, 
				website text,
				viewer_discretion int
) as $$
    query = f"select a.artist_name, a.genre, a.fans_counter, a.website, a.viewer_discretion from artist a where a.fans_counter > '{criteria}';"
    result = plpy.execute(query)
    for elem in result:
        yield(elem["artist_name"], elem["genre"], elem["fans_counter"], elem["website"], elem["viewer_discretion"])
$$ language plpython3u;

select * from find_superstars('1000000');



--4
create or replace procedure replace_concert_to_Tver(country text)
as $$
    plan = plpy.prepare(
        "update concert set country = 'Russia', city = 'Tver' where country = $1;",
        ["text"]
    )
    plpy.execute(plan, [cntr])
$$ language plpython3u;

call replace_concert_to_Tver('Botswana');


-- 5
drop function clr_fans_check cascade;
create or replace function clr_fans_check()
returns trigger
as $$
    aname = TD["new"]["artist_name"]
    plan = plpy.prepare(
        "select a.fans_counter from artist a where a.artist_name = $1;",
        ["text"]
    )
    fans = plpy.execute(plan, [aname])
    if fans[0]["fans_counter"] > 1000000:
        plpy.notice(f"Everyone talking about {TD['new']['artist_name']}.")
    else:
        plpy.notice(f"Yet another musician.")

$$ language plpython3u;

create trigger trg_clr_fans_check 
after insert on concert
for row execute procedure clr_fans_check();

insert into concert (id, country, city, concert_date, artist_name, discretion_advised)
values (
	45001,
	'Russia',
	'Tver',
	'14/12/2023 02:11 AM',
    'Ships Fly Up',
    0
);

delete
from concert
where id = 45001;

-- 6
create type artist_card as (
    artist_name text,
    website text
);
create or replace function set_artist_card(aname text, web text)
returns setof artist_card
as $$
    return ([aname, web],)
$$ language plpython3u;
select * from set_artist_card('Ships Fly Up', 'https://band.link/shipsflyup');










create or replace function clr_find_concerts(fanid int)
returns table (artist_name text, 
				country text, 
				city text, 
				concert_date text
) as $$
    query = f"select c.artist_name, c.country, c.city, c.concert_date from concert c where c.id in (select t.concert_id from ticket t where t.fan_id = '{fanid}')"
    result = plpy.execute(query)
    for elem in result:
        yield(elem["artist_name"], elem["country"], elem["city"], elem["concert_date"])
$$ language plpython3u;

select * from clr_find_concerts('1241');
