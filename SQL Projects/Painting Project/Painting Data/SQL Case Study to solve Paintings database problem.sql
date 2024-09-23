
-- Exploring the Table Structures First
Use paintings;

SELECT Count(*) FROM ARTIST; -- 421

SELECT Count(*) FROM CANVAS_SIZE; -- 200

SELECT Count(*) FROM image_link; -- 14,775

SELECT Count(*) FROM MUSEUM; -- 57

SELECT Count(*) FROM MUSEUM_HOURS; -- 351

SELECT Count(*) FROM SUBJECT; -- 6,771

SELECT Count(*) FROM WORK; -- 14,776

SELECT count(*) FROM PRODUCT_SIZE; -- 110,347




-- Q1. Fetch all the paintings which are not displayed on any museums?
Select Count(*) from paintings.work 
where museum_id is null;


-- Q2. Are there museums without any paintings?    
SELECT 
    DISTINCT museum_id
FROM
    museum m
WHERE
    NOT EXISTS( SELECT 
            DISTINCT museum_id
        FROM
            work w
        WHERE
            w.museum_id = m.museum_id);

    
-- Q3. How many paintings have an asking price of more than their regular price?
select Count(*) from product_size
where sale_price > regular_price; 



-- Q4. Identify the paintings whose asking price is less than 50% of its regular price
SELECT 
    w.work_id,
    w.name AS Painting_name,
    sale_price,
    regular_price
FROM
    product_size ps
        JOIN
    work w ON w.work_id = ps.work_id
WHERE
    sale_price < (regular_price * 0.5); 


-- Q5. Which canva size costs the most?
	select cs.label as canva, ps.sale_price
	from (select *
		  , rank() over (order by sale_price desc) as rnk 
		  from product_size) ps
	join canvas_size cs on cs.size_id=ps.size_id
	where ps.rnk=1;
    
with RANKTABLE as
(select 
	*, 
	rank() over (order by sale_price desc) as rnk 
from product_size)

SELECT CS.LABEL AS CONVAS_LABEL, RT.SALE_PRICE
FROM CANVAS_SIZE CS 
JOIN RANKTABLE RT ON RT.SIZE_ID = CS.SIZE_ID
WHERE RT.RNK = 1;


-- 6) Delete duplicate records from work, product_size, subject and image_link tables
                        
SELECT COUNT(*) FROM WORK; --   14776        
              
DELETE FROM WORK
WHERE WORK_ID IN (
    SELECT WORK_ID
    FROM (
        SELECT 
            WORK_ID, 
            ROW_NUMBER() OVER (PARTITION BY WORK_ID) AS RowNum
        FROM 
            WORK
    ) AS Subquery
    WHERE RowNum > 1
);

SELECT COUNT(*) FROM WORK; --   14657    


-- Q7. Identify the museums with invalid city information in the given dataset 
SELECT *
FROM museum
WHERE city REGEXP '^[0-9]';


-- Q8. Museum_Hours table has 1 invalid entry. Identify it and remove it.

DELETE FROM museum_hours
WHERE museum_id NOT IN (
    SELECT MIN(museum_id)
    FROM museum_hours
    GROUP BY museum_id, day
);


-- Q9. Fetch the top 10 most famous painting subject
SELECT *
FROM (
    SELECT 
		s.subject,
        count(1) as no_of_paintings,
        row_number() over (order by count(1) desc) as ranking
        FROM work w
    JOIN subject s 
    ON s.work_id = w.work_id
	GROUP BY s.subject
) x
WHERE ranking <= 10;


-- Q10. Identify the museums which are open on both Sunday and Monday. Display museum name, city.
select
		m.name as 'museum name',
        m.city as city
from museum m 
join museum_hours mh 
on m.museum_id = mh.museum_id
where mh.day = 'Sunday'
	and exists (
		select 1
        from museum_hours mh2 
        where mh2.museum_id = mh.museum_id 
        and mh2.day ='Monday'
    );


-- Q11. How many museums are open every single day?

SELECT COUNT(*) AS total_museums_open_every_day
FROM (
    SELECT museum_id
    FROM museum_hours
    GROUP BY museum_id
    HAVING COUNT(day) = 7
) AS museums_open_every_day;


-- Q12. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)

SELECT m.museum_id,m.name AS museum, m.city, m.country, x.no_of_paintings
FROM (
    SELECT 
		m.museum_id, 
        COUNT(1) AS no_of_paintings,
		RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM work w
    JOIN museum m 
    ON m.museum_id = w.museum_id
    GROUP BY m.museum_id
) x
JOIN museum m ON m.museum_id = x.museum_id
WHERE x.rnk <= 5;


-- Q13. Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)

select a.full_name as Name , a.nationality , x.no_of_paintings 
from (
	select 
		a.artist_id ,
        count(1) as no_of_paintings ,
        row_number () over( order by count(1) desc) as rnk
    from work w 
    join artist a 
    on a.artist_id = w.artist_id 
    group by a.artist_id 
) x
join artist a 
on a.artist_id = x.artist_id 
where x.rnk <= 5;


