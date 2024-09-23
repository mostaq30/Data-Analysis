# SQL Painting Project

This project focuses on analyzing a dataset that includes information about paintings, artists, museums, and their associated attributes, utilizing SQL queries for data exploration and insights.

## Dataset Overview

The dataset includes the following tables:

Here’s a more concise version:

- **`artist`**: Stores artist details, including name, birth/death dates, nationality, and biographical information.
- **`canvas_size`**: Specifies canvas dimensions, including height, width, and unit measurements.
- **`image_link`**: Contains URLs or file paths to digital images of the paintings, with relevant metadata.
- **`museum`**: Includes information about museums, such as name, location, and notable collections or exhibitions.
- **`museum_hours`**: Lists museum opening/closing hours, including holiday or seasonal schedules.
- **`subject`**: Categorizes the themes or subjects of paintings (e.g., portraits, landscapes, abstract, etc.).
- **`work`**: Stores details about paintings, such as title, year, artist, canvas size, and medium.
- **`product_size`**: Provides dimensions for products associated with paintings (e.g., prints, framed versions).

## Exploring the dataset 

```sql
SELECT * FROM artist; -- 421
SELECT * FROM canvas_size; -- 200
SELECT * FROM image_link; -- 14775
SELECT * FROM museum; -- 57
SELECT * FROM museum_hours; -- 351
SELECT * FROM  subject; -- 6771
SELECT * FROM work; -- 14776
SELECT * FROM product_size; -- 110347
```


## SQL Queries and Outputs

Here are the SQL queries along with their outputs:

1. **Fetch all the paintings which are not displayed in any museums**

```sql
SELECT * FROM work
WHERE museum_id IS NULL;
```
-- Output --  
There are 10,223 paintings which are not displayed on any museums.

2. **Are there museuems without any paintings**

```sql
SELECT M.* 
FROM MUSEUM M
LEFT JOIN WORK W
ON M.MUSEUM_ID = W.MUSEUM_ID
WHERE W.MUSEUM_ID IS NULL;
```
-- Output --  
There is no museuems without any painting

3. **How many paintings have an asking price of more than their regular price?**
```sql
SELECT COUNT(WORK_ID)
FROM PRODUCT_SIZE
WHERE SALE_PRICE > REGULAR_PRICE;
```
-- Output --
There is no paintings have an asking price of more than their regular price.


4. **Identify the paintings whose asking price is less than 50% of its regular price**
```sql
SELECT work_id
FROM PRODUCT_SIZE
WHERE SALE_PRICE < REGULAR_PRICE / 2;
```
-- Output --
There are  5 paintings whose asking price is less than 50% of its regular price.

5. **Which canva size costs the most?**
```sql
SELECT C.LABEL, P.SALE_PRICE
FROM PRODUCT_SIZE P
LEFT JOIN CANVAS_SIZE C
ON P.SIZE_ID = C.SIZE_ID
ORDER BY SALE_PRICE DESC
LIMIT 1;
```
-- Output --
| Label                   | Sale Price |
|-------------------------|------------|
| 48" x 96" (122 cm x 244 cm) | 1115   |

6. **Delete duplicate records from work, product_size, subject and image_link tables**
```sql
-- DELETING FROM WORK TABLE
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

-- DELETING FROM PRODUCT_SIZE TABLE
DELETE FROM PRODUCT_SIZE
WHERE (WORK_ID, SIZE_ID) IN (
    SELECT WORK_ID, SIZE_ID
    FROM (
        SELECT 
            WORK_ID, 
            SIZE_ID,
            ROW_NUMBER() OVER (PARTITION BY WORK_ID, SIZE_ID ORDER BY WORK_ID) AS RowNum
        FROM 
            PRODUCT_SIZE
    ) AS Subquery
    WHERE RowNum > 1
);

-- DELETING FROM SUBJECT TABLE

DELETE FROM SUBJECT
WHERE (WORK_ID, SUBJECT) IN (
    SELECT WORK_ID, SUBJECT
    FROM (
        SELECT 
            WORK_ID, 
            SUBJECT,
            ROW_NUMBER() OVER (PARTITION BY WORK_ID, SUBJECT ORDER BY WORK_ID) AS RowNum
        FROM 
            SUBJECT
    ) AS Subquery
    WHERE RowNum > 1
);

-- DELETING FROM IMAGE_LINK TABLE

DELETE FROM IMAGE_LINK
WHERE (WORK_ID, URL, thumbnail_small_url, thumbnail_large_url) IN (
    SELECT WORK_ID, URL, thumbnail_small_url, thumbnail_large_url
    FROM (
        SELECT 
            WORK_ID, 
            URL, 
            thumbnail_small_url, 
            thumbnail_large_url,
            ROW_NUMBER() OVER (PARTITION BY WORK_ID, URL, thumbnail_small_url, thumbnail_large_url ORDER BY WORK_ID) AS RowNum
        FROM 
            IMAGE_LINK
    ) AS Subquery
    WHERE RowNum > 1
);

```
-- Output --
All duplicate recrod deleted from selected Table.

