SELECT *
FROM layoffs;

-- PROCESS OF DATA CLEANING
-- 1. Remove Duplicates
-- 2. Standardize the data - handle issues such as spelling errors
-- 3. Handle Null and blank values
-- 4. Remove any columns or rows that aren't necessary

-- 1. Removing Duplicates - If there is a unique identifier column then we can use that to find duplicates
						 -- If NOT improvise by assigning ROW_NUMBER() to the data to identify duplicates
                         -- If uuuusing a CTE it is not possible to update and delete from CTE tables
						 -- Hence, copy the CTE data into another table for deletion purposes


CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION  BY company, location, industry, total_laid_off, 
						percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte 
WHERE row_num > 1; 
;


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

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION  BY company, location, industry, total_laid_off, 
						percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


SELECT *
FROM layoffs_staging2;

-- 2. Standardizing the data
   -- IF any of the data has any trailing white spaces especially text data - we can trim
   -- If any of he data has same or close identifires standardize by giving them one name  e.g Crypto, Crypto cuurrency, cryptocurrency
   -- COrrect any spelling errors in data
   -- IF there are any columns with data that has the wrong DATA TYE then change the data first to the correct TYPE then alter the column
         -- to the right DATAA TYPE for example from text to DATE
   

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);  


SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. Handle Null or Blank values
	-- Check the data is similar rows have values that we can populate into the null or blank ones
    -- If any rows lack the data that we want or that are necessary then we can delete them after careful consideration


SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

SELECT *
FROm layoffs_staging2
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 As t2
	ON t1.company = t2.company
    AND t1.country = t1.country
WHERE (t1.industry IS NULL OR t1.industry = '')
	AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 As t2
	ON t1.company = t2.company
    AND t1.country = t1.country
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
	AND t2.industry IS NOT NULL;
    
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;


-- 4. Remove any columns and Rows that are not necessary

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;


ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
















