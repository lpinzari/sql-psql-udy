# Finding the Min/Max Value in a Column

You want to find the **highest** and **lowest** `values in a given column`.

## Problem

For example, you want to find the **highest** and **lowest** `salaries` **for all** `employees`, as well as the **highest** and **lowest** `salaries` **for each** `department`.

## Solution

When searching for the **lowest** and **highest** `salaries` **for all** employees, simply use the functions [MIN](https://github.com/lpinzari/sql-psql-udy/blob/master/04_sql_aggregations/04_min.md) and [MAX](https://github.com/lpinzari/sql-psql-udy/blob/master/04_sql_aggregations/02_max.md), respectively:

```SQL
SELECT ROUND(MIN(sal),2) AS min_sal,
       ROUND(MAX(sal),2) AS max_sal
  FROM emp;
```

|min_sal | max_sal|
|:------:|:------:|
| 800.00 | 5000.00|

When searching for the **lowest** and **highest** `salaries` **for each** `department`, use the functions `MIN` and `MAX` with the `GROUP BY` clause:

```SQL
SELECT deptno,
       ROUND(MIN(sal),2) AS min_sal,
       ROUND(MAX(sal),2) AS max_sal
  FROM emp
 GROUP BY deptno
 ORDER BY deptno;
```

|deptno | min_sal | max_sal|
|:-----:|:-------:|:------:|
|    10 | 1300.00 | 5000.00|
|    20 |  800.00 | 3000.00|
|    30 |  950.00 | 2850.00|

## Discussion

When searching for the **highest** or **lowest** values, and in cases `where the whole table is the group or window`, simply apply the `MIN` or `MAX` function to **the column you are interested in** without using the GROUP BY clause.

Remember that the `MIN` and `MAX` functions **ignore NULLs**, and that you can have `NULL` groups as well as `NULL` values for columns in a group. The following are examples that ultimately lead to a query using `GROUP BY` that returns NULL values for two groups (**DEPTNO** `10` and `20`):

```SQL
SELECT deptno, comm
  FROM emp
 WHERE deptno IN (10,30)
 ORDER BY 1;
```

|deptno | comm|
|:-----:|:----:|
|    10 | NULL|
|    10 | NULL|
|    10 | NULL|
|    30 | NULL|
|    30 | NULL|
|    30 |  300|
|    30 |    0|
|    30 |  500|
|    30 | 1400|

```SQL
SELECT MIN(comm) AS min_com,
       MAX(comm) AS max_com
  FROM emp;
```

|min_com | max_com|
|:------:|:------:|
|      0 |    1400|

```SQL
SELECT deptno,
       MIN(comm) AS min_com,
       MAX(comm) AS max_com
  FROM emp
 GROUP BY deptno
 ORDER BY deptno;
```

|deptno | min_com | max_com|
|:-----:|:-------:|:-------:|
|    10 |    NULL |    NULL|
|    20 |    NULL |    NULL|
|    30 |       0 |    1400|

```SQL
SELECT deptno,
       MIN(COALESCE(comm,0)) AS min_com,
       MAX(COALESCE(comm,0)) AS max_com
  FROM emp
 GROUP BY deptno
 ORDER BY deptno;
```

|deptno | min_com | max_com|
|:-----:|:-------:|:------:|
|    10 |       0 |       0|
|    20 |       0 |       0|
|    30 |       0 |    1400|

```SQL
SELECT MIN(COALESCE(comm,0)) AS min_com,
       MAX(COALESCE(comm,0)) AS max_com
  FROM emp
 GROUP BY deptno
 ORDER BY min_com, max_com;
```

|min_com | max_com|
|:------:|:------:|
|      0 |       0|
|      0 |       0|
|      0 |    1400|

Here you are still grouping by `DEPTNO` even though it is not in the `SELECT` clause. Including the column you are grouping by in the `SELECT` clause often improves readability, but **is not mandatory**.

```console
cookbook=> SELECT job
cookbook->        MIN(COALESCE(comm,0)) AS min_com,
cookbook->        MAX(COALESCE(comm,0)) AS max_com
cookbook->   FROM emp
cookbook->  GROUP BY deptno
cookbook->  ORDER BY min_com, max_com;
ERROR:  syntax error at or near "("
LINE 2:        MIN(COALESCE(comm,0)) AS min_com,
                  ^ 
```

**It is mandatory**, however, **that any column in** the `SELECT` **list** of a `GROUP BY` query **also be listed in the** `GROUP BY` clause.
