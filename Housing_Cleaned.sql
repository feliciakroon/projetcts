-- Data source: https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx
-- Before loading the data into MySQL, the SaleDate column was standardised and the empty cells were populated with "NULL" using Pandas in Python

-- Populating property address data based on parcelID

SELECT *
FROM nashville_housing
WHERE PropertyAddress IS NULL;
 
SELECT a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress,
COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Breaking out PropertyAddress into individual columns (Address, City)

SELECT PropertyAddress
FROM nashville_housing;

SELECT
	SUBSTRING_INDEX(PropertyAddress, ",",1) AS Address, -- Extracting everything before ","
	SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS City
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD PropertySplitAddress VARCHAR(255);

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ",",1);

ALTER TABLE nashville_housing
ADD PropertySplitCity VARCHAR(255);

UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);


-- Breaking out OwnerAddress into individual columns (Address, City, State)

SELECT OwnerAddress
FROM nashville_housing;

SELECT 
	SUBSTRING_INDEX(OwnerAddress, ",",1) AS Address, -- Extracting everything before ","
	SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS City,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD OwnerSplitAddress VARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ",",1);

ALTER TABLE nashville_housing
ADD OwnerSplitCity VARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);

ALTER TABLE nashville_housing
ADD OwnerSplitState VARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

-- Changing "Y" and "N" to "Yes" and "No" in "Sold as Vacant" field 

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = "Y" THEN "Yes"
    WHEN SoldAsVacant = "N" THEN "No"
    ELSE SoldAsVacant
END 
FROM nashville_housing;

UPDATE nashville_housing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = "Y" THEN "Yes"
    WHEN SoldAsVacant = "N" THEN "No"
    ELSE SoldAsVacant
END;

-- Removing duplicates 
-- 1. Identifying duplicates

WITH row_num AS 
(
SELECT *,
ROW_NUMBER () OVER(PARTITION BY
			parcelID,
			PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            ORDER BY UniqueID) AS Row_Nums
FROM nashville_housing
) 
SELECT *
FROM row_num
HAVING row_nums > 1
ORDER BY PropertyAddress ASC;

-- 2. Deleting duplicates

WITH row_num AS 
(
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY parcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS Row_Nums
    FROM nashville_housing
) 
DELETE nashville_housing -- I want to delete rows from the original table
FROM nashville_housing 
JOIN row_num ON nashville_housing.UniqueID = row_num.UniqueID -- Allow us to reference Row_Nums below
WHERE row_num.Row_Nums > 1; -- Ensures only rows with Row_Nums > 1 are deleted

-- Deleting dispensable columns 

ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;











 
 
