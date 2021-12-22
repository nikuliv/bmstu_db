create table if not exists public.artist (
	artist_name text primary key,
	genre text,
	fans_counter int,
	website text,
	viewer_discretion int
);

create table if not exists public.concert (
	id serial primary key,
	country text,
	city text,
	concert_date text,
	artist_name text,
	discretion_advised int,
	foreign key (artist_name) references public.artist (artist_name)
);

create table if not exists public.fan (
	id serial primary key,
	firstname text,
	surname text,
	fan_age int
);

create table if not exists public.ticket (
	concert_id int,
	fan_id int,
	foreign key (concert_id) references public.concert (id),
	foreign key (fan_id) references public.fan (id),
	price int
);

--drop table public.artist cascade;
--drop table public.concert cascade;
--drop table public.fan cascade;
--drop table public.ticket cascade;