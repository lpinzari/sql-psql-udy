# Filling in Missing Values in a Range of Values

You want to return the **number of employees hired each year** for the `entire decade` of the  minimum hiring date (i.e. `2006s`), but **there are some years in which no employees were hired**.


## Problem

```SQL
SELECT empno, ename, hiredate
  FROM emp
 ORDER BY hiredate;
```

```console
| empno | ename  |  hiredate|
|:-----:|:------:|:---------:|
|  7499 | ALLEN  | 2006-01-20|
|  7521 | WARD   | 2006-02-22|
|  7566 | JONES  | 2006-04-02|
|  7698 | BLAKE  | 2006-05-01|
|  7782 | CLARK  | 2006-06-09|
|  7844 | TURNER | 2006-09-08|
|  7654 | MARTIN | 2006-09-28|
|  7839 | KING   | 2006-11-17|
|  7902 | FORD   | 2006-12-03|
|  7900 | JAMES  | 2006-12-03| 2006 -> (10 employees)
-----------------------------------
|  7934 | MILLER | 2007-01-23|
|  7788 | SCOTT  | 2007-12-09| 2007 -> (2 employees)
-----------------------------------
|  7876 | ADAMS  | 2008-01-12| 2008 -> (1 employee)
-----------------------------------
|  7369 | SMITH  | 2015-12-17| 2015 -> (1 employee)
-----------------------------------
```

You would like to return the following result set:

|yr  | cnt|
|:---:|:---:|
|2006 |  10|
|2007 |   2|
|2008 |   1|
|2009 |   0|
|2010 |   0|
|2011 |   0|
|2012 |   0|
|2013 |   0|
|2014 |   0|
|2015 |   1|


## Solution

The trick to this solution is returning `zeros` for **years** that `saw no employees hired`.

- If no employee was hired in a given year, then no rows for that year will exist in table `EMP`.
- If the `year` **does not exist in the table**, how can you return a count, any count, even zero?

The solution requires you to **outer join**. You must supply a result set that returns all the years you want to see, and then perform a count against table `EMP` to see if there were any employees hired in each of those years.

```SQL
WITH m_y AS (
  SELECT MIN(EXTRACT ('YEAR' FROM hiredate)) AS min_yr
    FROM emp
), t1 AS (
  SELECT (SELECT min_yr FROM m_y) AS min_year,
         id - 1 AS rn
    FROM GENERATE_SERIES(1,10) id
), t2 AS (
  SELECT min_year + rn AS yr
    FROM t1
), t3 AS (
  SELECT EXTRACT('YEAR' FROM hiredate) AS yr,
         COUNT(*) AS cnt
    FROM emp
   GROUP BY yr
)
SELECT t2.yr,
       COALESCE(t3.cnt,0) AS cnt
  FROM t2
  LEFT JOIN t3
  ON t2.yr = t3.yr;
```


## Discussion


```SQL
SELECT MIN(EXTRACT ('YEAR' FROM hiredate)) AS min_yr
  FROM emp;
```

|min_yr|
|:------:|
|  2006|


```SQL
SELECT GENERATE_SERIES(1,10) id;
```

|id|
|:-:|
| 1|
| 2|
| 3|
| 4|
| 5|
| 6|
| 7|
| 8|
| 9|
|10|

```SQL
WITH m_y AS (
  SELECT MIN(EXTRACT ('YEAR' FROM hiredate)) AS min_yr
    FROM emp
)
SELECT (SELECT min_yr FROM m_y) AS min_year,
       id - 1 AS rn
  FROM GENERATE_SERIES(1,10) id;
```

|min_year | rn|
|:-------:|:--:|
|    2006 |  0|
|    2006 |  1|
|    2006 |  2|
|    2006 |  3|
|    2006 |  4|
|    2006 |  5|
|    2006 |  6|
|    2006 |  7|
|    2006 |  8|
|    2006 |  9|

```SQL
WITH m_y AS (
  SELECT MIN(EXTRACT ('YEAR' FROM hiredate)) AS min_yr
    FROM emp
), t1 AS (
  SELECT (SELECT min_yr FROM m_y) AS min_year,
         id - 1 AS rn
    FROM GENERATE_SERIES(1,10) id
)
SELECT min_year,
       rn,
       min_year + rn AS yr
  FROM t1;
```

|min_year | rn |  yr|
|:-------:|:--:|:---:|
|    2006 |  0 | 2006|
|    2006 |  1 | 2007|
|    2006 |  2 | 2008|
|    2006 |  3 | 2009|
|    2006 |  4 | 2010|
|    2006 |  5 | 2011|
|    2006 |  6 | 2012|
|    2006 |  7 | 2013|
|    2006 |  8 | 2014|
|    2006 |  9 | 2015|

```SQL
SELECT EXTRACT('YEAR' FROM hiredate) AS year,
       COUNT(*) AS cnt
  FROM emp
 GROUP BY year;
```

|year | cnt|
|:---:|:---:|
|2007 |   2|
|2006 |  10|
|2008 |   1|
|2015 |   1|

```SQL
WITH m_y AS (
  SELECT MIN(EXTRACT ('YEAR' FROM hiredate)) AS min_yr
    FROM emp
), t1 AS (
  SELECT (SELECT min_yr FROM m_y) AS min_year,
         id - 1 AS rn
    FROM GENERATE_SERIES(1,10) id
), t2 AS (
  SELECT min_year + rn AS yr
    FROM t1
), t3 AS (
  SELECT EXTRACT('YEAR' FROM hiredate) AS yr,
         COUNT(*) AS cnt
    FROM emp
   GROUP BY yr
)
SELECT t2.yr,
       COALESCE(t3.cnt,0) AS cnt
  FROM t2
  LEFT JOIN t3
  ON t2.yr = t3.yr;
```

|yr  | cnt|
|:---:|:---:|
|2006 |  10|
|2007 |   2|
|2008 |   1|
|2009 |   0|
|2010 |   0|
|2011 |   0|
|2012 |   0|
|2013 |   0|
|2014 |   0|
|2015 |   1|
