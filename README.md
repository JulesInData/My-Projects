# My-Projects
# Tech Layoffs — SQL Data Cleaning

Raw layoffs data from 2020–2023 is messy — duplicates, inconsistent formatting, blank fields, and dates stored as plain text. This project takes the dataset from uncleaned to analysis-ready using SQL only.

## Dataset
- **Source:** [Kaggle — World Layoffs Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
- **Records:** ~2,300 layoff events across global tech companies (2020–2023)
- **Fields:** company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions

## What I Did

**1. Created a staging table**
Never touched the raw data. All cleaning was done on a duplicate staging table — a practice I carried over from real-world data collection experience.

**2. Removed duplicates**
Used `ROW_NUMBER() OVER(PARTITION BY ...)` across all columns to identify true duplicates. Created a second staging table to safely delete them since CTEs don't support DELETE in all environments.

**3. Standardised values**
- Trimmed whitespace from company names using `TRIM()`
- Consolidated variations like `"Crypto"`, `"Crypto Currency"` → `"Crypto"` using `LIKE` and `UPDATE`
- Removed trailing punctuation from country names (`"United States."` → `"United States"`) using `TRIM(TRAILING '.' FROM ...)`

**4. Fixed date format**
Dates were stored as text. Converted to proper `DATE` type using `STR_TO_DATE()`, then altered the column type with `ALTER TABLE ... MODIFY COLUMN`.

**5. Handled NULLs and blanks**
- Converted empty strings to `NULL` for consistency
- Used a self-JOIN to fill NULL industry values by matching on company name — if another row for the same company had an industry, it was used to fill the gap
- Deleted rows where both `total_laid_off` AND `percentage_laid_off` were NULL (no useful data)

**6. Cleaned up**
Dropped the helper `row_num` column once deduplication was complete.

## SQL Techniques Used
- `ROW_NUMBER()` window function with `PARTITION BY`
- CTEs for multi-step logic
- `TRIM()`, `TRAILING`, `LIKE` for string cleaning
- `STR_TO_DATE()` and `ALTER TABLE ... MODIFY COLUMN` for type conversion
- Self-JOIN to fill NULL values from matching rows
- `UPDATE`, `DELETE`, `ALTER TABLE`

## Files
- `data_cleaning.sql` — full commented cleaning script

## Tools
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=flat&logo=postgresql&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=flat&logo=git&logoColor=white)
