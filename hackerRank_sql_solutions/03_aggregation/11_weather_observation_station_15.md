# Weather observation station 15

[Problem](https://www.hackerrank.com/challenges/weather-observation-station-15/problem?isFullScreen=true)

Query the Western Longitude (**LONG_W**) for the `largest Northern Latitude` (**LAT_N**) in **STATION** that is less than`137.2345`.  Round your answer to `4` decimal places.

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
SELECT ROUND(long_w,4)
  FROM station
 WHERE lat_n = (SELECT MAX(lat_n)
                  FROM station
                 WHERE lat_n < 137.2345);
```
