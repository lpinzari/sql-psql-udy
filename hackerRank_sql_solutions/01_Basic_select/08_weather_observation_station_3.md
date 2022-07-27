# Weather Observation Station 3

[Problem](https://www.hackerrank.com/challenges/weather-observation-station-3/problem?isFullScreen=true)

Query a list of **CITY** names from **STATION** for cities that have an even **ID** number. Print the results in any order, but **exclude duplicates from the answer**.

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
 WHERE MOD(id,2) = 0;
```
