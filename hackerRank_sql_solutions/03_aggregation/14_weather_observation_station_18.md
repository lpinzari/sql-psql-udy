# Weather observation station 18

[Problem](https://www.hackerrank.com/challenges/weather-observation-station-18/problem?isFullScreen=true)

Consider P<sub>1</sub>(a,b)  and P<sub>2</sub>(c,d) to be two points on a 2D plane.

- a: happens to equal the minimum value in Northern Latitude (LAT_N in STATION).
- b: happens to equal the minimum value in Western Longitude (LONG_W in STATION).
- c: happens to equal the maximum value in Northern Latitude (LAT_N in STATION).
- d: happens to equal the maximum value in Western Longitude (LONG_W in STATION).

Query the [Manhattan Distance](https://xlinux.nist.gov/dads/HTML/manhattanDistance.html) between points P<sub>1</sub> and P<sub>2</sub>  and round it to a scale of `4` decimal places.

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
SELECT ROUND(ABS(MIN(lat_n) - MAX(lat_n)) + ABS(MIN(long_w) - MAX(long_w)),4)
  FROM station; 
```
