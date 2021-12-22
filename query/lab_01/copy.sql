copy public.artist(artist_name, genre, fans_counter, website, viewer_discretion) from '/artist.csv' delimiter ',' csv;

copy public.concert(id, country, city, concert_date, artist_name, discretion_advised) from '/concert.csv' delimiter ',' csv;

copy public.fan(id, firstname, surname, fan_age) from '/fans.csv' delimiter ',' csv;

copy public.ticket(concert_id, fan_id, price) from '/tickets.csv' delimiter ',' csv;
