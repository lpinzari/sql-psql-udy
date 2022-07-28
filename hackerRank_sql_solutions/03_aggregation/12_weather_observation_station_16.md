# Weather observation station 16

[Problem](https://www.hackerrank.com/challenges/weather-observation-station-16/problem?isFullScreen=true)

Query the **smallest** Northern Latitude (**LAT_N**) from **STATION** that is greater than `38.7780` . Round your answer to `4` decimal places.

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
SELECT ROUND(MIN(lat_n),4)
  FROM station
 WHERE lat_n > 38.7780;
```