7. **Identify the museums with invalid city information in the given dataset**
```sql
SELECT * FROM museum
WHERE  city REGEXP '^[0-9]';
```
-- Output --
| Museum ID | Name                            | Address               | City          | State | Postal  | Country     | Phone            | Website                                                |
|-----------|---------------------------------|-----------------------|---------------|-------|---------|-------------|------------------|--------------------------------------------------------|
| 34        | The State Hermitage Museum      | Palace Square         | Sankt-Peterburg|       | 190000  | Russia      | 7 812 710-90-79 | [https://www.hermitagemuseum.org/wps/portal/hermitage/](https://www.hermitagemuseum.org/wps/portal/hermitage/) |
| 36        | Museum Folkwang                 | Museumsplatz 1        | Essen         |       | 45128   | Germany     | 49 201 8845000  | [https://www.museum-folkwang.de/en](https://www.museum-folkwang.de/en) |
| 37        | Museum of Grenoble              | 5 Pl. de Lavalette    | Grenoble      |       | 38000   | France      | 33 4 76 63 44 44| [https://www.museedegrenoble.fr/1986-the-museum-in-english.htm](https://www.museedegrenoble.fr/1986-the-museum-in-english.htm) |
| 38        | Musée des Beaux-Arts de Quimper| 40 Pl. Saint-Corentin | Quimper       |       | 29000   | France      | 33 2 98 95 45 20| [https://www.mbaq.fr/en/home-3.html](https://www.mbaq.fr/en/home-3.html) |
| 40        | Musée du Louvre                 | Rue de Rivoli         | Paris         |       | 75001   | France      | 33 1 40 20 50 50| [https://www.louvre.fr/en](https://www.louvre.fr/en) |
| 74        | Kröller-Müller Museum           | Houtkampweg 6         | Otterlo       |       | 6731 AW | Netherlands | +31 318 591 241 | [https://krollermuller.nl/en](https://krollermuller.nl/en) |

8. **Museum_Hours table has 1 invalid entry. Identify it and remove it**
```sql
MySQL doesn't have certain pseudo-columns like CTID because 
MySQL and PostgreSQL are different database management systems 
with different architectures and feature sets.
```
9. **Fetch the top 10 most famous painting subject**
```sql
SELECT s.subject, COUNT(*) AS no_of_paintings
FROM work w
JOIN subject s ON s.work_id = w.work_id
GROUP BY s.subject
ORDER BY COUNT(*) DESC
LIMIT 10;
```
-- Output --
| Subject                  | No. of Paintings |
|--------------------------|------------------|
| Portraits                | 1070             |
| Abstract/Modern Art      | 575              |
| Nude                     | 525              |
| Landscape Art            | 495              |
| Rivers/Lakes             | 480              |
| Flowers                  | 457              |
| Still-Life               | 395              |
| Seascapes                | 326              |
| Marine Art/Maritime      | 268              |
| Horses                   | 265              |

10. **Identify the museums which are open on both Sunday and Monday. Display museum name, city.**
```sql
SELECT M.name, m.city FROM MUSEUM M
LEFT JOIN MUSEUM_HOURS H
ON M.MUSEUM_ID = H.MUSEUM_ID
WHERE DAY IN ('Sunday', 'Monday');

```
-- Output --
| Name                                           | City          |
|------------------------------------------------|---------------|
| The Museum of Modern Art                      | New York      |
| Pushkin State Museum of Fine Arts             | Moscow        |
| National Gallery of Victoria                  | Melbourne     |
| São Paulo Museum of Art                       | São Paulo     |
| The State Hermitage Museum                    | 2             |
| The Metropolitan Museum of Art                | New York      |
| Museum Folkwang                               | 45128         |
| Museum of Grenoble                            | 38000         |
| Musée des Beaux-Arts de Quimper              | 29000         |
| Nelson-Atkins Museum of Art                   | Kansas City   |
| Musée du Louvre                               | 75001         |
| National Maritime Museum                      | London        |
| Museum of Fine Arts Boston                    | Boston        |
| Rijksmuseum                                   | Amsterdam     |
| Israel Museum                                 | Jerusalem     |
| Kunsthaus Zürich                              | Zurich        |
| National Gallery of Art                       | Washington    |
| National Gallery                              | London        |
| Mauritshuis Museum                            | Den Haag      |
| Musée d'Orsay                                 | Paris         |
| The Prado Museum                              | Madrid        |
| The Barnes Foundation                         | Philadelphia  |
| Hungarian National Gallery                    | Budapest      |
| Cleveland Museum Of Art                       | Cleveland     |
| Museum of Fine Arts, Houston                  | Houston       |
| The J. Paul Getty Museum                      | Los Angeles   |
| Thussen-Bornemisza Museum                     | Madrid        |
| Van Gogh Museum                               | Amsterdam     |
| The Phillips Collection                       | Washington    |
| Toledo Museum of Art                          | Toledo        |
| Los Angeles County Museum of Art              | Los Angeles   |
| Solomon R. Guggenheim Museum                  | New York      |
| The Tate Gallery                              | London        |
| Indianapolis Museum of Art                    | Indianapolis  |
| Museum of Fine Arts of Nancy                  | Nancy         |
| Fine Arts Museums of San Francisco Legion of Honor | San Francisco |
| Smithsonian American Art Museum               | Washington    |
| Philadelphia Museum of Art                    | Philadelphia  |
| The Art Institute of Chicago                  | Chicago       |
| Saint Louis Art Museum                        | St. Louis     |
| Uffizi Gallery Italy                          | Firenze       |
| Ohara Museum of Art                           | Kurashiki     |
| Musée Marmottan Monet                         | Paris         |
| Walters Art Museum                            | Baltimore     |
| Kröller-Müller Museum                         | 6731 AW Otterlo |
| National Museum                               | Cardiff       |
| Columbus Museum of Art                        | Columbus      |
| Kimbell Art Museum                            | Fort Worth    |
| Walker Art Gallery                            | Liverpool     |
| National Museum of Art Architecture and Design| Oslo          |
| Dallas Museum of Art                          | Dallas        |
| Museum of Fine Arts                           | Bern          |
| Army Museum                                   | Paris         |
| Chrysler Museum of Art                       | Norfolk       |
| National Gallery Prague                       | Nové Měst     |
| Norton Simon Museum                           | Pasadena      |
| Courtauld Gallery                             | Stran         |

11. **How many museums are open every single day**
```sql
SELECT 
    COUNT(*)
FROM
    (SELECT 
        museum_id, COUNT(*) AS no_of_museum_opening
    FROM
        museum_hours
    GROUP BY museum_id
    HAVING no_of_museum_opening = 7) x;
    
```
-- Output --
| COUNT(*) |
|----------|
|    18    |

12. **Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)**
```sql
SELECT m.museum_id, 
       m.name,  
       COUNT(work_id) AS work_shown 
FROM work w
JOIN museum m ON w.museum_id = m.museum_id

GROUP BY 1, 2 
ORDER BY work_shown DESC
LIMIT 5;    
```
-- Output --
| Museum ID | Name                              | Works Shown |
|-----------|-----------------------------------|-------------|
| 35        | The Metropolitan Museum of Art   | 939         |
| 43        | Rijksmuseum                       | 452         |
| 47        | National Gallery                  | 423         |
| 46        | National Gallery of Art           | 375         |
| 51        | The Barnes Foundation             | 350         |

13. **Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)**
```sql
SELECT 
a.artist_id,
full_name,
count(w.work_id) as NO_OF_WORK
FROM work w
JOIN artist a 
ON w.artist_id = a.artist_id
group by a.artist_id, full_name
order by NO_OF_WORK DESC
LIMIT 5;
 
```
-- Output --
| Artist ID | Full Name              | No. of Works |
|-----------|------------------------|--------------|
| 500       | Pierre-Auguste Renoir | 469          |
| 550       | Claude Monet           | 378          |
| 677       | Vincent Van Gogh       | 308          |
| 649       | Maurice Utrillo        | 253          |
| 559       | Albert Marquet         | 233          |

14. **Display the 3 least popular canva sizes**
```sql
SELECT
p.size_id, 
c.label,
count(w.work_id) as work_shown
FROM work w
JOIN product_size p
ON w.work_id = p.work_id
JOIN canvas_size c
ON c.size_id = p.size_id
group by 1,2
order by work_shown
limit 3;    
```
-- Output --
| Size ID | Label                          | Works Shown |
|---------|--------------------------------|-------------|
| 3730    | 37" x 30"(94 cm x 76 cm)      | 1           |
| 3218    | 32" x 18"(81 cm x 46 cm)      | 1           |
| 4635    | 46" x 35"(117 cm x 89 cm)     | 1           |



15. **Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?**
```sql
with CTE as (
SELECT 
    m.museum_id,
    m.name,
    MAX(HOUR(
    TIMEDIFF(
        STR_TO_DATE(close, '%h:%i:%p'), 
        STR_TO_DATE(open, '%h:%i:%p')
    ) ))AS hour_gap
FROM 
    museum_hours h join 
    museum m
    on m.museum_id = h.museum_id
    group by 1,2)
select * from CTE
order by hour_gap desc
limit 1
; --  'Musée du Louvre' open for 12 hour which is maximum 
```
-- Output --
| Museum ID | Name              | Hour Gap |
|-----------|-------------------|----------|
| 40        | Musée du Louvre  | 12       |

16. **Which museum has the most no of most popular painting style?**
```sql
SELECT 
       m.name, 
       w.style,
       COUNT(work_id) AS work_shown 
FROM work w
JOIN museum m ON w.museum_id = m.museum_id
GROUP BY m.museum_id,m.name, 
       w.style
ORDER BY work_shown DESC
LIMIT 1;
```
-- Output --
| Name                              | Style         | Works Shown |
|-----------------------------------|---------------|-------------|
| The Metropolitan Museum of Art   | Impressionism| 244         |

17. **Identify the artists whose paintings are displayed in multiple countries**
```sql
create table  temp (
 SELECT DISTINCT 
        a.full_name AS artist,
        m.country
    FROM 
        work w
    JOIN 
        artist a ON a.artist_id = w.artist_id
    JOIN 
        museum m ON m.museum_id = w.museum_id
);
select 
artist,
count(country) as country
from temp
group by artist
having country > 1
order by country desc;
```
-- Output --
| Artist            | Country | 
|-------------------|---------|
| Vincent Van Gogh  | 8       |
| Claude Monet      | 7       |
| Paul Gauguin      | 7       |
| Pierre-Auguste Renoir | 6   |
| Francois Boucher  | 6       |
| Rembrandt Van Rijn | 6     |
| Camille Pissarro  | 5       |
| Édouard Vuillard  | 5       |
| El Greco          | 5       |
| Peter Paul Rubens | 5       |
| Alfred Sisley     | 5       |
| André Derain      | 5       |
| Francisco De Goya | 5       |
| Frans Hals        | 5       |
| Edgar Degas       | 5       |
| Leonardo Da Vinci | 5       |
| ................. | ....... |


18. **Display the country and the city with most no of museums. Output 2 seperate columns to
    mention the city and country. If there are multiple value, seperate them with comma.**
```sql
WITH cte_country AS (
    SELECT 
        country,
        COUNT(*) AS country_count,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS country_rank
    FROM 
        museum
    GROUP BY 
        country
),
cte_city AS (
    SELECT 
        city,
        COUNT(1) AS city_count,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS city_rank
    FROM 
        museum
    GROUP BY 
        city
)
SELECT 
    (SELECT GROUP_CONCAT(DISTINCT country) FROM cte_country WHERE country_rank = 1) AS top_country,
    (SELECT GROUP_CONCAT(DISTINCT city) FROM cte_city WHERE city_rank = 1) AS top_city;
```
-- Output --
| top_country                              | top_city  |
|-----------------------------------|---------------|
| 'USA' |  'London,New York,Paris,Washington'|      

19. **Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum name, museum city and canvas label

```sql
WITH cte AS (
    SELECT 
        w.work_id,
        full_name,
        sale_price,
        w.name AS museum_name,
        m.name,
        m.city,
        c.label,
        MAX(sale_price) OVER () AS max_sale_price,
        MIN(sale_price) OVER () AS min_sale_price
    FROM 
        product_size p 
    JOIN 
        work w ON w.work_id = p.work_id
    JOIN 
        museum m ON m.museum_id = w.museum_id
    JOIN 
        artist a ON a.artist_id = w.artist_id
    JOIN 
        canvas_size c ON c.size_id = p.size_id
)
SELECT 
    *
FROM 
    cte
WHERE 
    sale_price IN (max_sale_price, min_sale_price)
limit 2;

```
-- Output --
| Work ID | Full Name               | Sale Price | Museum Name                    | Name                              | City       | Label                           | Max Sale Price | Min Sale Price |
|---------|-------------------------|------------|--------------------------------|-----------------------------------|------------|---------------------------------|----------------|----------------|
| 22890   | Peter Paul Rubens      | 1115       | Fortuna                        | The Prado Museum                 | Madrid     | 48" x 96"(122 cm x 244 cm)     | 1115           | 10             |
| 31780   | Adélaïde Labille-Guiard | 10        | Portrait of Madame Labille-Guyard and Her Pupils | The Metropolitan Museum of Art | New York   | 30" Long Edge                   | 1115           | 10             |



20. **Which country has the 5th highest no of paintings?**
```sql
create table  temp (
 SELECT DISTINCT 
        a.full_name AS artist,
        m.country
    FROM 
        work w
    JOIN 
        artist a ON a.artist_id = w.artist_id
    JOIN 
        museum m ON m.museum_id = w.museum_id
);
select 
artist,
count(country) as country
from temp
group by artist
having country > 1
order by country desc;
```
-- Output --
| Country | No. of Paintings |
|---------|------------------|
| Spain   | 196              |


21. **Which are the 3 most popular and 3 least popular painting styles?**
```sql
SELECT 
    style,
    CASE 
        WHEN rnk <= 3 THEN 'Most Popular'
        ELSE 'Least Popular' 
    END AS popularity
FROM (
    SELECT 
        style,
        RANK() OVER (ORDER BY cnt DESC) AS rnk
    FROM (
        SELECT 
            style,
            COUNT(*) AS cnt
        FROM 
            work
        WHERE 
            style IS NOT NULL
        GROUP BY 
            style
    ) AS subquery
) AS ranked_styles
WHERE 
    rnk <= 3
    OR rnk > (SELECT COUNT(DISTINCT style) FROM work WHERE style IS NOT NULL) - 3;
```
-- Output --
| Style              | Popularity     |
|--------------------|----------------|
| Impressionism     | Most Popular   |
| Post-Impressionism| Most Popular   |
| Realism            | Most Popular   |
| Avant-Garde        | Least Popular  |
| Art Nouveau        | Least Popular  |
| Japanese Art       | Least Popular  |

20. **Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.**
```sql
SELECT 
    full_name AS artist_name,
    nationality,
    no_of_paintings
FROM (
    SELECT 
        a.full_name,
        a.nationality,
        COUNT(*) AS no_of_paintings,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM 
        work w
    JOIN 
        artist a ON a.artist_id = w.artist_id
    JOIN 
        subject s ON s.work_id = w.work_id
    JOIN 
        museum m ON m.museum_id = w.museum_id
    WHERE 
        s.subject = 'Portraits'
        AND m.country != 'USA'
    GROUP BY 
        a.full_name, a.nationality
) x
WHERE 
    rnk = 1;
```
-- Output --
| Artist Name          | Nationality | No. of Paintings |
|----------------------|-------------|------------------|
| Jan Willem Pieneman | Dutch       | 14               |
| Vincent Van Gogh    | Dutch       | 14               |
