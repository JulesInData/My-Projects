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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Tech Layoffs — Exploratory Data Analysis

Once the dataset was cleaned, I wanted to actually understand what happened. The tech industry went through a brutal wave of layoffs between 2020 and 2023 — this project digs into who was hit hardest, which industries suffered most, and how the numbers moved over time.

## The data

Source: [Kaggle — World Layoffs Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022)

The cleaned version from the companion [data cleaning project](https://github.com/JulesInData/layoffs-sql-data-cleaning). Around 2,300 layoff events from tech companies worldwide.

## What I looked at

I started simple — just exploring the range of the data, finding the max layoffs in a single event, and listing companies that shut down entirely (100% laid off).

From there I moved into company and industry rankings. Which companies cut the most jobs in absolute terms? Which industries bled the most people overall? I used basic aggregation with `group by` and `order by` for most of this.

The more interesting analysis came from breaking things down by year. I ranked companies by total layoffs per year using `dense_rank()` — which handles ties better than `rank()` — and wrapped it in a CTE so I could filter down to just the top 5 per year cleanly.

The last piece was a rolling monthly total. I first built a CTE that summed layoffs by month, then ran a `sum() over(order by month)` window function on top of that to get a cumulative picture of how the damage accumulated. Watching that number climb through 2022 and into 2023 tells a very different story than looking at monthly snapshots alone.

## Tools

PostgreSQL · Git

## Files

- `SQL EXPLORATORY DATA ANALYSIS PROJECT.sql` — the full script with comments throughout
