# Japan cities names

[Problem](https://www.hackerrank.com/challenges/japanese-cities-name/problem?isFullScreen=true)

Query the names of all the Japanese cities in the **CITY** table. The **COUNTRYCODE** for Japan is `JPN`.

The **CITY** table is described as follows:

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
 WHERE countrycode = 'JPN';
```
