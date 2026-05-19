# Netflix Data Pipeline 🎬

An end-to-end data engineering pipeline that ingests the Netflix titles catalog from Kaggle, lands it in Amazon S3, loads it into Snowflake, and transforms it through staging and mart layers for analytics.

---

## Architecture

```
Kaggle API
    │
    ▼
Amazon S3 (Raw landing zone)
    │
    ▼
Snowflake — RAW schema (netflix_db.raw.NETFLIX_RAW)
    │
    ▼
Snowflake — STAGING schema (cleaned, typed, standardised)
    │
    ▼
Snowflake — MART schema (analytics-ready aggregates)
```

---

## Tech Stack

| Layer | Tool |
|---|---|
| Data source | Kaggle API (`shivamb/netflix-shows`) |
| Raw storage | Amazon S3 |
| Data warehouse | Snowflake |
| Ingestion | Python, pandas, snowflake-connector-python |
| Transformation | SQL (staging views + mart tables) |
| Format | Parquet (intermediate) |

---

## Project Structure

```
netflix-data-pipeline/
│
├── README.md
├── requirements.txt
├── .env.example
├── .gitignore
│
├── notebooks/
│   ├── 01_ingest.ipynb        # Download from Kaggle, upload to S3, load to Snowflake RAW
│   └── 02_transform.ipynb     # Run staging and mart SQL transformations
│
└── sql/
    ├── staging_netflix.sql    # Cleans and standardises the raw table
    └── mart_content_stats.sql # Analytics-ready aggregates for reporting
```

---

## Setup

### 1. Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/netflix-data-pipeline.git
cd netflix-data-pipeline
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure environment variables

Copy `.env.example` to `.env` and fill in your credentials:

```bash
cp .env.example .env
```

Then edit `.env`:

```
SNOWFLAKE_USER=your_username
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_ACCOUNT=your_account_identifier
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
S3_BUCKET_NAME=your-bucket-name
```

### 4. Run the notebooks in order

- `notebooks/01_ingest.ipynb` — downloads the dataset, uploads to S3, creates Snowflake warehouse/database/schema, and loads raw data
- `notebooks/02_transform.ipynb` — runs the staging and mart SQL to build clean, analytics-ready tables

---

## Data Model

### RAW layer — `netflix_db.raw.NETFLIX_RAW`
Direct copy of the Kaggle CSV. No transformations. 8,807 rows, 12 columns including `show_id`, `type`, `title`, `director`, `cast`, `country`, `date_added`, `release_year`, `rating`, `duration`, `listed_in`, `description`.

### STAGING layer — `netflix_db.staging.stg_netflix`
- Null handling for `director`, `cast`, `country`
- `date_added` parsed to a proper `DATE` column
- `duration_minutes` and `duration_seasons` split from the combined `duration` field
- Duplicate rows removed

### MART layer — `netflix_db.mart.*`
| Table | Description |
|---|---|
| `content_by_country` | Count of titles per country |
| `rating_distribution` | Breakdown of content ratings (PG, TV-MA, etc.) |
| `yearly_additions` | Number of titles added per year |
| `type_split` | Movies vs TV Shows ratio |

---

## What I Learned

- How to use `kagglehub` to programmatically download datasets
- Uploading files to S3 using `boto3` and structuring a raw landing zone
- Connecting Python to Snowflake using `snowflake-connector-python` and bulk loading with `write_pandas`
- Designing a multi-layer data warehouse pattern (RAW → STAGING → MART) to separate concerns between ingestion and transformation
- Converting CSV to Parquet for more efficient columnar storage
- Managing credentials securely using environment variables instead of hardcoding

---

## Dataset

[Netflix Movies and TV Shows](https://www.kaggle.com/datasets/shivamb/netflix-shows) by Shivam Bansal on Kaggle.

---

## Author

**Your Name** — [LinkedIn](https://linkedin.com/in/yourprofile) · [GitHub](https://github.com/yourusername)
