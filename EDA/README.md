# Layoffs Dataset - Exploratory Data Analysis (EDA)

## Overview

This project involves Exploratory Data Analysis (EDA) on a dataset about layoffs in 2022, sourced from Kaggle ([Layoffs 2022](https://www.kaggle.com/datasets/swaptr/layoffs-2022)). The objective is to uncover insights, trends, and outliers without predefined hypotheses, focusing on the scale, timing, and distribution of layoffs.

## Data Source
- **Dataset:** Layoffs 2022 from Kaggle
- **Table Name:** `world_layoffs.layoffs_staging2`

## EDA Steps

### 1. **Basic Statistics**
   - **Maximum Layoffs in a Single Event:**
     ```sql
     SELECT MAX(total_laid_off) FROM world_layoffs.layoffs_staging2;
     ```
     - Determines the largest number of layoffs in any single event.

   - **Analysis of Layoff Percentages:**
     ```sql
     SELECT MAX(percentage_laid_off), MIN(percentage_laid_off) FROM world_layoffs.layoffs_staging2 WHERE percentage_laid_off IS NOT NULL;
     ```
     - Identifies the range (highest to lowest) of layoff percentages, excluding null entries.

### 2. **Outliers and Significant Events**
   - **Companies with 100% Layoffs:**
     ```sql
     SELECT * FROM world_layoffs.layoffs_staging2 WHERE percentage_laid_off = 1 ORDER BY funds_raised_millions DESC;
     ```
     - Lists companies where 100% of employees were laid off, sorted by the amount of funds raised to highlight the scale of these companies.

### 3. **Group By Analysis**
   - **Companies with the Largest Single Layoff Events:**
     ```sql
     SELECT company, total_laid_off FROM world_layoffs.layoffs_staging ORDER BY total_laid_off DESC LIMIT 5;
     ```
     - Identifies the top 5 companies by the number of layoffs in one event.

   - **Total Layoffs by Various Dimensions:**
     - **Company:** `SELECT company, SUM(total_laid_off) FROM world_layoffs.layoffs_staging2 GROUP BY company ORDER BY 2 DESC LIMIT 10;`
     - **Location:** `SELECT location, SUM(total_laid_off) FROM world_layoffs.layoffs_staging2 GROUP BY location ORDER BY 2 DESC LIMIT 10;`
     - **Country:** `SELECT country, SUM(total_laid_off) FROM world_layoffs.layoffs_staging2 GROUP BY country ORDER BY 2 DESC;`
     - **Industry:** `SELECT industry, SUM(total_laid_off) FROM world_layoffs.layoffs_staging2 GROUP BY industry ORDER BY 2 DESC;`
     - **Stage:** `SELECT stage, SUM(total_laid_off) FROM world_layoffs.layoffs_staging2 GROUP BY stage ORDER BY 2 DESC;`

### 4. **Complex Queries**
   - **Layoffs by Company Per Year, Ranking Top 3:**
     ```sql
     WITH Company_Year AS (
       SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off FROM layoffs_staging2 GROUP BY company, YEAR(date)
     ),
     Company_Year_Rank AS (
       SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking FROM Company_Year
     )
     SELECT company, years, total_laid_off, ranking FROM Company_Year_Rank WHERE ranking <= 3 AND years IS NOT NULL ORDER BY years ASC, total_laid_off DESC;
     ```
     - Ranks companies by layoffs for each year, showing only the top 3.

   - **Rolling Total of Layoffs Over Time:**
     ```sql
     WITH DATE_CTE AS (
       SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off FROM layoffs_staging2 GROUP BY dates ORDER BY dates ASC
     )
     SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs FROM DATE_CTE ORDER BY dates ASC;
     ```
     - Calculates a cumulative sum of layoffs month by month, useful for identifying temporal trends in layoffs.

## Conclusion

This EDA has revealed insights into the dynamics of layoffs across various dimensions like companies, regions, industries, and time. Key findings include:
- Identification of companies with significant layoffs or complete closures.
- Trends in layoffs by sector, location, and company development stage.
- Temporal analysis showing how layoffs evolve over time, potentially correlating with economic cycles.

Further exploration could involve integrating external economic data or looking into specific sectors for more detailed analysis.
