# Weather Observation Station 1

[Problem](https://www.hackerrank.com/challenges/weather-observation-station-1/problem?isFullScreen=true)

Query a list of **CITY** and **STATE** from the **STATION** table.

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
SELECT city, state
  FROM station;
```
