# Revising Aggregation - The Average function

[Problem](https://www.hackerrank.com/challenges/revising-aggregations-the-average-function/problem?isFullScreen=true)

Query the average population of all cities in **CITY** where District is California.


## Input Format

The **CITY** table is described as follows:

|Field|Type|
|:---:|:---:|
|ID|NUMBER||
|NAME|VARCHAR(17)|
|COUNTRYCODE|VARCHAR(3)|
|DISTRICT|VARCHAR2(20)|
|POPULATION|NUMBER|

[FLOOR](https://www.w3resource.com/PostgreSQL/floor-function.php#:~:text=The%20PostgreSQL%20floor()%20function,as%20smaller%20than%20the%20argument.)

## Solution

```SQL
SELECT FLOOR(AVG(population)) AS pop_avg
  FROM city;
```
