--1. Standardize Date Format
--- Check if 'SaleDateConverted' exists; if so, update it
IF COL_LENGTH('PortfolioProjects.dbo.NashvilleHousing', 'SaleDateConverted') IS NOT NULL
BEGIN
    -- Update the existing column
    UPDATE PortfolioProjects.dbo.NashvilleHousing
    SET SaleDateConverted = CONVERT(DATE, SaleDate);
END
ELSE
BEGIN
    -- Add 'SaleDateConverted' column and update it
    ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
    ADD SaleDateConverted DATE;

    UPDATE PortfolioProjects.dbo.NashvilleHousing
    SET SaleDateConverted = CONVERT(DATE, SaleDate);
END;


--2. Populate Missing Property Address Data
-- Update missing PropertyAddress using values from records with the same ParcelID
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;


--3. Split Address into Individual Components
-- Check if the 'PropertySplitAddress' column exists; if not, add it
IF COL_LENGTH('PortfolioProjects.dbo.NashvilleHousing', 'PropertySplitAddress') IS NULL
BEGIN
    ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
    ADD PropertySplitAddress NVARCHAR(255);
END;

-- Check if the 'PropertySplitCity' column exists; if not, add it
IF COL_LENGTH('PortfolioProjects.dbo.NashvilleHousing', 'PropertySplitCity') IS NULL
BEGIN
    ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
    ADD PropertySplitCity NVARCHAR(255);
END;

-- Update new columns with split data
UPDATE PortfolioProjects.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
WHERE PropertyAddress IS NOT NULL AND CHARINDEX(',', PropertyAddress) > 0;

-- Confirm the existence of the columns
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NashvilleHousing'
  AND COLUMN_NAME IN ('PropertySplitAddress', 'PropertySplitCity');

-- Review the table structure to ensure columns are present
EXEC sp_columns @table_name = 'NashvilleHousing';

--4. Standardize 'Sold As Vacant' Field
-- Check the data type of the SoldAsVacant column
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NashvilleHousing'
  AND COLUMN_NAME = 'SoldAsVacant';

-- Alter the column to use nvarchar(max)
ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
ALTER COLUMN SoldAsVacant NVARCHAR(MAX);

-- Update the SoldAsVacant column values
UPDATE PortfolioProjects.dbo.NashvilleHousing
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

--5. Remove Duplicate Records
-- Identify duplicates using ROW_NUMBER
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY [UniqueID]) AS row_num
    FROM PortfolioProjects.dbo.NashvilleHousing
)
-- Delete duplicates
DELETE FROM RowNumCTE WHERE row_num > 1;

--6. Delete Unused Columns
-- Remove unnecessary columns to streamline the dataset
ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

--7. Identify and Handle Outliers in Sale Prices
-- Check the data type of the SalePrice column
-- Calculate basic statistics for SalePrice
SELECT 
    AVG(SalePrice) AS AvgPrice, 
    STDEV(SalePrice) AS StdDevPrice,
    MIN(SalePrice) AS MinPrice,
    MAX(SalePrice) AS MaxPrice
FROM PortfolioProjects.dbo.NashvilleHousing;

-- Identify potential outliers
SELECT * 
FROM PortfolioProjects.dbo.NashvilleHousing
WHERE SalePrice > (AVG(SalePrice) + 3 * STDEV(SalePrice)) OR SalePrice < (AVG(SalePrice) - 3 * STDEV(SalePrice));


--8. Normalize Numerical Data
-- Add normalized SalePrice column
ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
ADD NormalizedSalePrice FLOAT;

-- Update normalized SalePrice using min-max scaling
UPDATE PortfolioProjects.dbo.NashvilleHousing
SET NormalizedSalePrice = (SalePrice - (SELECT MIN(SalePrice) FROM PortfolioProjects.dbo.NashvilleHousing)) / 
                          ((SELECT MAX(SalePrice) FROM PortfolioProjects.dbo.NashvilleHousing) - (SELECT MIN(SalePrice) FROM PortfolioProjects.dbo.NashvilleHousing));

--9. Advanced Data Aggregation for Business Insights
-- Calculate average sale price by neighborhood
SELECT Neighborhood, AVG(SalePrice) AS AvgSalePrice
FROM PortfolioProjects.dbo.NashvilleHousing
GROUP BY Neighborhood
ORDER BY AvgSalePrice DESC;

-- Determine the most common property types sold
SELECT PropertyType, COUNT(*) AS CountSold
FROM PortfolioProjects.dbo.NashvilleHousing
GROUP BY PropertyType
ORDER BY CountSold DESC;

--10. Data Validation and Integrity Checks
-- Check for invalid data entries in important fields
SELECT * 
FROM PortfolioProjects.dbo.NashvilleHousing
WHERE SalePrice <= 0 
   OR PropertySplitAddress IS NULL 
   OR SaleDateConverted IS NULL;

-- Ensure unique constraints where necessary
ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
ADD CONSTRAINT UniqueSale UNIQUE(ParcelID, SaleDateConverted, SalePrice);
