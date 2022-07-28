# Japan Population

[Problem](https://www.hackerrank.com/challenges/japan-population/problem?isFullScreen=true)

Query the sum of the populations for `all Japanese cities` in **CITY**. The **COUNTRYCODE** for Japan is `JPN`.


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
SELECT SUM(population) AS tot_pop
  FROM city
 WHERE countrycode = 'JPN';
```
