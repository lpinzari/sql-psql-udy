# CAST EXAMPLES

## EXERCISE

1. Write a query to look at the top 10 rows to understand the columns and the raw data in the table called `sf_crime_data`:

```SQL
SELECT *
  FROM sf_crime_data
 LIMIT 10;
```

|incidnt_num|category | descript|day_of_week|date| time|pd_district|resolution|address|lon|lat|location|id|
|:---------:|:------------:|:---:|:--:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:--:|
|1.40099416E8|VEHICLE THEFT|STOLEN AND RECOVERED VEHICLE| Friday|01/31/2014 08:00:00 AM +0000| 17:00| INGLESIDE| NONE|0 Block of GARRISON AV|-122.413623946206|37.709725805163|(37.709725805163, -122.413623946206)|	1|
|1.40092426E8|	ASSAULT|	BATTERY|	Friday|	01/31/2014 08:00:00 AM +0000|	17:45|	TARAVAL|	ARREST, CITED	|100 Block of FONT BL|	-122.47370623066|	37.7154876086057|	(37.7154876086057, -122.47370623066)|	2|

2. Change the `date` column format. The format of the date column is `mm/dd/yyyy` with times that are not correct also at the end of the date.

```SQL
SELECT date orig_date,
       (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2))::DATE new_date
FROM sf_crime_data;
```

**Output**

|orig_date|new_date|
|:--------:|:-----:|
|01/31/2014 08:00:00 AM +0000|	2014-01-31T00:00:00.000Z|
|01/31/2014 08:00:00 AM +0000|	2014-01-31T00:00:00.000Z|
