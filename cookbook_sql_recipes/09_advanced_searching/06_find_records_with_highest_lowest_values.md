# Finding Records with the Highest and Lowest Values

You want to find “**extreme**” `values` in your table.

## Problem

For example, you want to find the employees with the `highest` and `lowest` salaries in table `EMP`.

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


The output:

|ename | sal|
|:----:|:---:|
|SMITH |  800|
|KING  | 5000|


## Solution

```SQL
WITH t AS (
  SELECT ename, sal,
         MIN(sal) OVER() AS min_sal,
         MAX(sal) OVER() AS max_sal
    FROM emp
)
SELECT ename, sal
  FROM t
 WHERE sal IN(min_sal, max_sal);
```

- **solution 2**

```SQL
WITH t AS (
  SELECT MIN(sal) AS min_sal,
         MAX(sal) AS max_sal
    FROM emp
)
SELECT ename, sal
  FROM emp
 WHERE sal = (SELECT min_sal FROM t) OR
       sal = (SELECT max_sal FROM t);
```

## Discussion

The window functions `MIN OVER` and `MAX OVER` allow each row to have access to the lowest and highest salaries.

```SQL
SELECT ename, sal,
       MIN(sal) OVER() AS min_sal,
       MAX(sal) OVER() AS max_sal
  FROM emp
 ORDER BY sal;
```

|ename  | sal  | min_sal | max_sal|
|:-----:|:----:|:-------:|:-------:|
|SMITH  |  800 |     800 |    5000|
|JAMES  |  950 |     800 |    5000|
|ADAMS  | 1100 |     800 |    5000|
|WARD   | 1250 |     800 |    5000|
|MARTIN | 1250 |     800 |    5000|
|MILLER | 1300 |     800 |    5000|
|TURNER | 1500 |     800 |    5000|
|ALLEN  | 1600 |     800 |    5000|
|CLARK  | 2450 |     800 |    5000|
|BLAKE  | 2850 |     800 |    5000|
|JONES  | 2975 |     800 |    5000|
|FORD   | 3000 |     800 |    5000|
|SCOTT  | 3000 |     800 |    5000|
|KING   | 5000 |     800 |    5000|

```SQL
WITH t AS (
  SELECT ename, sal,
         MIN(sal) OVER() AS min_sal,
         MAX(sal) OVER() AS max_sal
    FROM emp
)
SELECT ename, sal
  FROM t
 WHERE sal IN(min_sal, max_sal);
```

- **solution 2**

```SQL
WITH t AS (
  SELECT MIN(sal) AS min_sal,
         MAX(sal) AS max_sal
    FROM emp
)
SELECT ename, sal
  FROM emp
 WHERE sal = (SELECT min_sal FROM t) OR
       sal = (SELECT max_sal FROM t);
```
