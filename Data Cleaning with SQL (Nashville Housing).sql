/* Cleaning Data in SQL Queries 
*/

Select *
From Portfolioproject.dbo.NashvilleHousing

-- Standardize Date Format

Select SaleDate, Convert(Date, SaleDate)
From Portfolioproject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = convert(Date, SaleDate)

Select SaleDateConverted, Convert(Date, SaleDate)
From Portfolioproject.dbo.NashvilleHousing


-- Populate Property Address Data

Select *
From PortfolioProject.dbo.NashvilleHousing
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
  On a.ParcelID = b.ParcelID
  And a.[UniqueID] <> b.[UniqueID]
  Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
  On a.ParcelID = b.ParcelID
  And a.[UniqueID] <> b.[UniqueID]

Select PropertyAddress
From NashvilleHousing
Where PropertyAddress IS Null

-- Breaking out Address Into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
  
Select
Substring(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,  Len(PropertyAddress)) as Address
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1 ) 


Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,  Len(PropertyAddress))

Select *
From NashvilleHousing


Select 
PARSENAME(Replace(OwnerAddress, ',', '.') ,3),
PARSENAME(Replace(OwnerAddress, ',', '.') ,2),
PARSENAME(Replace(OwnerAddress, ',', '.') ,1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') ,3)


Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') ,2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') ,1)


--Change Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order By 2


Select SoldAsVacant,
Case
	When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case
	When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
End

-- Remove Duplicates

With RowNumCTE AS(
Select *,
  ROW_NUMBER() Over (
   Partition by ParcelID,
				PropertyAddress,
				SalePrice, 
				SaleDate,
				LegalReference
				Order by UniqueId 
				) row_num
From NashvilleHousing
)
Delete
From RowNumCTE
Where row_num >1


-- Delete Unused Columns

Select *
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousing
Drop Column SaleDate