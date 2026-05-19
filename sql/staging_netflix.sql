-- =============================================================
-- STAGING LAYER: stg_netflix
-- Cleans and standardises the raw Netflix table
-- Run this after 01_ingest.ipynb has loaded data into RAW
-- =============================================================

USE DATABASE netflix_db;

CREATE SCHEMA IF NOT EXISTS staging;
USE SCHEMA staging;

CREATE OR REPLACE VIEW stg_netflix AS
SELECT
    show_id,

    -- Normalise type values
    TRIM(UPPER(type)) AS content_type,

    TRIM(title) AS title,

    -- Null-safe director
    CASE WHEN TRIM(director) = '' OR director IS NULL THEN 'Unknown' ELSE TRIM(director) END AS director,

    -- Null-safe country
    CASE WHEN TRIM(country) = '' OR country IS NULL THEN 'Unknown' ELSE TRIM(country) END AS country,

    -- Parse date_added to a proper DATE
    TRY_TO_DATE(TRIM(date_added), 'MMMM DD, YYYY') AS date_added,

    release_year::INTEGER AS release_year,

    TRIM(rating) AS rating,

    -- Split duration into two typed columns
    CASE
        WHEN type = 'Movie' THEN TRY_TO_NUMBER(SPLIT_PART(duration, ' ', 1))
        ELSE NULL
    END AS duration_minutes,

    CASE
        WHEN type = 'TV Show' THEN TRY_TO_NUMBER(SPLIT_PART(duration, ' ', 1))
        ELSE NULL
    END AS duration_seasons,

    listed_in AS genres,

    TRIM(description) AS description

FROM netflix_db.raw.NETFLIX_RAW

-- Remove duplicates — keep first occurrence of each show_id
QUALIFY ROW_NUMBER() OVER (PARTITION BY show_id ORDER BY show_id) = 1;


-- Quick sanity check — run this after creating the view
-- SELECT content_type, COUNT(*) FROM stg_netflix GROUP BY 1;
