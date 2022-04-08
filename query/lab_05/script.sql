-- 1. Из таблиц базы данных, созданной в первой лабораторной работе, извлечь данные в JSON.
/*\c db_music

\o /artist.json
SELECT ROW_TO_JSON(r) FROM artist r;

\o /concert.json
SELECT ROW_TO_JSON(r) FROM concert r;

\o /fan.json
SELECT ROW_TO_JSON(r) FROM fan r;

\o /ticket.json
SELECT ROW_TO_JSON(r) FROM ticket r;
*/

-- Выполнить загрузку и сохранение XML или JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.
drop table artists_from_json;
CREATE TABLE artists_from_json (
    artist_name text  not null primary key,
	genre text not null,
	fans_counter int not null,
	website text not null,
	viewer_discretion int not null
);
drop table temp;


CREATE TABLE temp (
    data jsonb
);
COPY temp (data) FROM '/artist.json';

select *
from temp;

INSERT INTO artists_from_json (artist_name, genre, fans_counter, website, viewer_discretion)
SELECT 
	data->>'artist_name',
	data->>'genre',
	(data->>'fans_counter')::INT,
	data->>'website',
	(data->>'viewer_discretion')::INT
FROM temp;

select *
from artists_from_json;

-- Создать таблицу, в которой будет атрибут(-ы) с типом XML или JSON, или
-- добавить атрибут с типом XML или JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT
-- или UPDATE.
drop table json_table;
CREATE TABLE json_table (
    artists jsonb
);

INSERT INTO json_table (artists) VALUES 
('{"name": "Rihanna", "genre": "Pop", "fans_counter": 100619514, "concert": {"country": "Russia", "city": "Tver"}}'), 
('{"name": "2Pac", "genre": "Rap", "fans_counter": 18482818, "concert": {"country": "Ukraine", "city": "Kiev"}}');

select *
from json_table;

-- Извлечь JSON фрагмент из JSON документа.
SELECT artists->'concert' concert FROM json_table;

-- Извлечь значения конкретных узлов или атрибутов JSON документа.
SELECT artists->'concert'->'country' country FROM json_table;

-- Выполнить проверку существования узла или атрибута.
CREATE FUNCTION if_atr_exists(json_to_check jsonb, key text)
RETURNS BOOLEAN 
AS $$
BEGIN
    RETURN (json_to_check->key) IS NOT NULL;
END;
$$ LANGUAGE PLPGSQL;
SELECT if_atr_exists('{"country": "Russia", "city": "Tver"}', 'country');
SELECT if_atr_exists('{"country": "Russia", "city": "Tver"}', 'date');

-- Изменить JSON документ.
UPDATE json_table 
SET artists = jsonb_set(artists, '{fans_counter}', '20000000') 
WHERE (artists->'fans_counter')::INT < 20000000;

-- Разделить JSON документ на несколько строк по узлам.
SELECT * FROM jsonb_array_elements('[
	{"name": "Rihanna", "genre": "Pop", "fans_counter": 100619514, "concert": {"country": "Russia", "city": "Tver"}}, 
	{"name": "2Pac", "genre": "Rap", "fans_counter": 18482818, "concert": {"country": "Ukraine", "city": "Kiev"}}
	]');
