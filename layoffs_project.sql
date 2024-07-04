-- Data Cleaning

SELECT * 
FROM general.layoffs;

-- First we are creatin a copy of the raw data (never work on the original database, always create a copy)
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- Steps
-- 1. Removing Duplicates
-- 2. Standarize Data
-- 3. Null Values or Blank Values
-- 4 Remove Any Columns

-- 1. Removing Duplicates

-- ADDING A ROW NUMBER, IF THIS ROW NUMBER IS EQUAL TO 2, IT IS A DUPLICATE
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;
-- CREATING A CTE 
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * FROM duplicate_cte
WHERE row_num > 1;
-- MAKING SURE THEY ARE ACTUALLY DUPLICATES
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';
-- CREATING A NEW TABLE WHERE WE WILL DELETE THE DUPLICATES, AT THE END THEE WAS A NEW ROW CALLED ROW_NUM THIS WILL AGAIN HELP US SEE THE DUPLICATES
CREATE TABLE `layoffs_staging2` (
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
-- ADDING THE DATA TO THE NEW TABLE
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;
-- SEEING THE DUPLICATES ON THE NEW UPDATED TABLE
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;
-- DELETING THE DUPLICATES
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

-- 2. Standarize Data
SELECT company, TRIM(company)
FROM layoffs_staging2;
-- DELETING THE BLANK SPACES IN COMPANY
UPDATE layoffs_staging2
SET company = TRIM(company);
-- ANALYZING THE DIFFERENT INDUSTRIES THAT EXIST
SELECT distinct(industry)
FROM layoffs_staging2
ORDER BY 1;
-- IT WAS OBSERVED THAT DIFFERENT CRYPTO INDUSTRIES EXISTED, SO WE ARE CHECKING IT OUT
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';
-- MAKING ALL THE CRYPTO INDUSTRIES INTO ONE NAME, IT IS LIKE A SEARCH AND REPLACE FUNCTION 
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
-- ANALYZING EVERY COLUMN
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;
-- HERE IN COUNTRY WE HAVE AN ISSUE 
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;
-- THE ISSUE IS A UNITED STATES WITH A POINT AT THE END 
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;
-- GETTING RID OF THE POINT AT THE END 
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
-- IN THIS TABLE THE DATE IS STATED AS TEXT, WE WILL CHANGE IT INTO A DATE 
SELECT `date`, 
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;
-- STANDARIZING THE DATE FORMAT
UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');
-- 
SELECT `date` 
FROM layoffs_staging2;
-- MODIFYING THE DATA TYPE (AGAIN, NEVER DO THIS ON THE RAW DATA TABLE)
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. Null Values or Blank Values
-- HAVING ROWS WITHOUT THOSE TWO IS NOT USABLE 
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- UPDATING EVERY BLANK SPACE AND MAKING IT A NULL, IT HELPS DELETE
	UPDATE layoffs_staging2
    SET industry = NULL 
    WHERE industry = '';
-- MAKING SURE
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';
-- WE FOUND SEVERAL ROWS WITH AIRBNB ON THE INDUSTRY BEING NULL, WE WILL COMPARE IT AND UPDATE IT 
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';
-- COMPARING AGAIN WITH A JOIN 
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location=t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;
-- UPDATING THE TABLE 
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;
-- DELETING THE ROWS THAT WILL NOT WORK 
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;



-- 4 Remove Any Columns
-- REMOVING A COLUMN NOW THAT THE CLEANING IS DONE AND IS OF NO USE ANY MORE
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
-- FINALLY WE HAVE THE CLEANED TABLE 
SELECT *
FROM layoffs_staging2