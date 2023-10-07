Select * 
from NashvilleHousing

--Standard Date format

Select SaleDate , CONVERT(Date, SaleDate)
from NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)


Select SaleDateConverted , CONVERT(Date, SaleDate)
from NashvilleHousing

--Populate Null Property Address

Select ParcelID, PropertyAddress
from NashvilleHousing
Where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from NashvilleHousing a
Join NashvilleHousing b
On a.ParcelID = b.ParcelID
And a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
Join NashvilleHousing b
On a.ParcelID = b.ParcelID
And a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into ( Address, City, State)

Select PropertyAddress, 
       SUBSTRING(PropertyAddress, 1, CHARINDEX( ',',PropertyAddress)-1) Address,
	   SUBSTRING(PropertyAddress, CHARINDEX( ',',PropertyAddress)+1, LEN(PropertyAddress)) City
from NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(200)

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX( ',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(200)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX( ',',PropertyAddress)+1, LEN(PropertyAddress))

 
-- With Housing
-- As 
--(Select PropertyAddress, 
--       SUBSTRING(PropertyAddress, 1, CHARINDEX( ',',PropertyAddress)-1) Address,
--	   SUBSTRING(PropertyAddress, CHARINDEX( ',',PropertyAddress)+1, LEN(PropertyAddress)) City
--from NashvilleHousing

--)

--Select * from Housing
--Where City Like '%Unknown%'

--Parsename is used to split from backwards using delimiter as a period 

Select OwnerAddress,
       PARSENAME(Replace(OwnerAddress, ',', '.'),3),
	   PARSENAME(Replace(OwnerAddress, ',', '.'),2),
	   PARSENAME(Replace(OwnerAddress, ',', '.'),1)
from NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'),1)

Select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant"

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
       Case
           When SoldAsVacant = 'Y' Then 'Yes'
		   When SoldAsVacant = 'N' Then 'No'
		   Else SoldAsVacant
	   End
from NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant=  Case
                       When SoldAsVacant = 'Y' Then 'Yes'
		               When SoldAsVacant = 'N' Then 'No'
					    Else SoldAsVacant
	               End

-- Remove Duplicates
With RowHousing
as
(
Select *,
       ROW_NUMBER() Over (Partition by 
	                                  ParcelId,
									  PropertyAddress,
									  Saledate,
									  SalePrice,
									  LegalReference
							Order by UniqueID)       As row_num                    
from NashvilleHousing
--Order by ParcelID
)

Select * from RowHousing

Select Distinct(row_num) from RowHousing 
Where row_num > 1

--Delete
--from RowHousing
--Where row_num > 1
--Order by PropertyAddress


--Drop table NashvilleHousing

--Dropping Columns

Select * from NashvilleHousing

Alter Table NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, TaxDistrict

Alter Table NashvilleHousing
Drop Column SaleDate