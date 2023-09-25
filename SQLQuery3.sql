

  --standardise date format to just date without time

  Select SaleDateConverted, CONVERT (date, SaleDate) 
  FROM [data cleaning portfolio].[dbo].housing

  Update housing
 SET SaleDate = CONVERT (date, SaleDate)

 ALTER Table [data cleaning portfolio].[dbo].housing
 Add SaleDateConverted Date:

Update [data cleaning portfolio].[dbo].housing
 SET SaleDateConverted = CONVERT (date, SaleDate)

 --Fill spaces where property addrress is null
 SELECT *
  FROM [data cleaning portfolio].[dbo].housing
  order by ParcelID
  WHERE a.PropertyAddress is null

	Update a
	SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
	FROM [data cleaning portfolio].[dbo].housing as a
  JOIN [data cleaning portfolio].[dbo].housing as b
  on a.ParcelID = b.ParcelID
  AND a.UniqueID <> b. UniqueID
    WHERE a.PropertyAddress is null

	--CREATING ADDRESS WITHOUT THE NAME OF THE CITY

	SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX (',',PropertyAddress)-1) As Address
	, SUBSTRING(PropertyAddress, CHARINDEX (',',PropertyAddress) +1 , LEN (PropertyAddress)) As City
	FROM [data cleaning portfolio].[dbo].housing
	
	ALTER Table [data cleaning portfolio].[dbo].housing
 Add AddressOnly Nvarchar (255)

Update [data cleaning portfolio].[dbo].housing
 SET AddressOnly  = SUBSTRING(PropertyAddress, 1, CHARINDEX (',',PropertyAddress)-1) 

 ALTER Table [data cleaning portfolio].[dbo].housing
 Add CityOnly Nvarchar (255)
Update [data cleaning portfolio].[dbo].housing
 SET CityOnly = SUBSTRING(PropertyAddress, CHARINDEX (',',PropertyAddress) +1 , LEN (PropertyAddress))

	--split the cells of thee owner address column into owner's split address, city and state 
	--and update it on table

	SELECT OwnerAddress
	FROM [data cleaning portfolio].[dbo].housing

	SELECT 
	PARSENAME (REPLACE (OwnerAddress, ',', '.'), +3),
	PARSENAME (REPLACE (OwnerAddress, ',', '.'), +2),
	PARSENAME (REPLACE (OwnerAddress, ',', '.'), +1)
	FROM [data cleaning portfolio].[dbo].housing
	

	ALTER Table [data cleaning portfolio].[dbo].housing
 Add OwnerSplitAddress Nvarchar (255)

Update [data cleaning portfolio].[dbo].housing
 SET OwnerSplitAddress = PARSENAME (REPLACE (OwnerAddress, ',', '.'), +3)

 ALTER Table [data cleaning portfolio].[dbo].housing
 Add OwnerSplitCity Nvarchar (255)

Update [data cleaning portfolio].[dbo].housing
 SET OwnerSplitCity = PARSENAME (REPLACE (OwnerAddress, ',', '.'), +2)

  ALTER Table [data cleaning portfolio].[dbo].housing
 Add OwnerSplitState Nvarchar (255)

Update [data cleaning portfolio].[dbo].housing
 SET OwnerSplitState = PARSENAME (REPLACE (OwnerAddress, ',', '.'), +1)


SELECT Distinct (SoldAsVacant)
FROM [data cleaning portfolio].[dbo].housing

--we have N, Y , Yes and No, and it shouldn't be so, let's make all y as yes and all N as No

SELECT (SoldAsVacant),
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [data cleaning portfolio].[dbo].housing

Update [data cleaning portfolio].[dbo].housing
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


--REMOVE DUPLICATES
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER () OVER (
PARTITION BY PARCELID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID
			 )row_num

FROM [data cleaning portfolio].[dbo].housing
)

DELETE 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


 