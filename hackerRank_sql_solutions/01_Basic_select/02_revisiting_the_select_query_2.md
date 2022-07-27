# Revisiting the Select Query 2

[Problem](https://www.hackerrank.com/challenges/revising-the-select-query-2/problem?isFullScreen=true)
Query the NAME field for all American cities in the CITY table with populations larger than 120000. The CountryCode for America is USA.

The CITY table is described as follows:

|Field|Type|
|:---:|:--:|
|ID|NUMBER|
|NAME|VARCHAR2(17)|
|COUNTRYCODE|VARCHAR(3)|
|DISTRICT|VARCHAR2(20)|
|POPULATION|NUMBER|

```SQL
SELECT name
  FROM city
 WHERE population > 120000 AND
       countrycode = 'USA';
```
