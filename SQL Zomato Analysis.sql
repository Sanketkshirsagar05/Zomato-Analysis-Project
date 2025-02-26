create database zomato;

use zomato;

CREATE TABLE RestaurantData (
    RestaurantID int,
    RestaurantName varchar(100),
    CountryCode	int,
    City varchar(100),
    Cuisines varchar(100),
    Has_Table_booking	varchar(100),
    Has_Online_delivery varchar(100),
    Votes int,
    Average_Cost_for_two int,
    Rating varchar(100),
    Datekey_Opening	date 
);

select *from RestaurantData;

select count(*) from RestaurantData;

#1. Build a country Map Table
select distinct CountryCode from RestaurantData;

create table country (
		CountryCode varchar(100) primary key,
        CountryName varchar(100)
);

insert into Country (CountryCode, CountryName) 
values  (1, 'India'),
(14, 'Australia'),
(30, 'Brazil'),
(37, 'Canada'),
(94, 'Indonesia'),
(148, 'New Zealand'),
(162, 'Philippines'),
(166, 'Qatar'),
(184, 'Singapore'),
(189, 'South Africa'),
(191, 'Sri Lanka'),
(208, 'Turkey'),
(214, 'United Arab Emirates'),
(215, 'United Kingdom'),
(216, 'United States');

alter table RestaurantData add Country varchar(100);

update RestaurantData
set Country = (
    select CountryName
    from country
    where country.CountryCode = RestaurantData.CountryCode
)
where exists (
    select 1
    from country
    where country.CountryCode = RestaurantData.CountryCode
);

select * from RestaurantData;

#2. Build a Calendar Table using the Column Datekey

# A.Year
alter table RestaurantData add Year int;

update RestaurantData
set Year = YEAR(Datekey_Opening);

#B.Monthno
alter table RestaurantData add MonthNo int;

update RestaurantData
set MonthNo = MONTH(Datekey_Opening);

#C.MonthFullName
alter table RestaurantData add MonthFullName varchar(20);

update RestaurantData
set MonthFullName = monthname(Datekey_Opening);

#D.Quarter(Q1,Q2,Q3,Q4)
alter table RestaurantData add Quarter varchar(20);

update RestaurantData
set Quarter = 
    case 
        when month(Datekey_Opening) between 1 and 3 then 'Qtr-1'
        when month(Datekey_Opening) between 4 and 6 then 'Qtr-2'
        when month(Datekey_Opening) between 7 and 9 then 'Qtr-3'
        when month(Datekey_Opening) between 10 and 12 then 'Qtr-4'
    end;
    
#E. YearMonth ( YYYY-MMM)
alter table RestaurantData add YearMonth varchar(20);

update RestaurantData
set YearMonth = date_format(Datekey_Opening, '%Y-%b');

#F. Weekdayno
alter table RestaurantData add WeekdayNo int;

update RestaurantData
set WeekdayNo = case 
    when dayofweek(Datekey_Opening) = 1 then 7 
    else dayofweek(Datekey_Opening) - 1
end;

#G.Weekdayname
alter table RestaurantData add WeekdayName varchar(20);

update RestaurantData
set WeekdayName = dayname(Datekey_Opening);

#H.FinancialMOnth
alter table RestaurantData add FinancialMonth varchar(20);

update RestaurantData
set FinancialMonth = 
    case 
        when month(Datekey_Opening) = 4 then 'FM-1'
        when month(Datekey_Opening) = 5 then 'FM-2'
        when month(Datekey_Opening) = 6 then 'FM-3'
        when month(Datekey_Opening) = 7 then 'FM-4'
        when month(Datekey_Opening) = 8 then 'FM-5'
        when month(Datekey_Opening) = 9 then 'FM-6'
        when month(Datekey_Opening) = 10 then 'FM-7'
        when month(Datekey_Opening) = 11 then 'FM-8'
        when month(Datekey_Opening) = 12 then 'FM-9'
        when month(Datekey_Opening) = 1 then 'FM-10'
        when month(Datekey_Opening) = 2 then 'FM-11'
        when month(Datekey_Opening) = 3 then 'FM-12'
    end;

#I. Financial Quarter
alter table RestaurantData add FinancialQuarter varchar(20);

update RestaurantData
set FinancialQuarter = 
    case 
        when month(Datekey_Opening) between 4 and 6 then 'FQ-1'
        when month(Datekey_Opening) between 7 and 9 then 'FQ-2'
        when month(Datekey_Opening) between 10 and 12 then 'FQ-3'
        when month(Datekey_Opening) between 1 and 3 then 'FQ-4'
    end;

select * from RestaurantData;

#3.Find the Numbers of Resturants based on City and Country.
select Country, City, count(*) as NumberOfRestaurants
from RestaurantData
group by Country, City
order by NumberOfRestaurants desc;

#4.Numbers of Resturants opening based on Year , Quarter , Month
select Year, Quarter, MonthNo, count(*) as  NumberOfRestaurants
from RestaurantData
group by Year, Quarter, MonthNo
order by NumberOfRestaurants desc;

#5. Count of Resturants based on Average Ratings
with AvgRating as (
    select round(avg(Rating), 1) as AverageRating from RestaurantData
)
select 
    A.AverageRating,
    (select COUNT(*) from RestaurantData where round(Rating, 1) = A.AverageRating) as NumberOfRestaurants
from AvgRating A;

#6. Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets
select 
    case 
        when Average_Cost_for_two <= 250 then '0-250'
        when Average_Cost_for_two between 251 and 500 then '251-500'
        when Average_Cost_for_two between 501 and 750 then '501-750'
        when Average_Cost_for_two between 751 and 1000 then '751-1000'
        when Average_Cost_for_two between 1001 and 2000 then '1001-2000'
        else 'Above-2001'
    end as BucketRange,
    count(*) as NumberOfRestaurants
from RestaurantData
group by BucketRange
order by min(Average_Cost_for_two);

#7.Percentage of Resturants based on "Has_Table_booking"
select 
    Has_Table_booking,
    concat(round(count(*) * 100 / (select count(*) from RestaurantData), 2), '%') as Percentage
from RestaurantData
group by Has_Table_booking;

#8.Percentage of Resturants based on "Has_Online_delivery"
select 
    Has_Online_delivery,
    concat(round(count(*) * 100 / (select count(*) from RestaurantData), 2), '%') as Percentage
from RestaurantData
group by Has_Online_delivery;

#9. Develop Charts based on Cusines, City, Ratings
select City, round(avg(Rating), 2) as AvgRating
from RestaurantData
group by City
order by AvgRating desc
limit 10;

select Cuisines, count(*) as NumberOfRestaurants
from RestaurantData
group by Cuisines
order by NumberOfRestaurants desc
limit 5;