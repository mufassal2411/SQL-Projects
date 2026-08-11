# Netflix Movies and TV Shows Data Analysis using SQL

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

```sql
--create a new database as 'sql_project_2'
CREATE DATABASE sql_project_2

--the staging table is made to solve the problem of impoting a huge file as netflix(file also contains n no. of null values)
CREATE TABLE dbo.netflix_stage (
    show_id NVARCHAR(50),
    type NVARCHAR(50),
    title NVARCHAR(500),
    director NVARCHAR(500),
    [cast] NVARCHAR(MAX),
    country NVARCHAR(200),
    date_added NVARCHAR(50),
    release_year NVARCHAR(20),   
    rating NVARCHAR(20),
    duration NVARCHAR(50),
    listed_in NVARCHAR(300),
    description NVARCHAR(MAX)
);

--dbo.netflix was created while importing flate file(SSMS 21)

BULK INSERT dbo.netflix_stage
FROM 'C:\data\netflix_titles.csv'
WITH (
    FORMAT = 'CSV',--this shows the sql server that the file is a pure csv file and respect all its conditions
    FIRSTROW = 2,
    CODEPAGE = '65001',   -- UTF-8 is used becoz the csv file contains diff accents
    TABLOCK
);

--inserting the data from netflix_stage table to netflix table
INSERT INTO dbo.netflix
(
    show_id, type, title, director, [cast], country,
    date_added, release_year, rating, duration, listed_in, description
)
SELECT
    show_id,
    type,
    title,
    director,
    [cast],
    country,
    date_added,
    TRY_CAST(release_year AS INT),
    rating,
    duration,
    listed_in,
    description
FROM dbo.netflix_stage;

SELECT COUNT(*) AS total_rows FROM dbo.netflix;

SELECT * FROM netflix

SELECT DISTINCT type from netflix;

--counting the number of movies vs TV shows

SELECT 
    type,
    COUNT(*) as movies_and_shows
FROM netflix
GROUP BY type

--fing the most common rating for movies and tv shows
SELECT
   type,
   rating
FROM

(
  SELECT
      type,
      rating,
      COUNT(*) as count_mt,
      RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS Ranking
 FROM netflix
 GROUP BY type,rating
) AS t1
WHERE Ranking  = 1

--List all movies released in a specific year (eg: 2022)
SELECT *
   --type,
   --release_year
from netflix
WHERE type = 'Movie' AND release_year = '2020'

SELECT * FROM netflix

--top 5 countries with the most content on netflix
SELECT TOP 5
    s.value AS new_country,
    COUNT(show_id) AS content
FROM netflix n
CROSS APPLY STRING_SPLIT(country,',') s
GROUP BY s.value
ORDER BY content DESC

--finding the longest movie
SELECT *
FROM netflix
WHERE
   type = 'movie' AND
   CAST(REPLACE(duration,'min','') AS INT) = 
   ( 
     select
           MAX(CAST(REPLACE(duration,'min','') AS INT))
           FROM netflix
           WHERE type = 'movie'
);
 
--FINDING CONTENT ADDED IN THE LAST 5 YEARS
SELECT *
FROM netflix
WHERE
   YEAR(TRY_CAST(date_added AS DATE)) >=
   ( 
     SELECT 
          MAX(YEAR(TRY_CAST(date_added AS DATE))) -5
          FROM netflix
)
ORDER BY YEAR(TRY_CAST(date_added AS DATE)) DESC;

--selecting all movies and tv shows where director is 
SELECT * from netflix
WHERE director IN ('Aamir Khan','Rajiv Chilaka')

SELECT *
FROM netflix
WHERE director LIKE '%Aamir Khan%'
   OR director LIKE '%Rajiv Chilaka%';--'LIKE' also gives directors of directors-in-partnership

--list all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE 
     type = 'TV show' 
     AND
     CAST(REPLACE(REPLACE(duration,' Seasons', ''),' Season', '') AS INT) > 5;

--count the number of content items in each genre 

SELECT 
    s.value as new_genre,
    COUNT(show_id) AS total_content
FROM netflix n
CROSS APPLY string_split(n.listed_in,',') s
GROUP BY s.value
ORDER BY total_content DESC

--avg top 5 content per year by each country 
WITH country_split AS(
SELECT
   TRIM(value) AS country,
   YEAR(TRY_CAST(date_added AS DATE)) as released_year
FROM netflix
CROSS APPLY STRING_SPLIT(country,',')
WHERE date_added IS NOT NULL
)
,country_year_count AS(
SELECT
    country,
    released_year,
    COUNT(*) AS total_count
FROM country_split
GROUP BY country,released_year
)
SELECT TOP 5
    country,
    AVG(total_count * 1.0) AS Avg_Content_Per_Year
FROM country_year_count
GROUP BY country
ORDER BY Avg_Content_Per_Year DESC;

/*find each year and the avg number of content released by india on netflix,return top 5 year with
highest avg content released*/
WITH india_content AS(
   SELECT
      YEAR(TRY_CAST(date_added AS DATE)) AS released_year,
      COUNT(*) AS total_content
FROM netflix
CROSS APPLY string_split(country,',')
WHERE TRIM(value) = 'india'
GROUP BY YEAR(TRY_CAST(date_added AS DATE))
)
SELECT TOP 5
   released_year,
   AVG(total_content * 1.0) as avg_content 
FROM india_content
GROUP BY released_year
ORDER BY  AVG(total_content * 1.0) DESC;

--list all movies that are documentaries
SELECT *
FROM netflix n
CROSS APPLY string_split(listed_in,',') as genre
WHERE n.type = 'movie' AND
TRIM(genre.value) = 'Documentaries'

--find all content without director
SELECT *
FROM netflix
WHERE director IS NULL

--find how many movies actor 'salman khan' appeared in last 10 years
SELECT 
    --n.title,
    YEAR(TRY_CAST(date_added AS DATE)) AS released_date,
    COUNT(*) as no_of_movies
FROM netflix n
CROSS APPLY STRING_SPLIT(n.cast,',') c
WHERE TRIM(c.value) = 'salman khan'
AND n.type = 'movie'
AND YEAR(TRY_CAST(date_added AS DATE)) >= (
    select 
      MAX(YEAR(TRY_CAST(date_added AS DATE))) -9   --or can use getdate() to compare from present date
      FROM netflix
)
GROUP BY YEAR(TRY_CAST(date_added AS DATE))

--FIND THE TOP 10 ACTORS WHO HAVE APPEARED IN THE HIGHEST NUMBER OF MOVIES PRODUCED BY INDIA
SELECT TOP 10
   TRIM(c.value) AS Actors,
   COUNT(*) AS total_count
FROM netflix n
CROSS APPLY string_split(CAST,',') c
CROSS APPLY string_split(country,',') cn
WHERE n.type = 'movie' AND
TRIM(cn.value) = 'india'
GROUP BY TRIM(c.value)
ORDER BY total_count DESC;

/*categorize the content based on the presence of the ketwords 'killl' and 'voilence' in the description filed,
Label caontent containing thse keywords as 'Bad' and all other content as 'Good'.Count how many fall 
into each categoty*/
SELECT 
   CASE
     WHEN description LIKE '%Kill%' 
     OR  description LIKE '%violence%' 
     THEN 'Bad'
     ELSE 'Good'
   END AS BG_CONTENT,
   COUNT(*) AS Total_Count   
FROM netflix
GROUP BY
     CASE
       WHEN description LIKE '%Kill%' 
       OR  description LIKE '%violence%' 
       THEN 'Bad'
       ELSE 'Good'
 END;
   
SELECT COUNT(*) AS kill_content
FROM netflix
WHERE description LIKE '%kill%';--checking for kill

SELECT COUNT(*) AS violence_content
FROM netflix
WHERE description LIKE '%violence%';--checking for violence
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Mufassal Areeb

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

Thank you for your support, and I look forward to connecting with you!



