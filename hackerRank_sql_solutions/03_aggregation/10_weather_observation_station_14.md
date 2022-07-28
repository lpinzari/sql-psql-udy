# Weather observation station 14

[Problem](https://www.hackerrank.com/challenges/weather-observation-station-14/problem?isFullScreen=true)

Query the greatest value of the Northern Latitudes (LAT_N) from STATION that is less than `137.2345`. Truncate your answer to `4` decimal places.

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
SELECT ROUND(MAX(lat_n),4)
  FROM station
 WHERE lat_n < 137.2345;
```
