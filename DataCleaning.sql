/*
Cleaning Data in SQL Queries
*/

SELECT *
From [PorfolioProject].[dbo].[NashvilleHousing]

-- Standardize Date Format: CONVERT(Date, SaleDate) 
SELECT SaleDate 
FROM [PorfolioProject].[dbo].[NashvilleHousing]

-- Populate Property Address data
SELECT *
FROM [PorfolioProject].[dbo].[NashvilleHousing]
-- WHERE [PorfolioProject].[dbo].[NashvilleHousing].[PropertyAddress] is NULL
ORDER BY [ParcelID]

SELECT a.ParcelID, a.[OwnerAddress], b.ParcelID, b.[OwnerAddress], ISNULL(a.[OwnerAddress], b.[OwnerAddress])
FROM [PorfolioProject].[dbo].[NashvilleHousing] a 
JOIN [PorfolioProject].[dbo].[NashvilleHousing] b 
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.OwnerAddress is NULL

UPDATE a 
SET [OwnerAddress] = ISNULL(a.[OwnerAddress], b.[OwnerAddress])
FROM [PorfolioProject].[dbo].[NashvilleHousing] a 
JOIN [PorfolioProject].[dbo].[NashvilleHousing] b 
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.[OwnerAddress] is NULL

-- Breaking OUT Address into Individual Columns (Address, City, State)

SELECT [OwnerAddress]
FROM [PorfolioProject].[dbo].[NashvilleHousing]
-- WHERE [PorfolioProject].[dbo].[NashvilleHousing].[PropertyAddress] is NULL
-- ORDER BY [ParcelID]

SELECT
SUBSTRING( [OwnerAddress], 1, CHARINDEX(',', [OwnerAddress]) -1) AS Address
, SUBSTRING( [OwnerAddress], CHARINDEX(',', [OwnerAddress]) +1, LEN([OwnerAddress])) AS Address
-- CHARINDEX(',', [PropertyAddress]) specifying position of character
FROM [PorfolioProject].[dbo].[NashvilleHousing]

ALTER TABLE [PorfolioProject].[dbo].[NashvilleHousing]
ADD [PropertySplitAddress] NVARCHAR(255);


UPDATE [PorfolioProject].[dbo].[NashvilleHousing]
SET [PropertySplitAddress] = PARSENAME(REPLACE([OwnerAddress], ',', '.'), 3)

ALTER TABLE [NashvilleHousing]
ADD [PropertySplitCity] NVARCHAR(255);

UPDATE [NashvilleHousing]
SET [PropertySplitCity] = PARSENAME(REPLACE([OwnerAddress], ',', '.'), 2)

ALTER TABLE [NashvilleHousing]
ADD [PropertySplitState] NVARCHAR(255);

UPDATE [NashvilleHousing]
SET [PropertySplitState] = PARSENAME(REPLACE([OwnerAddress], ',', '.'), 1)

SELECT *
FROM [PorfolioProject].[dbo].[NashvilleHousing]



SELECT [OwnerAddress]
FROM [PorfolioProject].[dbo].[NashvilleHousing]


/* 

SELECT 
PARSENAME(REPLACE([OwnerAddress], ',', '.'), 3),
PARSENAME(REPLACE([OwnerAddress], ',', '.'), 2),
PARSENAME(REPLACE([OwnerAddress], ',', '.'), 1)
FROM [PorfolioProject].[dbo].[NashvilleHousing]

*/

-- Change Y and N to Yes and No in "Sold as Vacant" field 
-- This demonstrate substituting Values in a table


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [PorfolioProject].[dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT [SoldAsVacant],
CASE WHEN [SoldAsVacant] = 'Y' THEN 'Yes'
     WHEN [SoldAsVacant] = 'N' THEN 'NO'
     ELSE [SoldAsVacant]
     END
FROM [PorfolioProject].[dbo].[NashvilleHousing]

UPDATE [PorfolioProject].[dbo].[NashvilleHousing]
SET [SoldAsVacant] =
CASE WHEN [SoldAsVacant] = 'Y' THEN 'Yes'
     WHEN [SoldAsVacant] = 'N' THEN 'NO'
     ELSE [SoldAsVacant]
     END


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [PorfolioProject].[dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2

/* Remove Duplicates */

WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID,
                     PropertyAddress,
                     SalePrice,
                     SaleDate,
                     LegalReference
                     ORDER BY
                        UniqueID
    )row_num
FROM [PorfolioProject].[dbo].[NashvilleHousing]
--ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


/* Delete Unused Columns */

SELECT *
FROM [PorfolioProject].[dbo].[NashvilleHousing]

ALTER TABLE [PorfolioProject].[dbo].[NashvilleHousing]
DROP COLUMN [OwnerAddress], [TaxDistrict], [PropertyAddress]
