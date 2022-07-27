# Weather Observation Station 6

[Problem](https://www.hackerrank.com/challenges/weather-observation-station-6/problem?isFullScreen=true)

Query the list of **CITY** names starting with vowels (i.e., `a`, `e`, `i`, `o`, or `u`) from **STATION**. Your `result cannot contain duplicates`.

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

- [Lower tutorial](https://github.com/lpinzari/sql-psql-udy/blob/master/06_string_functions/09_lower.md)
- [left tutorial](https://github.com/lpinzari/sql-psql-udy/blob/master/06_string_functions/07_left.md)
- [in tutorial](https://github.com/lpinzari/sql-psql-udy/blob/master/01_basic_sql/16_in_not_in.md)

```SQL
SELECT DISTINCT city
  FROM station
 WHERE LOWER(LEFT(city,1)) IN ('a','e','i','o','u');
```
