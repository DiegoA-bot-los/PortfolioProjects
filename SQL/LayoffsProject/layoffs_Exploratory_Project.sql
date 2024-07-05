-- Exploratory Data Analysis
-- EXPLORING A LITTLE BIT
SELECT *
FROM layoffs_staging2;
-- LOOKING AT MAX´S
SELECT MAX(total_laid_off), MAX(percentage_laid_off) 
FROM layoffs_staging2;
-- SEEING WHICH COMPANYS LAID OFF ITS ENTIRE WORKFORCE (BANKRUPT)
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;
-- SEEING WHICH COMPANY LAID MOST WORKERS IN TOTAL 
SELECT company, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
-- SEEING THE DATE RANGE 
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
-- SEEING WHICH INDUSTRY LAID MOST OFF
SELECT industry, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
-- SEEING WHICH COUNTRY WAS THE MOST AFFECTED 
SELECT country, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
-- SEEING THE TOTAL LAID OFFS BY EACH YEAR OF THE DATASET
SELECT YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
-- STAGES IS HOW BIG IS THE COMPANY SO WE ARE SEEING AT THE MAGNITUDE OF THE COMPANYS AND WHICH LAID MOST OFF
SELECT stage, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;
-- SEEING THE LAID OFFS BY MONTH
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- MAKING A ROLLING TOTAL WITH THE DATES
WITH Rolling_Total as
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT  `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- MAKING A ROLLING TOTAL WITH THE COMPANY
SELECT company, YEAR(`date`) ,SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`) ,SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), 
Company_Year_Rank AS 
(
SELECT *,
 dense_rank() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE Ranking <= 5
;

