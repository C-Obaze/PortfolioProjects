-- populate propertyaddress
SELECT a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ifnull(a.propertyaddress, b.propertyaddress)
FROM projectportfolio.`nashville housing` a
join projectportfolio.`nashville housing` b
	on a.parcelID = b.parcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update projectportfolio.`nashville housing` a
join projectportfolio.`nashville housing` b
	on a.parcelID = b.parcelID
	and a.UniqueID <> b.UniqueID
set a.propertyaddress = ifnull(a.propertyaddress, b.propertyaddress)
where a.PropertyAddress is null;

-- breaking out propertyaddress into individual columns(address, city)
select 
substring(propertyaddress, 1, position(',' in propertyaddress)-1) as address,
substring(propertyaddress, position(',' in propertyaddress)+1, length(propertyaddress)) as address
from projectportfolio.`nashville housing`;

alter table projectportfolio.`nashville housing`
add newPropertyAddress varchar(255);

update projectportfolio.`nashville housing`
set newPropertyAddress = substring(propertyaddress, 1, position(',' in propertyaddress)-1);

alter table projectportfolio.`nashville housing`
add PropertySplitCity varchar(255);

update projectportfolio.`nashville housing`
set PropertySplitCity = substring(propertyaddress, position(',' in propertyaddress)+1, length(propertyaddress));

select newpropertyaddress, propertysplitcity from projectportfolio.`nashville housing`;

-- breaking out owneraddress into individual columns(address, city, state)
select
substring_index(owneraddress, ',', 1),
substring_index(substring_index(owneraddress, ',', 2), ',', -1),
substring_index(owneraddress, ',', -1)
from projectportfolio.`nashville housing`;

alter table projectportfolio.`nashville housing`
add OwnerSplitAddress varchar(255);

update projectportfolio.`nashville housing`
set OwnerSplitAddress = substring_index(owneraddress, ',', 1);

alter table projectportfolio.`nashville housing`
add OwnerSplitCity varchar(255);

update projectportfolio.`nashville housing`
set OwnerSplitCity = substring_index(substring_index(owneraddress, ',', 2), ',', -1);

alter table projectportfolio.`nashville housing`
add OwnerSplitState varchar(255);

update projectportfolio.`nashville housing`
set OwnerSplitState = substring_index(owneraddress, ',', -1);

select ownersplitaddress, ownersplitcity, ownersplitstate from projectportfolio.`nashville housing`;

-- change 'Y' and 'N' to 'YES' and 'NO' in column; soldasvacant
select distinct(soldasvacant), count(soldasvacant)
from projectportfolio.`nashville housing`
group by SoldAsVacant
order by 2;

select soldasvacant,
case when soldasvacant = 'y' then 'yes'
	 when soldasvacant = 'n' then 'no'
	 else soldasvacant
     end
from projectportfolio.`nashville housing`;

update projectportfolio.`nashville housing`
set soldasvacant = case when soldasvacant = 'y' then 'yes'
						when soldasvacant = 'n' then 'no'
						else soldasvacant
						end;
                        
-- remove duplicates
with rownumcte as(
select *,
	row_number() over(
    partition by parcelid,
				 propertyaddress,
                 saleprice,
                 saledate,
                 legalreference
                 order by
					 UniqueID
					 ) row_num
from projectportfolio.`nashville housing`
)
select count(*)
from rownumcte
where row_num > 1;

with uniqueid_tokeep 
as(
	SELECT MIN(uniqueid)
	FROM projectportfolio.`nashville housing`
	GROUP BY parcelid,propertyaddress,saleprice,saledate,legalreference
    )
delete
from projectportfolio.`nashville housing`
where uniqueid not in(
					  select * 
                      from uniqueid_tokeep
					 );

select * from projectportfolio.`nashville housing`;

-- delete unused columns
select * from projectportfolio.`nashville housing`;

alter table projectportfolio.`nashville housing`
drop column owneraddress,
drop column taxdistrict,
drop column propertyaddress;

