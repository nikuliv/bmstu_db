alter table public.artist add constraint name_check check (artist_name is not null);
alter table public.artist add constraint fans_counter_check 
			check (fans_counter > 0 AND fans_counter < 8000000000);
alter table public.artist add constraint website_check check (website LIKE 'http%');

alter table public.concert add constraint concert_id_check check (id is not null);
alter table public.concert add constraint concert_date_check check (concert_date like '__/__/____ __:__ _M');
alter table public.concert add constraint artist_name_check check (artist_name IS NOT null);

alter table public.fan add constraint fan_id_check check (id is not null);
alter table public.fan add constraint fan_age_check check (fan_age > 0 AND fan_age < 100);

alter table public.ticket add constraint fan_id_check check (fan_id is not null);
alter table public.ticket add constraint concert_id_check check (concert_id is not null);
alter table public.ticket add constraint price_check check (price > 99 AND price < 1001);