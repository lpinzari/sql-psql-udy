# Weather observation station 13

[Problem](https://www.hackerrank.com/challenges/weather-observation-station-13/problem?isFullScreen=true)

Query the sum of Northern Latitudes (LAT_N) from STATION having values greater than `38.7880` and less than `137.2345`. Truncate your answer to `2` decimal places.

# Input Format

The **STATION** table is described as follows:

|Field|Type|
|:---:|:--:|
|ID| NUMBER|
|CITY|VARCHAR(21)|
|STATE|VARCHAR(2)|
|LAT_N|NUMBER|
|LONG_W|NUMBER|

where LAT_N is the northern latitude and LONG_W is the western longitude.

## Solution

```SQL
SELECT ROUND(SUM(lat_n),4)
  FROM station
 WHERE lat_n > 38.7880 and lat_n < 137.2345;
```
