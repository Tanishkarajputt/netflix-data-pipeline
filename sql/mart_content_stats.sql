-- =============================================================
-- MART LAYER: Analytics-ready tables
-- Run after staging_netflix.sql has been executed
-- =============================================================

USE DATABASE netflix_db;

CREATE SCHEMA IF NOT EXISTS mart;
USE SCHEMA mart;


-- -------------------------------------------------------------
-- 1. Content split: Movies vs TV Shows
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE type_split AS
SELECT
    content_type,
    COUNT(*) AS total_titles,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM netflix_db.staging.stg_netflix
GROUP BY content_type
ORDER BY total_titles DESC;


-- -------------------------------------------------------------
-- 2. Titles added per year (growth trend)
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE yearly_additions AS
SELECT
    YEAR(date_added) AS year_added,
    content_type,
    COUNT(*) AS titles_added
FROM netflix_db.staging.stg_netflix
WHERE date_added IS NOT NULL
GROUP BY year_added, content_type
ORDER BY year_added DESC, titles_added DESC;


-- -------------------------------------------------------------
-- 3. Top countries by content volume
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE content_by_country AS
SELECT
    country,
    COUNT(*) AS total_titles,
    COUNT_IF(content_type = 'MOVIE') AS movies,
    COUNT_IF(content_type = 'TV SHOW') AS tv_shows
FROM netflix_db.staging.stg_netflix
WHERE country != 'Unknown'
GROUP BY country
ORDER BY total_titles DESC
LIMIT 20;


-- -------------------------------------------------------------
-- 4. Rating distribution
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE rating_distribution AS
SELECT
    rating,
    COUNT(*) AS total_titles,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM netflix_db.staging.stg_netflix
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY total_titles DESC;


-- -------------------------------------------------------------
-- 5. Average movie duration by genre (top 10 genres)
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE movie_duration_by_genre AS
WITH genre_split AS (
    SELECT
        TRIM(g.value) AS genre,
        duration_minutes
    FROM netflix_db.staging.stg_netflix,
    LATERAL FLATTEN(INPUT => SPLIT(genres, ',')) g
    WHERE content_type = 'MOVIE'
      AND duration_minutes IS NOT NULL
)
SELECT
    genre,
    ROUND(AVG(duration_minutes), 1) AS avg_duration_minutes,
    COUNT(*) AS movie_count
FROM genre_split
GROUP BY genre
HAVING movie_count >= 10
ORDER BY avg_duration_minutes DESC
LIMIT 10;


-- =============================================================
-- Validation queries — uncomment and run to check row counts
-- =============================================================
-- SELECT 'type_split'             AS table_name, COUNT(*) AS rows FROM mart.type_split
-- UNION ALL
-- SELECT 'yearly_additions',                      COUNT(*) FROM mart.yearly_additions
-- UNION ALL
-- SELECT 'content_by_country',                    COUNT(*) FROM mart.content_by_country
-- UNION ALL
-- SELECT 'rating_distribution',                   COUNT(*) FROM mart.rating_distribution
-- UNION ALL
-- SELECT 'movie_duration_by_genre',               COUNT(*) FROM mart.movie_duration_by_genre;
