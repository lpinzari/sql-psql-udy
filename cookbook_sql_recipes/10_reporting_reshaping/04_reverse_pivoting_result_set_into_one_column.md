# Reverse Pivoting a Result Set into One Column

You want to return all **columns from a query as just one column**.

## Problem

For example, you want to return the
- `ENAME`,
- `JOB`, and
- `SAL` of all employees in `DEPTNO 10`,

and you want to return **all three values in one column**.

You want to return **three rows for each employee** and **one row of white space** `between employees`.

You want to return the following result set:

```console
|emps       |
|:---------:|
|CLARK      |
|MANAGER    |
|2450       |
|           |
|KING       |
|PRESIDENT  |
|5000       |
|           |
|MILLER     |
|CLERK      |
|1300       |
|           |
```


## Solution

The key is to use a `GENERATE SERIES` **combined with** `Cartesian product` to return `four rows` for **each employee**.

```SQL
WITH four_rows (id) AS (
  SELECT GENERATE_SERIES(1,4)
),
emp10 AS (
  SELECT ename, job, sal
    FROM emp
   WHERE deptno = 10
),
x AS (
  SELECT e.*, f.id AS rn
    FROM emp10 AS e, four_rows AS f
)
SELECT CASE WHEN rn = 1
            THEN ename
            WHEN rn = 2
            THEN job
            WHEN rn = 3
            THEN sal::VARCHAR
       END AS emps
  FROM x;
```



## Discussion


```SQL
WITH four_rows (id) AS (
  SELECT GENERATE_SERIES(1,4)
),
emp10 AS (
  SELECT ename, job, sal
    FROM emp
   WHERE deptno = 10
)
SELECT e.*, f.id AS rn
  FROM emp10 AS e, four_rows AS f;  
```

|ename  |    job    | sal  | rn|
|:-----:|:---------:|:----:|:--:|
|CLARK  | MANAGER   | 2450 |  1|
|CLARK  | MANAGER   | 2450 |  2|
|CLARK  | MANAGER   | 2450 |  3|
|CLARK  | MANAGER   | 2450 |  4|
|KING   | PRESIDENT | 5000 |  1|
|KING   | PRESIDENT | 5000 |  2|
|KING   | PRESIDENT | 5000 |  3|
|KING   | PRESIDENT | 5000 |  4|
|MILLER | CLERK     | 1300 |  1|
|MILLER | CLERK     | 1300 |  2|
|MILLER | CLERK     | 1300 |  3|
|MILLER | CLERK     | 1300 |  4|

The hard work is now done, and all that is left is to use a `CASE` expression to put `ENAME`, `JOB`, and `SAL` into **one column** for each employee (you need to convert `SAL` to a string to keep `CASE` happy):

```SQL
WITH four_rows (id) AS (
  SELECT GENERATE_SERIES(1,4)
),
emp10 AS (
  SELECT ename, job, sal
    FROM emp
   WHERE deptno = 10
),
x AS (
  SELECT e.*, f.id AS rn
    FROM emp10 AS e, four_rows AS f
)
SELECT CASE WHEN rn = 1
            THEN ename
            WHEN rn = 2
            THEN job
            WHEN rn = 3
            THEN sal::VARCHAR
       END AS emps
  FROM x;
```

```console
|emps       |
|:---------:|
|CLARK      |
|MANAGER    |
|2450       |
|           |
|KING       |
|PRESIDENT  |
|5000       |
|           |
|MILLER     |
|CLERK      |
|1300       |
|           |
```
