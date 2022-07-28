# Weather observation station 2

[Problem](https://www.hackerrank.com/challenges/weather-observation-station-2/problem?isFullScreen=true)

Query the following two values from the **STATION** table:

- The sum of all values in `LAT_N` rounded to a scale of `2` decimal places.
- The sum of all values in `LONG_W` rounded to a scale of `2` decimal places.

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

## Output Format

Your results must be in the form:

```console
lat lon
```

where  `lat` is the sum of all values in `LAT_N` and `lon` is the sum of all values in `LONG_W`. Both results must be rounded to a scale of `2` decimal places.

## Solution

```SQL
SELECT ROUND(SUM(lat_n),2),ROUND(SUM(long_w),2)
FROM station;
```