-- Q14. Display the 3 least popular canva sizes
select label,ranking,no_of_paintings
from
	(select cs.size_id , cs.label ,
	count(1) as no_of_paintings,
	row_number() over (order by count(1) asc) as ranking
from work w 
join product_size ps on ps.work_id=w.work_id
join canvas_size cs on cs.size_id = ps.size_id
group by cs.size_id,cs.label) x
where x.ranking <= 3;



-- 15. Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?

SELECT *
FROM (
    SELECT m.name AS museum_name, m.state, day, open, close,
		str_to_date(close, '%h:%i:%p') as Close_time ,
        STR_TO_DATE(open, '%h:%i:%p') as open_time,
		timediff(STR_TO_DATE(close, '%h:%i:%p'),STR_TO_DATE(open, '%h:%i:%p')) AS duration,
		 row_number() OVER (ORDER BY TIMEDIFF(STR_TO_DATE(close, '%h:%i:%p'), STR_TO_DATE(open, '%h:%i:%p')) DESC) AS rnk
    FROM museum_hours mh
    JOIN museum m ON m.museum_id = mh.museum_id
) x
WHERE x.rnk = 1;

-- Q16. Which museum has the most no of most popular painting style?

select m.museum_id, m.name, w.style,
	   count(w.work_id) as Most_popular_style 
from museum m
join work w on m.museum_id = w.museum_id
group by m.museum_id,m.name, w.style
order by Most_popular_style desc
limit 1;


-- Q17. Identify the artists whose paintings are displayed in multiple countries

with cte as 
	(select distinct a.full_name as Artist,
	   m.country
	from artist a
	join work w on a.artist_id = w.artist_id
	join museum m on m.museum_id = w.museum_id)
select Artist, count(country) as no_of_countries 
from cte
group by Artist 
having	count(country) >1
order by 2 desc;

-- Q18. Display the country and the city with most no of museums. Output 2 seperate
-- columns to mention the city and country. If there are multiple value, seperate them
-- with comma.

with cte_country as 
		(select country, count(1),
		rank() over(order by count(1) desc) as rnk
		from museum
		group by country),
	cte_city as 
		(select city, count(1),
        rank() over(order by count(1) desc) as rnk
		from museum
		group by city)
        
select group_concat(distinct country separator ',') as country , group_concat(city separator ',') as city
from cte_country
cross join cte_city
where cte_country.rnk = 1
and cte_city.rnk = 1;

-- Q19  Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum name, museum city and canvas label
WITH cte AS (
    SELECT 
        w.work_id,
        full_name as 'Artist Name',
        sale_price,
        w.name AS Painting_name,
        m.name as museum_name,
        m.city as museum_city ,
        c.label as canvas_label
    FROM product_size p 
    JOIN work w ON w.work_id = p.work_id
    JOIN museum m ON m.museum_id = w.museum_id
    JOIN artist a ON a.artist_id = w.artist_id
    JOIN canvas_size c ON c.size_id = p.size_id
)
SELECT *
FROM cte
WHERE sale_price = (select MAX(sale_price) from cte)
union all 
select *
from cte
where sale_price = (select MIN(sale_price) from cte)
limit 2;



-- Q20. Which country has the 5th highest no of paintings?
 with cte as 
	(select 
		m.Country , 
		count(w.work_id) as no_of_painting,
        rank() over (order by count(w.work_id) desc) as rnk 
		from museum m 
		join work w on w.museum_id = m.museum_id 
		group by m.country) 
select country, no_of_painting
from cte
where rnk = 5;



-- Q21.Which are the 3 most popular and 3 least popular painting styles?

WITH style_counts AS (
    SELECT 
        style,
        COUNT(*) AS num_paintings,
        rank() OVER (ORDER BY COUNT(*) DESC) AS popular_rank,
        rank() OVER (ORDER BY COUNT(*) ASC) AS unpopular_rank
    FROM work
    where style is not null
    GROUP BY style
)
SELECT 
    style,
    num_paintings,
    case 
		when popular_rank <= 3 then 'Most Popular'
        when Unpopular_rank <= 3 then 'Least Popular'
        else null 
        End as Popularity_category
FROM style_counts
WHERE popular_rank <= 3 OR unpopular_rank <= 3
order by num_paintings desc;


-- Q22. Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality
select full_name as Artist_name, Nationality , no_of_painting
from
	(select a.full_name, a.nationality,
	count(w.work_id) as no_of_painting,
    rank() over (order by count(w.work_id) desc ) as rnk 
	from artist a 
	join work w on w.artist_id = a.artist_id 
	join museum m on m.museum_id = w.museum_id 
	join subject s on s.work_id = w.work_id
	where s.subject = 'Portraits'
	and m.Country !='USA'
	group by a.Full_name, a.nationality) x 
    
    where rnk = 1;






















