Select *
From [Portfolio Project 1].dbo.NashvilleHousing


-- Change The SaleDate Format

Select SaleDataConverted, CONVERT(date, saledate)
From [Portfolio Project 1].dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDataConverted Date;

UPDATE NashvilleHousing
SET SaleDataConverted = CONVERT(date, SaleDate)





---------------------------------------------------------------------------------------
-- Populate Property Address Data


Select *
From [Portfolio Project 1].dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project 1].dbo.NashvilleHousing a
Join [Portfolio Project 1].dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
where a. PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project 1].dbo.NashvilleHousing a
Join [Portfolio Project 1].dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a. PropertyAddress is null




---------------------------------------------------------------------------------------
-- Breaking Out Address Into Individual Columns (Address, City, State)


Select PropertyAddress
From [Portfolio Project 1].dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From [Portfolio Project 1].dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))




Select OwnerAddress
From [Portfolio Project 1].dbo.NashvilleHousing




Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio Project 1].dbo.NashvilleHousing




ALTER TABLE [Portfolio Project 1].dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE [Portfolio Project 1].dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)



ALTER TABLE [Portfolio Project 1].dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE [Portfolio Project 1].dbo.NashvilleHousing
SET PropertySplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [Portfolio Project 1].dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE [Portfolio Project 1].dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)





---------------------------------------------------------------------------------------
-- Change Y AND N to Yes and No in "SoldAsVacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project 1].dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
, Case When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End
From [Portfolio Project 1].dbo.NashvilleHousing


Update [Portfolio Project 1].dbo.NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End



---------------------------------------------------------------------------------------
-- Remove Duplicates

With RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num


From [Portfolio Project 1].dbo.NashvilleHousing
)

Delete
From RowNumCTE
Where row_num > 1




---------------------------------------------------------------------------------------
-- Delete Unused Columns


Select *
From [Portfolio Project 1].dbo.NashvilleHousing


ALTER TABLE [Portfolio Project 1].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress


ALTER TABLE [Portfolio Project 1].dbo.NashvilleHousing
DROP COLUMN SaleDate
