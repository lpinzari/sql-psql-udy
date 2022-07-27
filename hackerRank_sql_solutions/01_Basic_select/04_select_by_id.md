# SELECT BY ID

[Problem](https://www.hackerrank.com/challenges/select-by-id/problem?isFullScreen=true)

Query all columns for a city in CITY with the ID 1661.

The CITY table is described as follows:

|Field|Type|
|:---:|:--:|
|ID|NUMBER|
|NAME|VARCHAR2(17)|
|COUNTRYCODE|VARCHAR(3)|
|DISTRICT|VARCHAR2(20)|
|POPULATION|NUMBER|

```SQL
SELECT *
  FROM city
 WHERE id = 1661;
```
