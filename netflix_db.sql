-- My Neflix Project
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(150),
	description VARCHAR(250)


);

SELECT * FROM netflix;

SELECT COUNT(*) as total_content FROM netflix;

-- Business Problems
-- 1. Count the Number of Movies vs TV Shows
SELECT type,
	 	COUNT(*) as total_content
FROM netflix
GROUP BY type;

-- 2. Find the Most Common Rating for Movies and TV Shows
SELECT
	type,
	rating
FROM
(
	SELECT 
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1, 2
)as t1
WHERE
	ranking = 1;
	
-- 3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT * FROM netflix
WHERE type = 'Movie' AND release_year = 2020;

-- 4. Find the Top 5 Countries with the Most Content on Netflix
SELECT
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- 5. Identify the Longest Movie
SELECT type, title, duration FROM netflix
WHERE
	type = 'Movie'
	AND duration = (SELECT MAX (duration) FROM netflix);
	
-- 6. Find Content Added in the Last 5 Years
SELECT * FROM netflix
WHERE
	TO_DATE(date_added, 'Month, DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find All Movies/TV Shows by Director 'Gerard Barrett'
SELECT type, title, director FROM netflix 
WHERE director LIKE '%Gerard Barrett%';

-- 8. List All TV Shows with More Than 5 Seasons
SELECT type, title, duration FROM netflix
WHERE type = 'TV Show'
AND SPLIT_PART(duration, ' ', 1)::numeric > 5; 

-- 9. Count the Number of Content Items in Each Genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1;

-- 10. Find each year and the average numbers of content release in United States on netflix.
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY'))as year,
	COUNT(*) as yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'United States')::numeric * 100, 2) as avg_content_per_year
FROM netflix
WHERE country LIKE 'United States'
GROUP BY 1
ORDER BY 3 DESC;

-- 11. Find How Many Movies Actor 'Liam Neeson' Appeared in the Last 10 Years
SELECT * FROM netflix
WHERE 
	casts ILIKE '%Liam Neeson%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
	
-- 12. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in United States
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country ILIKE '%United States%'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 13. Categorize Content Based on the Presence of 'Love' and 'Romance' Keywords in description field.
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%love%' OR description ILIKE '%romance%' THEN 'ROMCOM'
            ELSE 'Other'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
