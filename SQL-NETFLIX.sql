--1 Count the Number of Movies vs TV Shows

SELECT 
    type,
    COUNT(*) AS total_content
FROM [dbo].[netflix]
GROUP BY type;

--2 Find the Most Common Rating for Movies and TV Shows

WITH RankedRatings AS (
    SELECT 
        type, 
        rating, 
        COUNT(*) AS count_rating,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM [dbo].[netflix]
    GROUP BY type, rating
)
SELECT 
    type, 
    rating
FROM RankedRatings
WHERE ranking = 1;

--3 List All Movies Released in a Specific Year (e.g., 2020)

SELECT 
    *  
FROM [dbo].[netflix]
WHERE 
    type = 'Movie'
    AND release_year = 2020;

--4 Find the Top 5 Countries with the Most Content on Netflix

SELECT TOP 5
    TRIM(value) AS country,
    COUNT(*) AS total_content
FROM netflix
CROSS APPLY STRING_SPLIT(country, ',')
WHERE country IS NOT NULL
GROUP BY TRIM(value)
ORDER BY total_content DESC;

--5 Identify the Longest Movie

SELECT 
    *
FROM netflix
WHERE 
    type = 'Movie'
    AND duration = (SELECT MAX(duration) FROM netflix WHERE type = 'Movie');

--6 Find Content Added in the Last 5 Years

SELECT 
    *
FROM netflix
WHERE CAST(date_added AS DATE) >= DATEADD(YEAR, -5, GETDATE());

--7 Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT 
    *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

--8 List All TV Shows with More Than 5 Seasons

SELECT 
    *
FROM netflix
WHERE 
    type = 'TV Show'
    AND CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5

--9 Count the Number of Content Items in Each Genre

SELECT 
    TRIM(value) AS genre,
    COUNT(*) AS total_content
FROM netflix
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY TRIM(value)
ORDER BY total_content DESC;

--10 Find each year and the average numbers of content release in India on netflix 
--return top 5 year with highest avg content release

SELECT TOP 5
    YEAR(CONVERT(DATE, date_added, 113)) AS year,
    COUNT(*) AS total_release,
    ROUND(
        CAST(COUNT(*) AS FLOAT) / 
        CAST((SELECT COUNT(*) FROM netflix WHERE country = 'India') AS FLOAT) * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY YEAR(CONVERT(DATE, date_added, 113))
ORDER BY avg_release DESC;

--11 List All Movies that are Documentaries

SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries%';

--12 Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL;
--13  Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT 
    title,
    release_year
FROM netflix
WHERE 
    cast LIKE '%Salman Khan%'
    AND release_year > YEAR(GETDATE()) - 10
    AND type = 'Movie';

--14 Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT TOP 10 
    TRIM(value) AS actors,
    COUNT(*) AS count_movies
FROM netflix
CROSS APPLY STRING_SPLIT(cast, ',')
WHERE country = 'India'
GROUP BY TRIM(value)
ORDER BY count_movies DESC;

--15 Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

WITH CategorizedContent AS (
    SELECT 
        *, 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad_Content'
            ELSE 'Good_Content'
        END AS category
    FROM netflix
)
SELECT 
    category,
    COUNT(*) AS total_content
FROM CategorizedContent
GROUP BY category;