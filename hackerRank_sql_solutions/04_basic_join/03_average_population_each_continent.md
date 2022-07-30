# Average population of each continent

[Problem](https://www.hackerrank.com/challenges/average-population-of-each-continent/problem?isFullScreen=true)

Given the **CITY** and **COUNTRY** tables, query the names of all the continents (`COUNTRY.Continent`) and their respective `average city populations` (`CITY.Population`) rounded down to the nearest integer.

**Note**: `CITY.CountryCode` and `COUNTRY.Code` are matching key columns.

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
SELECT cy.continent,
       FLOOR(AVG(c.population)) AS avg_pop
  FROM city c
 INNER JOIN country cy ON c.countrycode = cy.code
 GROUP BY cy.continent;
```
