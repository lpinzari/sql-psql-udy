# Weather Observation Station 4

[Problem](https://www.hackerrank.com/challenges/weather-observation-station-4/problem?isFullScreen=true)

Find the difference between the total number of **CITY** entries in the table and the number of distinct **CITY** entries in the table.

The **STATION** table is described as follows:

|Field|Type|
|:---:|:--:|
|ID| NUMBER|
|CITY|VARCHAR(21)|
|STATE|VARCHAR(2)|
|LAT_N|NUMBER|
|LONG_W|NUMBER|

where LAT_N is the northern latitude and LONG_W is the western longitude.

For example, if there are three records in the table with **CITY** values 'New York', 'New York', 'Bengalaru', there are 2 different city names: 'New York' and 'Bengalaru'. The query returns , because

```console
total number of records - number of unique city names = 3 - 2 = 1
```

[count lesson](https://github.com/lpinzari/sql-psql-udy/blob/master/04_sql_aggregations/08_count.md)

```SQL
SELECT COUNT(city) - COUNT(DISTINCT(city))
  FROM station;
```
