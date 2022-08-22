# Reverse Pivoting a Result Set


You want to **transform columns to rows**.

## Problem

Consider the following result set:

|deptno_10 | deptno_20 | deptno_30|
|:--------:|:---------:|:--------:|
|        3 |         5 |         6|


You would like to convert that to the following:

|deptno | counts_by_dept|
|:-----:|:---:|
|    10 |   3|
|    20 |   5|
|    30 |   6|

Some readers may have noticed that the first listing is the output from the first recipe in this chapter. To make this output available for this recipe, we can store it in a view with the following query:

```SQL
CREATE VIEW emp_cnts AS (
  SELECT SUM(CASE WHEN deptno = 10 THEN 1 ELSE 0 END) AS deptno_10,
         SUM(CASE WHEN deptno = 20 THEN 1 ELSE 0 END) AS deptno_20,
         SUM(CASE WHEN deptno = 30 THEN 1 ELSE 0 END) AS deptno_30
    FROM emp
);
```

In the solution and discussion that follow, the queries will refer to the `EMP_CNTS` view created by the preceding query.

## Solution


Examining the desired result set, it’s easy to see that you can execute a simple `COUNT` and `GROUP BY` on table `EMP` to produce the desired result.

The object here, though, is to imagine that the data is not stored as rows; perhaps **the data is** `denormalized` and **aggregated values are stored as multiple columns**.

To **convert columns to rows**, use a `Cartesian product`.

You’ll need to `know in advance how many columns you want to convert to rows` because the table expression you use to create the Cartesian product must have a cardinality of at least the number of columns you want to transpose.

The full solution is as follows:

```SQL
WITH deptno_t AS (
  SELECT deptno
    FROM dept
   WHERE deptno <= 30
)
SELECT dt.deptno,
       CASE dt.deptno
            WHEN 10 THEN ec.deptno_10
            WHEN 20 THEN ec.deptno_20
            WHEN 30 THEN ec.deptno_30
       END AS counts_by_dept
  FROM deptno_t dt, emp_cnts ec
 ORDER BY deptno;
```

## Discussion

The view `EMP_CNTS` represents the `denormalized view`, or “wide” result set that you want to convert to rows, and is shown here:

|deptno_10 | deptno_20 | deptno_30|
|:--------:|:---------:|:--------:|
|        3 |         5 |         6|

Because there are `three columns`, you **will create three rows**. Begin by creating a `Cartesian product` between i view `EMP_CNTS` and **some table expression that has at least three rows**.

For example, a table expression with three rows:

```SQL
WITH deptno_t AS (
  SELECT deptno
    FROM dept
   WHERE deptno <= 30
)
SELECT *
  FROM deptno_t;
```

|deptno|
|:-----:|
|    10|
|    20|
|    30|

The following code uses table `DEPTNO_t` to create the Cartesian product:

```SQL
WITH deptno_t AS (
  SELECT deptno
    FROM dept
   WHERE deptno <= 30
)
SELECT dt.deptno,
       ec.deptno_10,
       ec.deptno_20,
       ec.deptno_30
  FROM deptno_t dt, emp_cnts ec
 ORDER BY deptno;
```

|deptno | deptno_10 | deptno_20 | deptno_30|
|:-----:|:---------:|:---------:|:--------:|
|    10 |         3 |         5 |         6|
|    20 |         3 |         5 |         6|
|    30 |         3 |         5 |         6|

The Cartesian product enables you to return a row for each column in view `EMP_CNTS`. Since the final result set should have only the `DEPTNO` and the `number of employees` in said `DEPTNO`, use a `CASE` expression to transform the three columns into one:

```SQL
WITH deptno_t AS (
  SELECT deptno
    FROM dept
   WHERE deptno <= 30
)
SELECT dt.deptno,
       CASE dt.deptno
            WHEN 10 THEN ec.deptno_10
            WHEN 20 THEN ec.deptno_20
            WHEN 30 THEN ec.deptno_30
       END AS counts_by_dept
  FROM deptno_t dt, emp_cnts ec
 ORDER BY deptno;
```

|deptno | counts_by_dept|
|:-----:|:--------------:|
|    10 |              3|
|    20 |              5|
|    30 |              6|
