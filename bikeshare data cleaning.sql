/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
from cyclics

SELECT *
from bikeshare
--Some tables have columns with quotation marks attached to them. we put these tables together and clean the
--quotation marks together

--First we create a new table called Cyclics

CREATE TABLE Cyclics (
    ride_id varchar (250),
    rideable_type varchar (250),
	started_at varchar (250),
	ended_at varchar (250),
	start_station_name varchar (250),
    start_station_id varchar (250),
	end_station_name varchar (250),
	end_station_id varchar (250),
	start_lat varchar (250),
    start_lng varchar (250),
    end_lat varchar (250),
    end_lng varchar (250),
	member_casual varchar (250)
	)

--we write a union statement to put these tables together since theey have the same columns with different values,
--a union statement is preferable

INSERT INTO Cyclics
    SELECT * FROM [cyclic].[dbo].[September22]
    UNION ALL
    SELECT * FROM [cyclic].[dbo].[October22]
    UNION ALL
    SELECT * FROM [cyclic].[dbo].[November22]
    UNION ALL
    SELECT * FROM [cyclic].[dbo].[December22]
    UNION ALL
    SELECT * FROM [cyclic].[dbo].[January23]
    UNION ALL
    SELECT * FROM [cyclic].[dbo].[February23]
    UNION ALL
    SELECT * FROM [cyclic].[dbo].[March23]
    UNION ALL
    SELECT * FROM [cyclic].[dbo].[April23]

----Add new columns where the cleaned string cells are going to be 
ALTER Table Cyclics
  Add RideID Nvarchar (255),
      RideableType Nvarchar (255),
      StartedAt Nvarchar (255),
      EndedAt Nvarchar (255),
      StartstationName Nvarchar (255),
      EndstationName Nvarchar (255),
      StartStationID Nvarchar (255),
      EndStationID Nvarchar (255),
      MemberCasual Nvarchar (255)

 --Remove quotation marks from the columns and put them in the new column
 Update cyclics
    SET RideID  = REPLACE (ride_id, '"', ''),
        RideableType = REPLACE (rideable_type, '"', ''),
       StartedAt  = REPLACE (started_at, '"', ''),
       EndedAt  = REPLACE (ended_at, '"', ''),
       StartstationName  = REPLACE (start_station_name, '"', ''),
       EndstationName  = REPLACE (end_station_name, '"', ''),
       StartstationID  = REPLACE (start_station_id, '"', ''),
       EndstationID  = REPLACE (end_station_id, '"', ''),
       MemberCasual  = REPLACE (member_casual, '"', '')

--Now that the quotation marks have been removed from these tables, we will combine them with the remaining tables

--We will create a new table called 'bikeshare' to combine these tables 
CREATE TABLE bikeshare (
      ride_id varchar (250),
      rideable_type varchar (250),
	  started_at varchar (250),
	  ended_at varchar (250),
	  start_station_name varchar (250),
	  start_station_id varchar (250),
	  end_station_name varchar (250),
	  end_station_id varchar (250),
	  start_lat varchar (250),
	  start_lng varchar (250),
	  end_lat varchar (250),
	  end_lng varchar (250),
	  member_casual varchar (250)
	)

--Now, we will use the union statement to combine the tables and insert them into the new table
INSERT INTO bikeshare
     SELECT RideID, RideableType, StartedAt, EndedAt, StartstationName, StartstationID, EndStationName, EndStationID,
     start_lat, start_lng, end_lat, end_lng,MemberCasual
     FROM [cyclic].[dbo].[May22]
     UNION ALL
     SELECT  RideID, RideableType, StartedAt, EndedAt, StartstationName, StartstationID, EndStationName, EndStationID,
     start_lat, start_lng, end_lat, end_lng,MemberCasual
     FROM [cyclic].[dbo].[June22]
     UNION ALL
     SELECT RideID, RideableType, StartedAt, EndedAt, StartstationName, StartstationID, EndStationName, EndStationID,
     start_lat, start_lng, end_lat, end_lng,MemberCasual
     FROM [cyclic].[dbo].[July22]
     UNION ALL
     SELECT RideID, RideableType, StartedAt, EndedAt, StartstationName, StartstationID, EndStationName, EndStationID,
     start_lat, start_lng, end_lat, end_lng,MemberCasual 
     FROM [cyclic].[dbo].[August22]
     UNION ALL
     SELECT RideID, RideableType, StartedAt, EndedAt, StartstationName, StartstationID, EndStationName, EndStationID,
     start_lat, start_lng, end_lat, end_lng,MemberCasual 
     FROM cyclics

SELECT *
FROM bikeshare

--Convert the  startedat and endedat columns to datetime data format
ALTER Table bikeshare
       Add startedat DATETIME
       Add endedat DATETIME
Update bikeshare
     SET 
     startedat  = CONVERT (DATETIME, started_at, 120),
     endedat  = CONVERT (DATETIME, ended_at, 120)


SELECT 
    startedat,
    endedat,
    DATEDIFF(SECOND, startedat, endedat) / 3600 AS hours,
    (DATEDIFF(SECOND, startedat, endedat) % 3600) / 60 AS minutes,
    DATEDIFF(SECOND, startedat, endedat) % 60 AS seconds, CONCAT ( DATEDIFF(SECOND, startedat, endedat) / 3600 +
	" " + (DATEDIFF(SECOND, startedat, endedat) % 3600) / 60 + " " + DATEDIFF(SECOND, startedat, endedat) % 60) 
FROM bikeshare

--Create a column for duration of trip, find the time difference between trip start time and end time

ALTER Table bikeshare
add duration nvarchar (255)

Update bikeshare
SET 
duration  =   CONCAT(
        DATEDIFF(SECOND, startedat, endedat) / 3600,
        ':',
        (DATEDIFF(SECOND, startedat, endedat) % 3600) / 60,
        ':',
        DATEDIFF(SECOND, startedat, endedat) % 60
		)

		Update bikeshare
		SET trip_duration = CAST (trip_duration AS time)

--Create column for month, season, day and year of trip
alter table bikeshare
		add month varchar (255)

Update bikeshare
		SET month = DATENAME (MONTH, startedat)

alter table bikeshare
		add day varchar (255)

Update bikeshare
		SET day = DATENAME (weekday, startedat)

alter table bikeshare
		add Year varchar (255)

Update bikeshare
		SET Year = DATENAME (year, startedat)
		

alter table bikeshare
		add month_year varchar (255),
		add season varchar (255),
		weekday_weekend varchar (255)

Update bikeshare
		SET month_year = CONCAT (month,',',year), 
	  	season = CASE 
		            when Month IN ('March', 'April', 'May') THEN 'Spring'
					when Month IN ('June', 'July', 'August') THEN 'Summer'
					when Month IN ('September', 'October', 'November') THEN 'Autumn'
					when Month IN ('December', 'January', 'February') THEN 'Winter'
					ELSE 'Unknown'
				END
		,weekday_weekend = CASE 
		                     when Day IN ('Saturday', 'Sunday') THEN 'weekend'
					         ELSE 'weekday'
						 END
ALTER TABLE bikeshare
DROP COLUMN trip_duration

select distinct season
from bikeshare