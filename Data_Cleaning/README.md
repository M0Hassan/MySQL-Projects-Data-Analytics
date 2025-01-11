# SQL Project - Data Cleaning

**Project Overview:**

This project focuses on cleaning a dataset related to layoffs in 2022, sourced from Kaggle (link: [Layoffs 2022](https://www.kaggle.com/datasets/swaptr/layoffs-2022)). The primary goal is to prepare the data for analysis by addressing common data quality issues such as duplicates, null values, and inconsistencies in data entries.

## Project Steps:

### 1. **Setup Staging Table**
   - **Action:** Created a staging table `layoffs_staging` to work on without altering the original data.
   - **SQL:** 
     ```sql
     CREATE TABLE world_layoffs.layoffs_staging LIKE world_layoffs.layoffs;
     INSERT INTO layoffs_staging SELECT * FROM world_layoffs.layoffs;
     ```

### 2. **Remove Duplicates**
   - **Action:** Identified and removed duplicate entries to ensure data integrity.
   - **Method:** Used `ROW_NUMBER()` for partitioning data and identifying duplicates based on key columns.
   - **SQL:** 
     ```sql
     WITH DELETE_CTE AS (
         SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
         ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
         FROM world_layoffs.layoffs_staging
     )
     DELETE FROM world_layoffs.layoffs_staging
     WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
         SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
         FROM DELETE_CTE
     ) AND row_num > 1;
     ```

### 3. **Standardize Data**
   - **Action:** Standardized entries for `industry`, `country`, and `date` to ensure uniformity.
   - **Industry Standardization:** Converted variations like 'Crypto Currency' and 'CryptoCurrency' to 'Crypto'.
   - **Country Standardization:** Removed trailing periods from country names.
   - **Date Standardization:** Converted string dates to SQL date format.
   - **SQL:** 
     ```sql
     UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry IN ('Crypto Currency', 'CryptoCurrency');
     UPDATE layoffs_staging2 SET country = TRIM(TRAILING '.' FROM country);
     UPDATE layoffs_staging2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
     ALTER TABLE layoffs_staging2 MODIFY COLUMN `date` DATE;
     ```

### 4. **Handle Null Values**
   - **Action:** Reviewed null values in key columns like `total_laid_off`, `percentage_laid_off`, and `funds_raised_millions`. Decided to keep them as null where no data was available to maintain data accuracy.

### 5. **Remove Unnecessary Data**
   - **Action:** Removed rows where both `total_laid_off` and `percentage_laid_off` were null, as these entries were deemed not useful for analysis.
   - **SQL:** 
     ```sql
     DELETE FROM world_layoffs.layoffs_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
     ```

### 6. **Final Cleanup**
   - **Action:** Dropped the temporary `row_num` column used for duplicate handling.
   - **SQL:** 
     ```sql
     ALTER TABLE layoffs_staging2 DROP COLUMN row_num;
     ```

## Conclusion

The cleaned data is now stored in `layoffs_staging2`, ready for further analysis or EDA (Exploratory Data Analysis). This dataset should now have fewer inconsistencies, no duplicates, and standardized entries, making it more reliable for extracting insights on layoffs in 2022.

**Note:** Remember to back up your data before making significant changes, and consider using version control for your SQL scripts to track changes over time.
