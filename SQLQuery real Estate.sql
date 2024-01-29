--1-Retrieve all information for all properties in the dataset
select * from Real_Estate

--2-Retrieve property details for the town 'YourTown(Manchester)' and display them in ascending order based on the Sale Amount.
select * from Real_Estate
where Town ='Manchester'
order by Sale_Amount asc;

--3-Calculate and show the average Assessed Value for all properties.
Select round(AVG(Assessed_Value),2)as average_Assessed_Value from Real_Estate

--4-Count the number of properties for each unique Residential Type.
select Property_Type, count(*)as total_count from Real_Estate
group by Property_Type

--medium
--1-Retrieve property records where the sale was recorded in the year 2020
select * from Real_Estate
where List_Year='2020';
--or
select *,YEAR(date_recorded)as a from Real_Estate
where YEAR(date_recorded)='2020';


--2-Find the minimum and maximum Sales Ratio for each Property Type.
select Property_Type,ROUND(MIN(Sales_Ratio),4) AS min_sales,ROUND(max(Sales_Ratio),4) AS MAX_SALE
from Real_Estate
GROUP BY Property_Type

--3-Retrieve details for properties in 'YourTown/Manchester' with Sale Amount greater than the average Sale Amount for all towns.

select * from Real_Estate
where town='Manchester' and Sale_Amount >=
(select avg(sale_amount)as avg_sale from Real_Estate);


--4-Retrieve property details where the Sale Amount is greater than the Assessed Value. Include town and address.
select * from Real_Estate
where Sale_Amount>=Assessed_Value;
-- or
select Town,Address, Sale_Amount from Real_Estate
where Sale_Amount>=Assessed_Value
group by Town,Address, Sale_Amount

--5-Calculate the average Sale Amount for properties with a Sales Ratio above 0.8.
select avg(Sale_Amount)as avgsale_amount from Real_Estate
where Sales_Ratio >=0.8;


--1-Retrieve property details with the highest Sale Amount for each town.
select * from Real_Estate

with cte as(
select * from Real_Estate)
select  town,max(sale_amount) highestsale from cte
group by town




--2-Rank properties based on Sale Amount within each Property Type.
select * from Real_Estate
with cte as(
select sale_amount,property_type, dense_rank() over(partition by property_type order by sale_amount desc )as rn from Real_Estate 
where property_type is not null and sale_amount is not null
) 
select property_type,sale_amount,rn from cte 
group by property_type,sale_amount,rn
order by sale_amount desc

--3-Create a pivot table showing the count of properties for each Residential Type and Property Type combination.
select * from Real_Estate

SELECT *
FROM (
    SELECT Residential_Type, Property_Type
    FROM Real_Estate -- Replace YourTableName with the actual name of your table
  
) AS SourceTable
PIVOT (
    count(Property_Type)
    FOR Property_Type IN ([Residential], [Commercial],[Vacant Land]) -- Specify your Property Types
) AS PivotTable;

--4-Use a CTE to calculate the difference between Sale Amount and Assessed Value. Retrieve records where this difference is greater than a certain threshold.(50000)

with cte as( select *,(sale_amount-Assessed_Value)as differnce from Real_Estate)
select * from cte
where differnce >=500000

--5-Calculate the total Sale Amount for each month in the List Year. 
--Retrieve properties for 'YourTown' where there is no record with the same address and a higher Sale Amount.

select * from Real_Estate

with cte as(select month(date_recorded) as months,sum(Sale_Amount)as sales
from Real_Estate
group by month(date_recorded))
select * from cte
order by months


select a.town,a.address,a.sale_amount
from Real_Estate a
join Real_Estate b on a.Address=b.Address
where a.Town='Ansonia' and b.Address is not null

--1-Calculate the year-over-year percentage change in the total Sale Amount for each town.

select town,sale_amount,lag(sale_amount,1) over (partition by town order by sale_amount) as previous_yr,
case 
	when lag(sale_amount) over (partition by town order by sale_amount) is not null and LAG(Sale_Amount,1) over( partition by town order by Sale_Amount )!=0 then
	round((sale_amount-lag(sale_amount) over (partition by town order by sale_amount) )/ LAG(Sale_Amount,1) over( partition by town order by Sale_Amount )*100,2)
	else
	null
	end  as yoysale
from Real_Estate


--0r
select town,list_year,Sale_Amount,
LAG(Sale_Amount,1) over( partition by town order by Sale_Amount ) as previous_yr  ,
(Sale_Amount-LAG(Sale_Amount,1) over( partition by town order by Sale_Amount )) as yoy,
case 
    when LAG(Sale_Amount,1) over( partition by town order by Sale_Amount ) is not null and LAG(Sale_Amount,1) over( partition by town order by Sale_Amount )!=0 then
	(Sale_Amount-LAG(Sale_Amount,1) over( partition by town order by Sale_Amount ))/LAG(Sale_Amount,1) over( partition by town order by Sale_Amount )*100
	else
	null
	end as yoy_per
from Real_Estate 

-- calculate yoy totalsales for each town
select town ,Sale_Amount,
lag(Sale_Amount,1) over(partition by town order by Sale_Amount)as previous_yr,
(Sale_Amount-lag(Sale_Amount,1) over(partition by town order by Sale_Amount)) as yoysale
from Real_Estate
order by Town


--2-Identify the town with the highest total Sale Amount and retrieve its geographical location.
select * from Real_Estate

with cte as(
	select town,sum(Sale_Amount)as total_sale
	from Real_Estate
	group by town
)
select town,max(total_sale) as maxsale
from cte
group by town
order by maxsale

-- or 

with cte as (select town,sum(sale_amount) as totalsum
from Real_Estate
group by Town) 
select town ,totalsum
from cte 
where totalsum= (select max(totalsum) from cte)



