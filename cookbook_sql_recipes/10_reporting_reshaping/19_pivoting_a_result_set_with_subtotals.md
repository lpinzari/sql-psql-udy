# Pivoting a Result Set with Subtotals

You want to
- create a `report` containing **subtotals** and
- then `transpose` **the results** to provide a more readable report.


## Problem

```SQL
SELECT deptno, empno, ename, mgr, sal
  FROM emp
 ORDER BY deptno, mgr;
```

```console
deptno | empno | ename  | mgr  | sal
--------+-------+--------+------+------                    KING      |   KING 2450
    10 |  7934 | MILLER | 7782 | 1300               CLARK ---| (2450)|  CLARK 1300
    10 |  7782 | CLARK  | 7839 | 2450        MILLER ---| (1300)      |        3750
    10 |  7839 | KING   |      | 5000
    -----------------------------------
    20 |  7788 | SCOTT  | 7566 | 3000               KING            |  KING  2975
    20 |  7902 | FORD   | 7566 | 3000               JONES (2975)      JONES  6000
    20 |  7876 | ADAMS  | 7788 | 1100              ---|---             SCOTT 1100  
    20 |  7566 | JONES  | 7839 | 2975     (3000) SCOTT   FORD (3000)     FROD 800
    20 |  7369 | SMITH  | 7902 |  800     (1100) ADAMS   SMITH (800)        10875
    -----------------------------------
    30 |  7900 | JAMES  | 7698 |  950
    30 |  7499 | ALLEN  | 7698 | 1600
    30 |  7654 | MARTIN | 7698 | 1250
    30 |  7521 | WARD   | 7698 | 1250
    30 |  7844 | TURNER | 7698 | 1500
    30 |  7698 | BLAKE  | 7839 | 2850
```

For example, you’ve been asked to create a report that displays for **each department**,
- the `managers` in the department, and a
- `sum of the salaries` of the **employees who work for those managers**.

Additionally, you want to return two subtotals:
- the `sum of all salaries` in each department for those `employees` **who have managers**,
- and a `sum of all salaries` in the result set (the sum of the department subtotals).

You currently have the following report:

|deptno | mgr  |  sal|
|:-----:|:----:|:----:|
|    10 | 7782 |  1300|
|    10 | 7839 |  2450|
|    10 |      |  3750|
|    20 | 7566 |  6000|
|    20 | 7788 |  1100|
|    20 | 7839 |  2975|
|    20 | 7902 |   800|
|    20 |      | 10875|
|    30 | 7698 |  6550|
|    30 | 7839 |  2850|
|    30 |      |  9400|
|       |      | 24025|

You want to provide a more readable report and want to transform the previous result set to the following, which makes the meaning of the report much clearer:

|mgr  | deptno_10 | deptno_20 | deptno_30 | total|
|:---:|:---------:|:---------:|:---------:|:----:|
|7566 |         0 |      6000 |         0 ||
|7698 |         0 |         0 |      6550 ||
|7782 |      1300 |         0 |         0 ||
|7788 |         0 |      1100 |         0 ||
|7839 |      2450 |      2975 |      2850 ||
|7902 |         0 |       800 |         0 ||
|     |      3750 |     10875 |      9400 | 24025|

## Solution

The first step is to generate subtotals using the `ROLLUP` extension to `GROUP BY`. The next step is to perform a classic pivot (aggregate and CASE expression) to create the desired columns for your report. The `GROUPING` function allows you to easily determine which values are subtotals (that is, exist because of `ROLLUP` and otherwise would not normally be there). Depending on how your RDBMS sorts NULL values, you may need to add an ORDER BY to the solution to allow it to look like the previous target result set.


```SQL
WITH x AS (
  SELECT deptno, mgr,
         SUM(sal) AS sal,
         GROUPING(deptno)::CHAR(1) || GROUPING(mgr)::CHAR(1) AS flag
    FROM emp
   WHERE mgr IS NOT NULL
   GROUP BY ROLLUP(deptno, mgr)
)
SELECT mgr,
       SUM(CASE deptno WHEN 10 THEN sal ELSE 0 END) AS deptno_10,
       SUM(CASE deptno WHEN 20 THEN sal ELSE 0 END) AS deptno_20,
       SUM(CASE deptno WHEN 30 THEN sal ELSE 0 END) AS deptno_30,
       SUM(CASE flag WHEN '11' THEN sal ELSE NULL END) AS total
  FROM x
 GROUP BY mgr
 ORDER BY COALESCE(mgr,9999);
```


## Discussion

The first step is to generate a result set that sums the `SAL` for the employees in each `DEPTNO` **per** `MGR`. The idea is to show how much the employees make under a particular manager in a particular department.

```SQL
SELECT deptno, mgr,
       SUM(sal) AS sal
  FROM emp
 WHERE mgr IS NOT NULL
 GROUP BY 1,2
 ORDER BY 1,2;
```

|deptno | mgr  | sal|
|:-----:|:-----:|:---:|
|    10 | 7782 | 1300|
|    10 | 7839 | 2450|
|    20 | 7566 | 6000|
|    20 | 7788 | 1100|
|    20 | 7839 | 2975|
|    20 | 7902 |  800|
|    30 | 7698 | 6550|
|    30 | 7839 | 2850|

The next step is to use the `ROLLUP` extension to `GROUP BY` to create subtotals for each `DEPTNO` and across all employees (who have a manager):

```SQL
SELECT deptno, mgr,
       SUM(sal) AS sal
  FROM emp
 WHERE mgr IS NOT NULL
 GROUP BY ROLLUP(deptno, mgr)
 ORDER BY 1,2;
```

```console
deptno | mgr  |  sal
--------+------+-------
    10 | 7782 |  1300
    10 | 7839 |  2450
              -------
    10 |      |  3750
    -----------------
    20 | 7566 |  6000
    20 | 7788 |  1100
    20 | 7839 |  2975
    20 | 7902 |   800
              -------
    20 |      | 10875
    -----------------
    30 | 7698 |  6550
    30 | 7839 |  2850
    30 |      |  9400
              -------
       |      | 24025
```

With the subtotals created, you need a way to determine which values are in fact sub‐ totals (created by `ROLLUP`) and which are results of the regular `GROUP BY`. Use the `GROUPING` function to **create bitmaps** to help `identify the subtotal values` from the regular aggregate values:

```SQL
SELECT deptno, mgr,
       SUM(sal) AS sal,
       GROUPING(deptno)::CHAR(1) || GROUPING(mgr)::CHAR(1) AS flag
  FROM emp
 WHERE mgr IS NOT NULL
 GROUP BY ROLLUP(deptno, mgr)
 ORDER BY 1,2;
```

```console
deptno | mgr  |  sal  | flag
--------+------+-------+------
    10 | 7782 |  1300 | 00
    10 | 7839 |  2450 | 00
    10 |      |  3750 | 01
    ----------------------
    20 | 7566 |  6000 | 00
    20 | 7788 |  1100 | 00
    20 | 7839 |  2975 | 00
    20 | 7902 |   800 | 00
    20 |      | 10875 | 01
    ----------------------
    30 | 7698 |  6550 | 00
    30 | 7839 |  2850 | 00
    30 |      |  9400 | 01
       |      | 24025 | 11
```

If it isn’t immediately obvious, the rows with a value of `00` for FLAG are the results of **regular aggregation**. The rows with a value of `01` for FLAG are the results of `ROLLUP` aggregating SAL by `DEPTNO` (since DEPTNO is listed first in the ROLLUP; if you switch the order, for example, GROUP BY MGR, DEPTNO WITH ROLLUP, you’d see quite different results). The row with a value of `11` for FLAG is the result of `ROLLUP` aggregating `SAL over all rows`.


At this point you have everything you need to create a beautified report by simply using `CASE` expressions. The goal is to provide a report that shows employee salaries for each manager across departments. If a manager does not have any subordinates in a particular department, a zero should be returned; otherwise, you want to return the sum of all salaries for that manager’s subordinates in that department. Additionally, you want to add a final column, `TOTAL`, representing a sum of all the salaries in the report. The solution satisfying all these requirements is shown here:


```SQL
WITH x AS (
  SELECT deptno, mgr,
         SUM(sal) AS sal,
         GROUPING(deptno)::CHAR(1) || GROUPING(mgr)::CHAR(1) AS flag
    FROM emp
   WHERE mgr IS NOT NULL
   GROUP BY ROLLUP(deptno, mgr)
)
SELECT mgr,
       SUM(CASE deptno WHEN 10 THEN sal ELSE 0 END) AS deptno_10,
       SUM(CASE deptno WHEN 20 THEN sal ELSE 0 END) AS deptno_20,
       SUM(CASE deptno WHEN 30 THEN sal ELSE 0 END) AS deptno_30,
       SUM(CASE flag WHEN '11' THEN sal ELSE NULL END) AS total
  FROM x
 GROUP BY mgr
 ORDER BY COALESCE(mgr,9999);
```

|mgr  | deptno_10 | deptno_20 | deptno_30 | total|
|:---:|:---------:|:---------:|:---------:|:----:|
|7566 |         0 |      6000 |         0 ||
|7698 |         0 |         0 |      6550 ||
|7782 |      1300 |         0 |         0 ||
|7788 |         0 |      1100 |         0 ||
|7839 |      2450 |      2975 |      2850 ||
|7902 |         0 |       800 |         0 ||
|     |      3750 |     10875 |      9400 | 24025|
