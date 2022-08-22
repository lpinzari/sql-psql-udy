# Creating Vertical Histograms

You want to generate a `histogram` **that grows from the bottom up**.

## Problem

For example, you want to display the number of employees in each department as a vertical histogram with each employee represented by an instance of `*`.

```SQL
SELECT deptno,
       COUNT(*) AS cnt
  FROM emp
 GROUP BY deptno
 ORDER BY deptno;
```

|deptno | cnt|
|;-----:|:--:|
|    10 |   3|
|    20 |   5|
|    30 |   6|


You want to return the following result set:

```console
 d10 | d20 | d30
-----+-----+-----
    |     | *
    | *   | *
    | *   | *
*   | *   | *
*   | *   | *
*   | *   | *
```

## Solution

The technique used to solve this problem is built on a technique used earlier in this chapter: use the `ROW_NUMBER OVER` function to uniquely identify each instance of `*` for each `DEPTNO`. Use the aggregate function `MAX` to pivot the result set and group by the values returned by `ROW_NUMBER OVER`:

```SQL
WITH x AS (
  SELECT ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY empno) AS rn,
         CASE WHEN deptno = 10 THEN '*' ELSE NULL END AS deptno_10,
         CASE WHEN deptno = 20 THEN '*' ELSE NULL END AS deptno_20,
         CASE WHEN deptno = 30 THEN '*' ELSE NULL END AS deptno_30
    FROM emp
)
SELECT MAX(deptno_10) AS d10,
       MAX(deptno_20) AS d20,
       MAX(deptno_30) AS d30
  FROM x
 GROUP BY rn
 ORDER BY 1 DESC, 2 DESC, 3 DESC;
```

## Discussion

The first step is to use the window function `ROW_NUMBER` to uniquely identify each instance of `*` in each department. Use a `CASE` expression to return a `*` for each employee in each department:

```SQL
SELECT ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY empno) AS rn,
       CASE WHEN deptno = 10 THEN '*' ELSE NULL END AS deptno_10,
       CASE WHEN deptno = 20 THEN '*' ELSE NULL END AS deptno_20,
       CASE WHEN deptno = 30 THEN '*' ELSE NULL END AS deptno_30
  FROM emp;
```

```console
rn | deptno_10 | deptno_20 | deptno_30
----+-----------+-----------+-----------
 1 | *         |           |
 2 | *         |           |
 3 | *         |           |
 1 |           | *         |
 2 |           | *         |
 3 |           | *         |
 4 |           | *         |
 5 |           | *         |
 1 |           |           | *
 2 |           |           | *
 3 |           |           | *
 4 |           |           | *
 5 |           |           | *
 6 |           |           | *
 ```

 The next and last step is to use the aggregate function `MAX` on each `CASE` expression, grouping by `RN` to remove the `NULLs` from the result set. Order the results `ASC` or `DESC` depending on how your RDBMS sorts `NULLs`:

 ```SQL
 WITH x AS (
   SELECT ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY empno) AS rn,
          CASE WHEN deptno = 10 THEN '*' ELSE NULL END AS deptno_10,
          CASE WHEN deptno = 20 THEN '*' ELSE NULL END AS deptno_20,
          CASE WHEN deptno = 30 THEN '*' ELSE NULL END AS deptno_30
     FROM emp
 )
 SELECT MAX(deptno_10) AS d10,
        MAX(deptno_20) AS d20,
        MAX(deptno_30) AS d30
   FROM x
  GROUP BY rn
  ORDER BY 1 DESC, 2 DESC, 3 DESC;
 ```

```console
 d10 | d20 | d30
-----+-----+-----
    |     | *
    | *   | *
    | *   | *
*   | *   | *
*   | *   | *
*   | *   | *
```
