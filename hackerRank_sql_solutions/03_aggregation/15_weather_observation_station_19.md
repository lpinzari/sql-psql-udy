# Weather observation station 19

[Problem](https://www.hackerrank.com/challenges/weather-observation-station-19/problem?isFullScreen=true)

Consider P<sub>1</sub>(a,b) and P<sub>2</sub>(c,d) to be two points on a 2D plane where

- (a,b) are the respective minimum and maximum values of Northern Latitude (LAT_N) and

- (c,d)  are the respective minimum and maximum values of Western Longitude (LONG_W) in STATION.

Query the Euclidean Distance between points P<sub>1</sub> and P<sub>2</sub> and format your answer to display `4` decimal digits.

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
SELECT ROUND(SQRT(POWER(MAX(lat_n)-MIN(lat_n),2)+POWER(MAX(long_w)-MIN(long_w),2)),4)
  FROM station;
```
