/*

Cleaning Data in SQL Queries

*/
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;


-- Standardize Data Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate) AS Date
FROM PortfolioProject.dbo.NashvilleHousing;


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID]  <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID]  <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;


--------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHousing;



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;




SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing;




ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




--------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;



SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

FROM PortfolioProject.dbo.NashvilleHousing;


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;




--------------------------------------------------------------------------


-- Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID) AS row_num

FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress




--------------------------------------------------------------------------


-- Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict