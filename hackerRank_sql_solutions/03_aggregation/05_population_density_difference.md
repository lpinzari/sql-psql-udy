# Population Density Difference

Query the `difference` between the `maximum` and `minimum` populations in **CITY**.

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
SELECT MAX(population) - MIN(population) AS pop_diff
  FROM city;
```
