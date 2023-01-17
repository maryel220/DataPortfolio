/*
Cleaning data in SQL Queries 
*/
-------------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format if date format is datetime format not just date
 SELECT SaleDate, CONVERT(Date,SaleDate)
 FROM PortfolioProject..NashvilleHousing

 UPDATE NashvilleHousing
 SET SaleDate = CONVERT(Date,SaleDate)

 --or--

 ALTER TABLE NashvilleHousing
 Add SaleDateConverted Date

 UPDATE NashvilleHousing
 SET SaleDateConverted = CONVERT(Date,SaleDate)
-- Populate NULL Property Address data
  SELECT *
  FROM PortfolioProject.dbo.NashvilleHousing
  --WHERE PropertyAddress IS NULL
  ORDER BY ParcelID

  SELECT a.ParcelId, a.PropertyAddress, b.ParcelId, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
  FROM PortfolioProject.dbo.NashvilleHousing a
  JOIN PortfolioProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress IS NULL
  
  UPDATE a
  SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
  FROM PortfolioProject.dbo.NashvilleHousing a
  JOIN PortfolioProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress IS NULL
-- Breaking out Adress into individual columns (Addres, city, state)
-- USING SUBSTRINGS
  SELECT PropertyAddress
  FROM PortfolioProject.dbo.NashvilleHousing
  --WHERE PropertyAddress IS NULL
  --ORDER BY ParcelID


  SELECT
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address, 
  SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) AS City
  FROM PortfolioProject.dbo.NashvilleHousing

 ALTER TABLE NashvilleHousing
 Add PropertySplitAddress NVARCHAR(255);

 UPDATE NashvilleHousing
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

 ALTER TABLE NashvilleHousing
 Add PropertySplitCity NVARCHAR(255);

 UPDATE NashvilleHousing
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

  
-- or -- USING PARSENAME
  
 SELECT OwnerAddress
 FROM PortfolioProject.dbo.NashvilleHousing

 SELECT
 PARSENAME(REPLACE(OwnerAddress,',','.'),3),
 PARSENAME(REPLACE(OwnerAddress,',','.'),2),
 PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 FROM PortfolioProject.dbo.NashvilleHousing

 ALTER TABLE NashvilleHousing
 Add OwnerSplitAddress NVARCHAR(255);

 UPDATE NashvilleHousing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

 ALTER TABLE NashvilleHousing
 Add OwnerSplitCity NVARCHAR(255);

 UPDATE NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
 
 ALTER TABLE NashvilleHousing
 Add OwnerSplitState NVARCHAR(255);

 UPDATE NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

-- CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT'

 SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
 FROM PortfolioProject.dbo.NashvilleHousing
 GROUP BY SoldAsVacant
 order By 2

 SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
         WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END
 FROM PortfolioProject.dbo.NashvilleHousing

 UPDATE NashvilleHousing
 SET SoldAsVacant =     CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
         WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END
 FROM PortfolioProject.dbo.NashvilleHousing

-- REMOVE DUPLICATES 
 WITH rowNumCTE AS (
 SELECT *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelId,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
                    UniqueID
    ) row_num

 FROM PortfolioProject.dbo.NashvilleHousing
 )
 DELETE
 FROM rowNumCTE
 WHERE row_num > 1

-- DELETE UNUSED COLUMNS
 
 ALTER TABLE PortfolioProject.dbo.NashvilleHousing
 DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

 SELECT *
 FROM PortfolioProject.dbo.NashvilleHousing


 
 
 
 




 








