# Revising Aggregation - The Count function

[Problem](https://www.hackerrank.com/challenges/revising-aggregations-the-count-function/problem?isFullScreen=true)

Query a count of the number of cities in CITY having a Population larger than 100,000.

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
SELECT COUNT(*)
  FROM city
 WHERE population > 100000;
```
