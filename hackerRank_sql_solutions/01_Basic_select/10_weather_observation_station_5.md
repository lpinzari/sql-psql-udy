# Weather Observation Station 5

[Problem](https://www.hackerrank.com/challenges/weather-observation-station-5/problem?isFullScreen=true)

Query the two cities in **STATION** with the shortest and longest **CITY** names, as well as their respective lengths (i.e.: number of characters in the name). If there is more than one smallest or largest city, choose the one that comes first when ordered alphabetically.

The **STATION** table is described as follows:

|Field|Type|
|:---:|:--:|
|ID| NUMBER|
|CITY|VARCHAR(21)|
|STATE|VARCHAR(2)|
|LAT_N|NUMBER|
|LONG_W|NUMBER|

where LAT_N is the northern latitude and LONG_W is the western longitude.

## Sample Input

For example, CITY has four entries: `DEF`, `ABC`, `PQRS` and `WXY`.

## Sample Output

```console
ABC 3
PQRS 4
```

## Explanation

When ordered alphabetically, the CITY names are listed as `ABC`, `DEF`, `PQRS`, and `WXY`, with lengths `3,3,4` and `3`. The longest name is `PQRS`, but there are `3` options for shortest named city. Choose `ABC`, because it comes first alphabetically.

## Note
You can write two separate queries to get the desired output. It need not be a single query.

[order by tutorial](https://github.com/lpinzari/sql-psql-udy/blob/master/01_basic_sql/10_order_by.md)
[length function](https://github.com/lpinzari/sql-psql-udy/blob/master/06_string_functions/08_length.md)

```SQL
SELECT city,LENGTH(city)
  FROM station
 ORDER BY 2 ASC,1 ASC LIMIT 1;
SELECT city,LENGTH(city)
  FROM station
 ORDER BY 2 DESC,1 ASC LIMIT 1;
```
