--Standardize Date Format-
--tarih formatinin yeni halini bu komutla gorebilir
Select SaleDate, CONVERT(date,SaleDate)
from NashvilleHousing
--bu komut ile detablodaki tarih kismini yeni format ile guncelleyeebiliriz
Update NashvilleHousing 
Set SaleDate=CONVERT(date,SaleDate)s


--------------------------------------------------------------
--Populate Property Adress Data
Select PropertyAddress
From NashvilleHousing
Where PropertyAddress is Null

--There are elements that Property adress is nul, but at  same location
--and same parcel ID there are propety adress, we 'll use that

--first: parcel id leri eslesenler
Select a.ParcelID,a.PropertyAddress , b.ParcelID,b.PropertyAddress
From NashvilleHousing a
Join NashvilleHousing b on a.ParcelID=b.ParcelID
And a.[UniqueID ]<>b.[UniqueID ]--means not equal

--parcel id leri eslesen 17318 kayittan - icerisinde null olanlar

Select a.ParcelID,a.PropertyAddress , b.ParcelID,b.PropertyAddress
From NashvilleHousing a
Join NashvilleHousing b on a.ParcelID=b.ParcelID
And a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null
--bu bize 35 kayit listelemis olur


--isnull ile null icerisine atanmasi gereken column olusturma
Select a.ParcelID,a.PropertyAddress , b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b on a.ParcelID=b.ParcelID
And a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null


--
Update a
Set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b 
on a.ParcelID=b.ParcelID And a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

--ADRESS i Adres ,sehir ve eyalet seklinde bolmek

Select PropertyAddress
From NashvilleHousing

--

Select 
Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
--ikinci substrinde baslama konumu virgulun ildugu nokta
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address

From NashvilleHousing
--
--degistirilmis verileri tabloya ekleyelim
--tabloyu alter etmemiz ve yeni kolonlar eklememiz ve islememeiz gerekecek
 -- bu 4 asamayi tek tek execute et 
 Alter Table NashvilleHousing
 Add PropertySplitAddress Nvarchar(255);

 Update NashvilleHousing--icerisine de substringi atayacaz
 Set PropertySplitAddress =Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

  Alter Table NashvilleHousing
 Add PropertySplitCity Nvarchar(255);

 Update NashvilleHousing--icerisine de substringi atayacaz
 Set PropertySplitCity =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

 
--lets check
select * from
NashvilleHousing





--parse name ile parcalara ayiracagiz,
--replace ile icerisindeki  virgulu nokta ile degiselim,  parse okumaz yoksa

Select
PARSENAME(Replace(OwnerAddress,',','.'),1)
From NashvilleHousing

--bunu calsitirinca en sondaki eyalaetin kisaltmasi olan tn yi alir
--tum parcalari icin yapalim
Select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)

From NashvilleHousing

--bunlari tabloya update ve alter ile isleyelim
--hepsini parca parca execute et
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
--
Update NashvilleHousing
Set OwnerSplitAddress =PARSENAME(Replace(OwnerAddress,',','.'),2)
--
ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
--
Update NashvilleHousing
Set OwnerSplitCity =PARSENAME(Replace(OwnerAddress,',','.'),1)
--
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);
--
Update NashvilleHousing
Set OwnerSplitState =PARSENAME(Replace(OwnerAddress,',','.'),1)
--
-----------------------------------------------
--Sold as Vacant sutunundaki y veya n seklinde olanlari yes no ya cevir

--hangisinden kac tane var
Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2

--y ve n leri degisitirip yeni bir kolonda yeni hallerini tutalim
Select SoldAsVacant
	,Case When SoldAsVacant='Y' Then 'Yes'
		  When SoldAsVacant='N' Then 'No'	
		  Else SoldAsVacant
	 End
From NashvilleHousing

--update edelim
Update NashvilleHousing
Set SoldAsVacant=Case When SoldAsVacant='Y' Then 'Yes'
					  When SoldAsVacant='N' Then 'No'	
					  Else SoldAsVacant
				 End

--tekrardan bir distinct ile bakkalim
Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2


-----------------------------------------------------------
--Remove Duplicates

--once gruplayalim partition ile
Select*,
	 ROW_NUMBER() Over(
	 --partition bölmek demek, ama buradaki amaci ne
		Partition By ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
		 Order By 
			UniqueID
	) as row_num
From NashvilleHousing
--order by ParcelID

--duplicated elri secmis olduk
WITH RowNumCTE AS(
Select*,
	 ROW_NUMBER() Over(
	 --partition bölmek demek, ama buradaki amaci ne
		Partition By ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
		 Order By 
			UniqueID
	) as row_num
From NashvilleHousing
)
Select * 
from RowNumCTE
Where row_num>1
Order by PropertyAddress



--simdi bu kopyalari silelim
WITH RowNumCTE AS(
Select*,
	 ROW_NUMBER() Over(
	 --partition bölmek demek, ama buradaki amaci ne
		Partition By ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
		 Order By 
			UniqueID
	) as row_num
From NashvilleHousing
)
Delete  
from RowNumCTE
Where row_num>1

----
--delete Unused Columns

Select*
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress , TaxDistrict	, PropertyAddress
