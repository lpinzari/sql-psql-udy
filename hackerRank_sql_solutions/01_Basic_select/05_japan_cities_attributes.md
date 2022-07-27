# Japan cities Attributes

[Problem](https://www.hackerrank.com/challenges/japanese-cities-attributes/problem?isFullScreen=true)

Query all attributes of every Japanese city in the **CITY** table. The **COUNTRYCODE** for Japan is `JPN`.

The **CITY** table is described as follows:

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
 WHERE countrycode = 'JPN';
```
