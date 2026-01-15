-- Final Progect: Relational Databases - Concepts and Techniques --

-- 1 --

drop schema if exists pandemic;
create schema if not exists pandemic;

use pandemic;

select * from infectious_cases limit 5; -- додано limit 5 щоб не перевантажувати консоль

-- 2 --

SHOW CREATE TABLE infectious_data;
ALTER TABLE infectious_data DROP FOREIGN KEY infectious_data_ibfk_1;
ALTER TABLE infectious_data DROP INDEX country_id;

drop table if exists countries;
drop table if exists infectious_data;

create table countries(
	id int primary key auto_increment,
    entity_name varchar(40),
    code varchar(10),    
    constraint unique_entity unique(entity_name)
);

insert into countries (entity_name, code)
select distinct Entity, Code from infectious_cases;

create table infectious_data(
	id int auto_increment primary key,
    country_id int not null,
    year int not null,
    number_yaws double,
    polio_cases double,
    cases_guinea_worm double,
    number_rabies double,
    number_malaria double,
    number_hiv double,
    number_tuberculosis double,
    number_smallpox double,
    number_cholera_cases double,
foreign key(country_id) references countries(id)
);

-- ic. - infeсtious_cases, c. - countries - скорочення по назвам таблиць

insert into infectious_data (
	country_id, year,
    number_yaws, polio_cases, cases_guinea_worm,
    number_rabies, number_malaria, number_hiv,
    number_tuberculosis, number_smallpox, number_cholera_cases
)
select
	c.id, ic.year,
    nullif(ic.Number_yaws, ''),
    nullif(ic.polio_cases, ''),
    nullif(ic.cases_guinea_worm, ''),
    nullif(ic.Number_rabies, ''),
    nullif(ic.Number_malaria, ''),
    nullif(ic.Number_hiv, ''),
    nullif(ic.Number_tuberculosis, ''),
    nullif(ic.Number_smallpox, ''),
    nullif(ic.Number_cholera_cases, '')
from infectious_cases ic
join countries c on ic.Entity = c.entity_name and ic.Code = c.code;

SELECT COUNT(*) FROM infectious_cases;

select * from countries limit 10;

select * from infectious_data limit 10;

-- 3 --

select
	country_id,
    avg(number_rabies) as avg_rabies,
    min(number_rabies) as min_rabies,
    max(number_rabies) as max_rabies,
    sum(number_rabies) as sum_rabies

from infectious_data
where number_rabies > 0
group by country_id
order by avg_rabies desc
limit 10;

-- 4 -- 

select 
	year,
    makedate(year, 1) as january_1,
    curdate() as today,
    timestampdiff(year, makedate(year, 1), curdate()) as years_passed
from infectious_data
limit 5; -- щоб не перегружати екран.

-- 5 --

drop function if exists years_attribute_diff;

DELIMITER //

create function years_attribute_diff(input_year int)
returns int
deterministic
no sql

BEGIN
	declare result int;
    set result = timestampdiff(year, makedate(input_year, 1), curdate());
    return result;

END //

DELIMITER ;


select
	year,
    makedate(year, 1) as january_1,
    curdate() as today,
    years_attribute_diff(year) as years_passed
from infectious_data
limit 10; -- додано для зручності

drop function if exists years_attribute_diff;