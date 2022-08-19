# Selecting the Top n Records

You want to `limit` a result set to a **specific number of records based on a ranking of some sort**.

## Problem

For example, you want to return the `names` and `salaries` of the employees with the `top five` **salaries**.

```SQL
SELECT ename, sal
  FROM emp
 ORDER BY sal DESC;
```

|ename  | sal|
|:-----:|:---:|
|KING   | 5000|
|FORD   | 3000|
|SCOTT  | 3000|
|JONES  | 2975|
|BLAKE  | 2850|
|CLARK  | 2450|
|ALLEN  | 1600|
|TURNER | 1500|
|MILLER | 1300|
|MARTIN | 1250|
|WARD   | 1250|
|ADAMS  | 1100|
|JAMES  |  950|
|SMITH  |  800|

The output is:

|ename | sal|
|:----:|:---:|
|KING  | 5000|
|FORD  | 3000|
|SCOTT | 3000|
|JONES | 2975|
|BLAKE | 2850|
|CLARK | 2450|


## Solution

The solution to this problem depends on the use of a window function. Which window function you will use **depends on how you want to deal with ties**. The following solution uses `DENSE_RANK` so that each tie in salary will count as only one against the total:

```SQL
WITH t AS (
  SELECT ename, sal,
         DENSE_RANK() OVER(ORDER BY sal DESC) AS dr
    FROM emp
)
SELECT ename, sal
  FROM t
 WHERE dr <= 5;
```

## Discussion

The window function `DENSE_RANK OVER` does all the work. The following example shows the entire table after applying that function:

```SQL
SELECT ename, sal,
       DENSE_RANK() OVER(ORDER BY sal DESC) AS dr
  FROM emp;
```

|ename  | sal  | dr|
|:-----:|:----:|:--:|
|KING   | 5000 |  1|
|FORD   | 3000 |  2|
|SCOTT  | 3000 |  2|
|JONES  | 2975 |  3|
|BLAKE  | 2850 |  4|
|CLARK  | 2450 |  5|
|ALLEN  | 1600 |  6|
|TURNER | 1500 |  7|
|MILLER | 1300 |  8|
|MARTIN | 1250 |  9|
|WARD   | 1250 |  9|
|ADAMS  | 1100 | 10|
|JAMES  |  950 | 11|
|SMITH  |  800 | 12|

Now it’s just a matter of returning rows where DR is less than or equal to five.

```SQL
WITH t AS (
  SELECT ename, sal,
         DENSE_RANK() OVER(ORDER BY sal DESC) AS dr
    FROM emp
)
SELECT *
  FROM t
 WHERE dr <= 5;
```

|ename | sal  | dr|
|:----:|:----:|:-:|
|KING  | 5000 |  1|
|FORD  | 3000 |  2|
|SCOTT | 3000 |  2|
|JONES | 2975 |  3|
|BLAKE | 2850 |  4|
|CLARK | 2450 |  5|
