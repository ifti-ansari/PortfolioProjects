/*
Cleaning Data in SQL Queries
*/


select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDateConverted,CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE Nashvillehousing
ADD SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)






 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null

select  a.UniqueID, b.UniqueID, a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID 
where a.PropertyAddress IS null

update a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID 
where a.PropertyAddress IS null






--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT propertyaddress
from PortfolioProject.dbo.NashvilleHousing



--Where PropertyAddress is null
--order by ParcelID


SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyaddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress)) as city

From PortfolioProject.dbo.NashvilleHousing




ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD address Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
SET address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyaddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD city Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
SET city = SUBSTRING(PropertyAddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress))

select * 
from PortfolioProject.dbo.NashvilleHousing


-- Spliting owner address (same as above) using PARSENAME



select owneraddress 
from PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(owneraddress,',','.'),3) as ownersadress,
PARSENAME(REPLACE(owneraddress,',','.'),2) as ownercity,
PARSENAME(REPLACE(owneraddress,',','.'),1) as ownerstate
from PortfolioProject.dbo.NashvilleHousing






ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD ownersplitaddress Nvarchar(255);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD ownercity Nvarchar(255);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD ownerstate Nvarchar(255);


update PortfolioProject.dbo.NashvilleHousing
SET ownersplitaddress =  PARSENAME(REPLACE(owneraddress,',','.'),3)

update PortfolioProject.dbo.NashvilleHousing
SET ownercity =  PARSENAME(REPLACE(owneraddress,',','.'),2)

update PortfolioProject.dbo.NashvilleHousing
SET ownerstate =  PARSENAME(REPLACE(owneraddress,',','.'),1)



select *
from PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


select 
DISTINCT SoldAsVacant, COUNT(SoldAsVAcant)
From PortfolioProject.dbo.NashvilleHousing
GROUP by SoldAsvacant
order by 2


Select DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
	 
From PortfolioProject.dbo.NashvilleHousing

GROUP BY SoldAsVacant

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END








-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
select*,
   row_number() over(
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
				     UniqueID
					 )Row_num


from PortfolioProject.dbo.NashvilleHousing
)

--order By ParcelID
DELETE
FROM RowNumCTE
WHERE Row_num >1

--Order by PropertyAddress

--order by ParcelID



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



select *
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress













-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
