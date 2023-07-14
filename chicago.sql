

select * from chicago_weather..c_area
select * from chicago_weather..c_crime
select * from chicago_weather..c_temp
 -------------------------------------------------------------------------------------------------------------------------------------------------

--Create view of all the 3 tables
 
 create view  crimeData as
 select a.community_area_id, a.name, a.population, a.area_sq_mi, a.density, 
 b.crime_date,b.city_block,b.crime_type,b.crime_description, b.crime_location,b.arrest,b.domestic,  b.latitude, b.longitude
 ,c.temp_high,c.temp_low,c.precipitation  from chicago_weather..c_area a join c_crime b on a.community_area_id=b.community_id 
 join c_temp c on cast(b.crime_date as date)=cast(c.date as date)

  -------------------------------------------------------------------------------------------------------------------------------------------------

 -- How many total crimes were reported in 2021?
 select count(crime_date) total_crime_reported from crimeData

  -------------------------------------------------------------------------------------------------------------------------------------------------

 -- What is the count of Homicide, Battery and Assault reported?

 select crime_type, count(crime_type) total_crimes from crimeData where crime_type in ('Homicide','Battery','Assault') group by crime_type


   -------------------------------------------------------------------------------------------------------------------------------------------------


-- What are the top ten communities that had the most crimes reported?
-- We will also add the current population to see if area density is also a factor.

 select top 10 name, count(name) crime_no, population, density from crimeData  group by name,population,density order by crime_no desc

   -------------------------------------------------------------------------------------------------------------------------------------------------


 -- What are the top ten communities that had the least amount of crimes reported?
-- We will also add the current population to see if area density is also a factor.

 select top 10 name, count(name) crime_no, population, density from crimeData  group by name,population,density order by crime_no 

 -------------------------------------------------------------------------------------------------------------------------------------------------

 -- What month had the most crimes reported?

 select count(*) total_crime, DATENAME(MONTH,crime_date) month_name from crimeData group by DATENAME(MONTH,crime_date) order by total_crime desc

  -------------------------------------------------------------------------------------------------------------------------------------------------

  -- What month had the most homicides and what was the average  temperature?
  select count(*) total_crime, DATENAME(MONTH,crime_date) month_name, crime_type , round(avg((temp_high+temp_low)/2),2) as avg_temp
  from crimeData 
  where crime_type='homicide'
  group by crime_type, DATENAME(MONTH,crime_date)
  order by total_crime desc

    -------------------------------------------------------------------------------------------------------------------------------------------------

  -- What weekday were most crimes committed?
  select  DATENAME(WEEKDAY,crime_date) Day_Name, count(*) total_crime from crimeData group by DATENAME(WEEKDAY,crime_date) order by total_crime desc

    -------------------------------------------------------------------------------------------------------------------------------------------------

  -- What are the top ten city block that have had the most reported crimes?

  select top 10 city_block, count(city_block) crime_no from crimeData  group by city_block  order by crime_no desc
  
  -------------------------------------------------------------------------------------------------------------------------------------------------

-- What are the top ten city block that have had the most homicides?


select top 10 city_block, count(city_block) crime_no from crimeData where crime_type='Homicide' group by city_block  order by crime_no desc


  -------------------------------------------------------------------------------------------------------------------------------------------------


 -- What was the number of reported crimes on the hottest day of the year vs the coldest?

WITH hottest AS (
	SELECT temp_high, count(*) AS n_crimes
	FROM  crimeData
	WHERE	temp_high = (SELECT max(temp_high) FROM crimeData)
	GROUP BY temp_high),
coldest AS (
	SELECT temp_low, count(*) AS n_crimes
	FROM crimeData
	WHERE temp_low = (SELECT min(temp_low) FROM crimeData)
	GROUP BY temp_low)

SELECT	h.temp_high as temp, h.n_crimes FROM 	hottest AS h union
SELECT	c.temp_low,	c.n_crimes FROM 	coldest AS c
	

	  -------------------------------------------------------------------------------------------------------------------------------------------------

	-- What is the number and types of reported crimes on Michigan Ave?	

	select count(*) crimesReported, city_block, crime_type from crimeData where city_block like '%michigan ave%' group by city_block, crime_type order by crimesReported desc


	  -------------------------------------------------------------------------------------------------------------------------------------------------
	 
	 -- What are the top 5 least reported crime, how many arrests were made and the percentage of arrests made?

	 select a.crimeReported, a.crime_type, a.arrested, cast(100 * (arrested / crimeReported) as float) AS arrest_percentage from
	 (select top 5 count(crime_type) crimeReported,sum( case when arrest= 'true' then 1 else 0 end) as arrested,  
	  crime_type from crimeData
	  group by crime_type order by crimeReported) a

	  

	  
	  -- What is the percentage of domestic violence crimes?

    select  100*((select count(*) from crimeData where domestic like '%true%')/ count(*))  domestic_crime from crimeData