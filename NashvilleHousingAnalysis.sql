
SELECT *
FROM NashvilleHousing

-- STANDARDIZED DATE FORMAT
-- HOW TO CHANGE THE DATE FORMAT
SELECT SaleDateConverted, CONVERT(date, saledate)
FROM NashvilleHousing

-- HERE WHEN WE ADD THE NEW COLUMN SaleDateConverted TO THE TABLE, WE HAVE
-- TO SPECIFY: ADD ConvertedColumnName THE DATA TYPE WE Wnt to convert it to -DATE
ALTER TABLE NashvilleHousing 
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, saledate)

-- POPULATE PROPERTY ADDRESS DATE
-- USING A SELF JOIN
SELECT *
FROM NashvilleHousing
-- WHERE PropertyAddress is NULL 
order BY ParcelID

-- when we use self joins, we have to find a way to distinguish
-- what we select from the table from themselves that is why we use
-- the unique id because the saleDate, propertyAddress, ParcelId can
-- be the same
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null

-- when updating a table, we do so using its ALIAS else we would get an error
-- we can also replace a null value with a string from the ISNULL clause, instead of
-- b.PropertyAddress we can use 'No Address'
UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null


-- BREAKING OUT THE ADDRESS INTO INDIVIDUAL COLUMNS(ADRRESS, CITY, STATE)  
SELECT *
FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

 SELECT
PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2),
PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing 
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)
 


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
 

ALTER TABLE NashvilleHousing 
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

SELECT *
FROM NashvilleHousing



--CHANGE Y AND N TO YES AND NO IN 'SOL D AS VACANT' FIELD
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2
-- the 2 there means 'order by the second column'

SELECT SoldAsVacant, 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant =  'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END

-- REMOVING DUPLICATES FROM A TABLE
WITH DuplicateCTE AS(
SELECT *,
    ROW_NUMBER()OVER(
	    PARTITION BY ParcelId,
		            PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order By
					    UniqueId
					)AS row_num
FROM NashvilleHousing
)
DELETE 
from DuplicateCTE
WHERE row_num > 1
-- ORDER BY UniqueId


-- DELETE UNUSED COLUMNS
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate