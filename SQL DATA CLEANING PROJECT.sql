-- DATA CLEANING--

SELECT *
FROM layoffs;


-- Create a new table NEVER work on the raw data--
CREATE TABLE layoffs_stagging
LIKE layoffs;

SELECT *
FROM layoffs_stagging;

INSERT layoffs_stagging
SELECT *
FROM layoffs;


-- REMOVING DUPLICATES---
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_stagging;

-- create a CTE---
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_stagging
)
SELECT *
FROM duplicate_cte
WHERE row_num> 1;

-- AFTER GETTING THE DUPLICATES ABOVE, ALAWAYS CONFIRM THEY ARE DUPLICATES BY--

SELECT *
FROM layoffs_stagging
WHERE company = 'casper';
-- So it shows they are not duplicates, that means we have to partition all the columns, hence its important to check--

-- so casper has a duplicate this is how to remove 1 dupliate--

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_stagging
)
DELETE
FROM duplicate_cte
WHERE row_num> 1;

-- WHEN THE ABOVE METHOD DOESN'T WORK IN REAL LIFE YOU NEED TO CREATE A TABLE--


CREATE TABLE `layoffs_stagging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_stagging2;


INSERT INTO layoffs_stagging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_stagging;

-- NOW LETS FILTER DUPLICATES--
SELECT *
FROM layoffs_stagging2
WHERE row_num > 1;

--  DELETE--
DELETE 
FROM layoffs_stagging2
WHERE row_num > 1;

SELECT *
FROM layoffs_stagging2;


-- STANDARDIZING DATA---

SELECT company, TRIM(company)
FROM layoffs_stagging2;

UPDATE layoffs_stagging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_stagging2
ORDER BY 1;
-- SOO THE TABLE SHOWS CRYPTO IS DUPLICATED THRICE SO WE HAVE GTO CLEAN THAT JUU ITS THE SAME THING--

SELECT *
FROM layoffs_stagging2
WHERE industry LIKE 'crypto%';
-- SO NOW LETS UPDATE ALL OF THEM TO BE CRYPTO---

UPDATE layoffs_stagging2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';

SELECT DISTINCT industry
FROM layoffs_stagging2;
-- so now its only crypto--

SELECT DISTINCT location
FROM layoffs_stagging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_stagging2
ORDER BY 1;
-- SO BASICALLY SELECT DISTINCT IS TO CHECK KAMA KUNA DUPLICATES IN THE DATA SO UNAHECK FOR EVERY TITLE ON THE TABLE. KAMA HAPA KWA COUNTRY USA IKO REPEATED---SO UPDATE IT--

SELECT DISTINCT country, TRIM( TRAILING '.' FROM country)
FROM layoffs_stagging2
ORDER BY 1;
-- tip is TRAILING removed the fullstop---

UPDATE layoffs_stagging2
SET country = TRIM( TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT *
FROM layoffs_stagging2;
-- NOW HERE WE ARE HANGING THE DATE FROM A TEXT ILIKUWA TYPED TO AN ACTUAL DATE FORMAT--- USE STR_TO_DATE---

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_stagging2;

UPDATE layoffs_stagging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_stagging2;

ALTER TABLE layoffs_stagging2
MODIFY COLUMN `date` DATE;
-- SO HAPA JUU WE HAVE CHANGED THE DATA FROM TEXT TO DATE--ONLY USE ALTER IN YOUR DUPLIVATE DATE NEVER IN THE ORIGINAL DATA SET--SO NOW HAPA CHINI LETS SEE HOW OUR TABLE LOOKS--

SELECT *
FROM layoffs_stagging2;

-- NULL & BLANKS--
SELECT *
FROM layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_stagging2;

-- NOW TO REMOVE NULLS FROM INDUSTRY WE NEED TO MATCH COMPANY AND INDUSTRY--
SELECT *
FROM layoffs_stagging2
WHERE industry IS NULL
OR industry = '';

UPDATE layoffs_stagging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_stagging2 t1
JOIN layoffs_stagging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- SO HAPA JUU BASICALLY TUMECREATE 2 TABLES IN ONE NDIO WE COMPARE THE INDUSTRY AND COMPANY-- TO BREAKDOWN FURTHER INSTEAD OF SELECTING ALL UNAKUWA SPECIFIC-- like so--

SELECT t1.industry, t2.industry
FROM layoffs_stagging2 t1
JOIN layoffs_stagging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- then sasa update--
UPDATE layoffs_stagging2 t1
JOIN layoffs_stagging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_stagging2
WHERE company = 'Airbnb';
-- IT WORKED--- 

SELECT *
FROM layoffs_stagging2;

-- REMOVING A WHOLE COLUMN--

ALTER TABLE layoffs_stagging2
DROP COLUMN row_num;














