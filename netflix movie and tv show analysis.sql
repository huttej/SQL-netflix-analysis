select * from netflix_titles
--handling foreign character 
--remove duplicates
select show_id , COUNT(*)
FROM netflix_titles
group by show_id
having count(*)>1

SELECT COUNT(*) AS NullCount
FROM netflix_titles
WHERE show_id IS NULL;


ALTER TABLE netflix_titles
ALTER COLUMN show_id NVARCHAR(50) NOT NULL;

ALTER TABLE netflix_titles
ADD CONSTRAINT PK_netflix_titles_show_id
PRIMARY KEY (show_id);

select title , COUNT(*)
FROM netflix_titles
group by title
having count(*)>1

select * from netflix_titles
where  concat(upper(title),type) in (
select concat(upper(title), type)
FROM netflix_titles
group by upper(title), type
having count(*)>1
)
order by title,type

with cte as (
select *
,ROW_NUMBER() OVER(PARTITION by title , type order by show_id) as rn 
from netflix_titles
)
select * from cte where rn=1

--new tables for listed in , director, country, cast
select show_id , trim(value) as cast
into neflix_cast
from netflix_titles
cross apply string_split(cast,',')

select show_id , trim(value) as listed_in
into neflix_listed_in
from netflix_titles
cross apply string_split(listed_in,',')


select show_id , trim(value) as genre
into neflix_genre
from netflix_titles
cross apply string_split(genre,',')


WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY title, type
               ORDER BY show_id
           ) AS rn
    FROM netflix_titles
)
SELECT
    show_id,
    type,
    title,
    CAST(date_added AS date) AS date_added,
    release_year,
    rating,
    duration,
    description
FROM cte
WHERE rn = 1;

--populate missing values in country , duration columnn
insert into neflix_country 
select show_id , m.country
FROM netflix_titles nr 
inner join (
select director , country 
from neflix_country nc 
inner join neflix_director nd on nc.show_id=nd.show_id
group by director , country
) m on nr.director=m.director
where nr.country is null

select * from netflix_titles where show_id='s1001' 

select director , country 
from neflix_country nc 
inner join neflix_director nd on nc.show_id=nd.show_id
group by director , country


----------------------------------------------
select * from netflix_titles where duration is null

WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY title, type
               ORDER BY show_id
           ) AS rn
    FROM netflix_titles
)
SELECT
    show_id,
    type,
    title,
    CAST(date_added AS date) AS date_added,
    release_year,
    rating,
    case when duration is null then rating else duration end  as duration,
    description
FROM cte
WHERE rn = 1 and date_added is null

WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY title, type
               ORDER BY show_id
           ) AS rn
    FROM netflix_titles
)
SELECT
    show_id,
    type,
    title,
    CAST(date_added AS date) AS date_added,
    release_year,
    rating,
    case when duration is null then rating else duration end  as duration,
    description
    into netflix_stg
FROM cte

select * from netflix_stg
---metflix data analysis 
--1 for each director count the no if movies nd tv shows created by them in a sepearte column 
--for director who have created both tv shows nd movies both 
select nd.director
, COUNT(distinct case when n. type='Movie' then n. show_id end) as no_of_movies
, COUNT(distinct case when n. type='TV Show' then n.show_id end) as no_of_tvshow
from netflix_stg n
inner join neflix_director nd on n.show_id=nd.show_id
group by nd.director
having COUNT(distinct n.type)>1




 --2 which country has hightest number of comedy movies

 SELECT TOP 1
    nc.country,
    COUNT(DISTINCT ng.show_id) AS no_of_movies
FROM neflix_listed_in ng
INNER JOIN neflix_country nc
    ON ng.show_id = nc.show_id
INNER JOIN netflix_stg n
    ON ng.show_id = n.show_id
WHERE ng.listed_in = 'Comedies'
  AND n.type = 'Movie'
GROUP BY nc.country
ORDER BY no_of_movies DESC;

--3 for each yr as per date which director has max number of relaeases

WITH cte AS (
    SELECT
        nd.director,
        YEAR(n.date_added) AS date_year,
        COUNT(n.show_id) AS no_of_movies
    FROM netflix_stg n
    INNER JOIN neflix_director nd
        ON n.show_id = nd.show_id
    GROUP BY
        nd.director,
        YEAR(n.date_added)
)
, cte2 as (

SELECT
    *,
    ROW_NUMBER() OVER (
        PARTITION BY date_year
        ORDER BY no_of_movies DESC
    ) AS rn
FROM cte
--ORDER BY date_year,no_of_movies DESC;
) 
select * from cte2 where rn=1

--4 avg duration of movie in each genre
SELECT
    ng.listed_in,
    AVG(CAST(REPLACE(n.duration, ' min', '') AS INT)) AS avg_duration
FROM netflix_stg n
INNER JOIN neflix_listed_in ng
    ON n.show_id = ng.show_id
WHERE n.type = 'Movie'
GROUP BY ng.listed_in;

-- 5 find the list of directors who have created horror and comedy movies both.
-- display director names along with number of comedy and horror movies directed by them
select nd.director
, count(distinct case when ng.listed_in='Comedies' then n.show_id end) as no_of_comedy
, count(distinct case when ng.listed_in='Horror Movies' then n.show_id end) as no_of_horror
from netflix_stg n
inner join neflix_listed_in ng on n.show_id=ng.show_id
inner join neflix_director nd on n.show_id=nd.show_id
where type='Movie' and ng.listed_in in ('Comedies', 'Horror Movies')
group by nd.director
having COUNT(distinct ng.listed_in)=2;


select * from neflix_listed_in where show_id in
(select show_id from neflix_director where director='Steve Brill')
order by listed_in









