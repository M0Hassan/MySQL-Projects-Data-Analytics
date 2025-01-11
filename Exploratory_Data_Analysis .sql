-- Exploratory Data Analysis
-- Here we are just going to explore the data and find trends or patterns or anything interesting like outliers

SELECT *
FROM layoffs_staging2;

-- Getting maximums
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Companies with the biggest single Layoff
SELECT company, total_laid_off
FROM layoffs_staging2
ORDER BY 2 DESC;


-- Companies with the most Total Layoffs
SELECT *
FROM layoffs_staging2
WHERE total_laid_off = 12000;

-- Retrieving companies that laidoff all their staff 100%
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

-- Retrieving the number of companies that laidoff all their staff 100%
SELECT COUNT(*)
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

-- Ordering based on total layoffs
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- by location
SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- Ordering based on funds raised
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- -- Ordering based on industry
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY industry;

-- Retrieving companies and their total layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Retrieving industries and their total layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Retrieving the duration of the data 
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Retrieving countries and their total layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT *
FROM layoffs_staging2;

-- Retrieving the total layoffs in each year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 1 DESC;

-- Retrieving the total layoffs based on the stage of the companies
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Retrieving the total layoffs each month
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1;

-- Retrieving the rolling total layoffs based on each month
WITH Roling_total_cte AS 
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) As total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS Rolling_total
FROM Roling_total_cte
;


-- Ranking the top 5 companies with the most layoffs each year
WITH Year_ranking (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
), Top_Year_ranking AS
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Year_ranking
WHERE years IS NOT NULL
)
SELECT *
FROM Top_Year_ranking
WHERE Ranking <= 5
;





