# Population Census

[Problem](https://www.hackerrank.com/challenges/asian-population/problem?isFullScreen=true)

Given the **CITY** and **COUNTRY** tables, query the `sum` of the populations of all cities where the **CONTINENT** is `Asia`.

Note: `CITY.CountryCode` and `COUNTRY.Code` are matching key columns.

## Input Format

The **CITY** and **COUNTRY** tables are described as follows:

**CITY**

|Field|Type|
|:---:|:--:|
|ID|NUMBER|
|NAME|VARCHAR2(17)|
|COUNTRYCODE|VARCHAR2(3)|
|DISTRICT|VARCHAR2(20)|
|POPULATION|NUMBER|

**COUNTRY**

|Field|Type|
|:---:|:--:|
| CODE    | VARCHAR2()   |
| NAME    |  VARCHAR2()  |
|  CONTINENT   |  VARCHAR2()  |
|  REGION   |  VARCHAR2()  |
|  SURFACEAREA   |  NUMBER  |
|  INDEPYEAR   |  VARCHAR2()  |
|  POPULATION   |  NUMBER  |
| LIFEEXPECTANCY    |  VARCHAR2()  |
| GNP    |   NUMBER |
| GNPOLD    |  VARCHAR2()  |
| LOCALNAME    |  VARCHAR2()  |
| GOVERNMENTFORM    | VARCHAR2()   |
| HEADOFSTATE    |  VARCHAR2()  |
| CAPITAL    |  VARCHAR2()  |
| CODE2    |  VARCHAR2()  |


## Solution

```SQL
SELECT SUM(city.population)
  FROM country
  LEFT JOIN city ON country.code = city.countrycode
 WHERE country.continent = 'Asia';
```
