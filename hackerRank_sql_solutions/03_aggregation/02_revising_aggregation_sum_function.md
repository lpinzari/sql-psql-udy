# Revising Aggregation - The Sum function

[Problem](https://www.hackerrank.com/challenges/revising-aggregations-sum/problem?isFullScreen=true)

Query the total population of all cities in **CITY** where District is California.

## Input Format

The **CITY** table is described as follows:

|Field|Type|
|:---:|:---:|
|ID|NUMBER||
|NAME|VARCHAR(17)|
|COUNTRYCODE|VARCHAR(3)|
|DISTRICT|VARCHAR2(20)|
|POPULATION|NUMBER|

## Solution

```SQL
SELECT SUM(population) AS total_population
  FROM city
 WHERE district = 'California';
```
