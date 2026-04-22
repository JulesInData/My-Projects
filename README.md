# Practice_Projects
## Tech Layoffs — Data Cleaning

The raw layoffs dataset from Kaggle is pretty messy — there are duplicates, inconsistent company and country names, blank industry fields, and dates stored as plain text instead of actual date values. Before any analysis is useful, all of that needs to be fixed.

This project works through the full cleaning process in SQL.

## The data

Source: [Kaggle — World Layoffs Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022)

Around 2,300 layoff events from tech companies worldwide between 2020 and 2023. Each row covers a company, its location and industry, how many people were laid off, what percentage of the workforce that was, the date, funding stage, and how much the company had raised.

## What the cleaning involved

The first thing I did was create a staging table — a copy of the raw data to work on. You never want to run destructive operations directly on the original.

Removing duplicates was the trickiest part. I used `row_number()` with `partition by` across every column to flag rows that appeared more than once. Because you can't run `delete` directly on a CTE in all environments, I created a second staging table with the row number baked in, then deleted anything where that number was greater than 1.

Standardising the values involved a few things. Company names had leading and trailing whitespace that `trim()` cleaned up. The industry column had the same category written three different ways — Crypto, Crypto Currency, and CryptoCurrency — so I used `update` with `like 'Crypto%'` to consolidate them. The country column had entries like "United States." with a stray full stop, which `trim(trailing '.' from country)` sorted out.

The date column looked fine but was actually stored as text, which means any sorting or comparisons would break. I used `str_to_date()` to parse the values properly, then `alter table ... modify column` to change the type to `date`.

For nulls, I first converted any blank strings to null so the data was consistent. Then I used a self-join to fill in missing industry values — if a company appeared in multiple rows and one of them had the industry filled in, that value was used to patch the blank ones. Any rows where both `total_laid_off` and `percentage_laid_off` were null got deleted since they had nothing useful to offer.

Once everything was clean, I dropped the helper `row_num` column.

## Tools

PostgreSQL · Git

## Files

- `SQL DATA CLEANING PROJECT.sql` — the full script with comments throughout
