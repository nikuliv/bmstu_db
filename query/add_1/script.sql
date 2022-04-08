drop table if exists Table1 cascade;
drop table if exists Table2 cascade;


create table Table1
(
    id int,
    var1 text,
    valid_from_dttm date,
    valid_to_dttm date
);

create table Table2
(
    id int,
    var2 text,
    valid_from_dttm date,
    valid_to_dttm date
);

insert into Table1 
values  (1, 'A', '2018-09-01', '2018-09-15'),
    	(1, 'B', '2018-09-16', '5999-12-31');


insert into Table2 
values  (1, 'A', '2018-09-01', '2018-09-18'),
		(1, 'B', '2018-09-19', '5999-12-31');


select * 
from (select t1.id as id, t1.var1 as var1, t2.var2 as var2,
      greatest(t1.valid_from_dttm, t2.valid_from_dttm) as valid_from_dttm,
      least(t1.valid_to_dttm, t2.valid_to_dttm) as valid_to_dttm
	  from Table1 t1, Table2 t2
	  where t1.id = t2.id) as result
where valid_to_dttm >= valid_from_dttm
order by id;