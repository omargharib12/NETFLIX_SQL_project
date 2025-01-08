# # Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*) AS total_content
FROM [dbo].[netflix]
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT 
    *  
FROM [dbo].[netflix]
WHERE 
    type = 'Movie'
    AND release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT TOP 5
    TRIM(value) AS country,
    COUNT(*) AS total_content
FROM netflix
CROSS APPLY STRING_SPLIT(country, ',')
WHERE country IS NOT NULL
GROUP BY TRIM(value)
ORDER BY total_content DESC;

```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT 
    *
FROM netflix
WHERE 
    type = 'Movie'
    AND duration = (SELECT MAX(duration) FROM netflix WHERE type = 'Movie');
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT 
    *
FROM netflix
WHERE CAST(date_added AS DATE) >= DATEADD(YEAR, -5, GETDATE());
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT 
    *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT 
    *
FROM netflix
WHERE 
    type = 'TV Show'
    AND CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
    TRIM(value) AS genre,
    COUNT(*) AS total_content
FROM netflix
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY TRIM(value)
ORDER BY total_content DESC;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries%';

```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT 
    title,
    release_year
FROM netflix
WHERE 
    cast LIKE '%Salman Khan%'
    AND release_year > YEAR(GETDATE()) - 10
    AND type = 'Movie';
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT TOP 10 
    TRIM(value) AS actors,
    COUNT(*) AS count_movies
FROM netflix
CROSS APPLY STRING_SPLIT(cast, ',')
WHERE country = 'India'
GROUP BY TRIM(value)
ORDER BY count_movies DESC;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.




