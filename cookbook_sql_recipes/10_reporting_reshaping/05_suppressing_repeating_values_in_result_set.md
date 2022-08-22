# Suppressing Repeating Values from a Result Set

You are `generating a report`, and when **two rows have the same value in a column**, you want to `display that value only once`.

## Problem

```SQL
SELECT deptno, ename
  FROM emp
 ORDER BY deptno;
```

```console
deptno | ename
--------+--------
    10 | MILLER
    10 | CLARK
    10 | KING
    20 | SCOTT
    20 | JONES
    20 | SMITH
    20 | ADAMS
    20 | FORD
    30 | WARD
    30 | TURNER
    30 | ALLEN
    30 | BLAKE
    30 | MARTIN
    30 | JAMES
```

For example, you want to return `DEPTNO` and `ENAME` from table `EMP`, you want to group all rows for each `DEPTNO`, and you want to display each `DEPTNO` **only one time**.


You want to return the following result set:

```console
deptno | ename
--------+--------
    10 | MILLER
       | CLARK
       | KING
    20 | SCOTT
       | JONES
       | SMITH
       | ADAMS
       | FORD
    30 | WARD
       | TURNER
       | ALLEN
       | BLAKE
       | MARTIN
       | JAMES
```

## Solution

```SQL
SELECT CASE WHEN LAG(deptno) OVER(ORDER BY deptno) = deptno
            THEN NULL ELSE deptno
       END AS deptno,
       ename
  FROM emp;
```


## Discussion

The first step is to use the window function LAG OVER to return the prior DEPTNO for each row:

```SQL
SELECT LAG(deptno) OVER(ORDER BY deptno) AS prev_deptno,
       deptno, ename    
  FROM emp;
```


```console
      |prev_deptno | deptno | ename|
      |:----------:|:------:|:-----:|
10    |            |     10 | MILLER|
NULL  |         10 |     10 | CLARK|
NULL  |         10 |     10 | KING|
20    |         10 |     20 | SCOTT|
NULL  |         20 |     20 | JONES|
NULL  |         20 |     20 | SMITH|
NULL  |         20 |     20 | ADAMS|
NULL  |         20 |     20 | FORD|
NULL  |         20 |     30 | WARD|
30    |         30 |     30 | TURNER|
NULL  |         30 |     30 | ALLEN|
NULL  |         30 |     30 | BLAKE|
NULL  |         30 |     30 | MARTIN|
NULL  |         30 |     30 | JAMES|
```

If you inspect the previous result set, you can easily see where `DEPTNO` **matches** `PREV_ DEPTNO`. For those rows, you want to set `DEPTNO` to **NULL**.

```SQL
SELECT CASE WHEN LAG(deptno) OVER(ORDER BY deptno) = deptno
            THEN NULL ELSE deptno
       END AS deptno,
       ename
  FROM emp;
```

```console
deptno | ename
--------+--------
    10 | MILLER
       | CLARK
       | KING
    20 | SCOTT
       | JONES
       | SMITH
       | ADAMS
       | FORD
    30 | WARD
       | TURNER
       | ALLEN
       | BLAKE
       | MARTIN
       | JAMES
```
