Select *
From layoffs;

-- 1. Create a copy of Data
-- 2. Remove Duplicate
-- 3. Standardize the Data
-- 4. Null or Blank values
-- 5. Remove unneccessary Columns

-- 1. (This copies the columns from layoffs)
Create Table layoffs_staging
Like layoffs;

Select *
From layoffs_staging;

-- (Here copies every data from layoff into layoffs_staging)
Insert layoffs_staging
Select *
From layoffs;

-- 2. Remove duuplicates

Select *,
Row_Number() Over(
Partition By company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
From layoffs_staging;

With numbered_rows as(
Select *,
Row_Number() Over(
Partition By company, location, industry, total_laid_off, percentage_laid_off, `date`, stage,
country, funds_raised_millions) as row_num
From layoffs_staging)
Select *
From duplicate_cte
Where row_num > 1;

-- (Here is to look at a companies redundancies)
Select *
From layoffs_staging
Where company = "Casper";

-- (Creating another table to perform delete. Can't work in CTEs)
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
  `row_num` Int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Select *
From layoffs_staging2;

Insert Into layoffs_staging2
Select *,
Row_Number() Over(
Partition By company, location, industry, total_laid_off, percentage_laid_off, `date`, stage,
country, funds_raised_millions) as row_num
From layoffs_staging;

-- (To view what I want to delete)
Select *
From layoffs_staging2
Where row_num > 1;

Delete
From layoffs_staging2
Where row_num > 1;


-- 3. Standardize the data.

-- Remove trailing spaces
Select company, Trim(company)
From layoffs_staging2;

Update layoffs_staging2
Set company = Trim(company);

Select distinct industry
From layoffs_staging2
;

-- Standardize the Crypto industry name
Update layoffs_staging2
Set industry = "Crypto"
Where industry Like "Crypto%";

-- Remove trailing dots
Select Distinct country, Trim(Trailing "." from country)
From layoffs_staging2
Order By 1;

Update layoffs_staging2
Set country = Trim(Trailing "." from country)
Where country Like "United States%";

-- Changing date format
Select `date`,
Str_To_Date(`date`, "%m/%d/%Y")
From layoffs_staging2;

Update layoffs_staging2
Set `date` = Str_To_Date(`date`, "%m/%d/%Y");

Select `date`
From layoffs_staging2;

Alter Table layoffs_staging2
Modify column `date` Date;

-- 4. (Here I remove unnecessary rows and columns)
Select *
From layoffs_staging2
Where total_laid_off is Null
And percentage_laid_off is Null;

-- I investigated the Null and blank rows in industry column
Select *
From layoffs_staging2
Where industry Is Null
Or industry = "";

Select *
From layoffs_staging2
Where company = "Airbnb";

-- I viewed the Null rows to see if it can be populated
Select t1.industry, t2.industry
From layoffs_staging2 t1
Join layoffs_staging2 t2
	On t1.company = t2.company
Where t1.industry Is Null
And t2.industry Is Not Null;

-- I set the blanks to Null
Update layoffs_staging2
Set industry = Null
Where industry = "";

-- I populated the Null rows with the Not Nulls that have common company and industry
Update layoffs_staging2 t1
Join layoffs_staging2 t2
	On t1.company = t2.company
Set t1.industry = t2.industry
Where t1.industry Is Null
And t2.industry Is Not Null;

Select *
From layoffs_staging2;

Select *
From layoffs_staging2
Where total_laid_off is Null
And percentage_laid_off is Null;

-- (Let's delete the rows with Null total and % laid of)
Delete
From layoffs_staging2
Where total_laid_off is Null
And percentage_laid_off is Null;

Select *
From layoffs_staging2;

Alter Table layoffs_staging2
Drop Column row_num;