# Weather Observation Station 7

[Problem](https://www.hackerrank.com/challenges/weather-observation-station-7/problem?isFullScreen=true)

Query the list of **CITY** names `ending` with vowels (`a`, `e`, `i`, `o`, `u`) from **STATION**. Your result **cannot contain duplicates**.

## Input Format

The **STATION** table is described as follows:

|Field|Type|
|:---:|:--:|
|ID| NUMBER|
|CITY|VARCHAR(21)|
|STATE|VARCHAR(2)|
|LAT_N|NUMBER|
|LONG_W|NUMBER|

where LAT_N is the northern latitude and LONG_W is the western longitude.

```SQL
SELECT DISTINCT city
  FROM station
 WHERE LOWER(RIGHT(city,1)) IN ('a','e','i','o','u');
```
