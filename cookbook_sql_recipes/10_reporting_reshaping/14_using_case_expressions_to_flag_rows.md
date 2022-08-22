# Using Case Expressions to Flag Rows

You want to map the values in a column, perhaps the `EMP` table’s `JOB column`, into a series of “**Boolean**” `flags`.

## Problem

For example, you want to return the following result set:

|ename  |    job    | is_clerk | is_sales | is_mgr | is_analyst | is_prez|
|:-----:|:---------:|:--------:|:--------:|:------:|:----------:|:-------:|
|SCOTT  | ANALYST   |        0 |        0 |      0 |          1 |       0|
|FORD   | ANALYST   |        0 |        0 |      0 |          1 |       0|
|MILLER | CLERK     |        1 |        0 |      0 |          0 |       0|
|ADAMS  | CLERK     |        1 |        0 |      0 |          0 |       0|
|JAMES  | CLERK     |        1 |        0 |      0 |          0 |       0|
|SMITH  | CLERK     |        1 |        0 |      0 |          0 |       0|
|CLARK  | MANAGER   |        0 |        0 |      1 |          0 |       1|
|JONES  | MANAGER   |        0 |        0 |      1 |          0 |       1|
|BLAKE  | MANAGER   |        0 |        0 |      1 |          0 |       1|
|KING   | PRESIDENT |        0 |        0 |      0 |          0 |       0|
|TURNER | SALESMAN  |        0 |        1 |      0 |          0 |       0|
|ALLEN  | SALESMAN  |        0 |        1 |      0 |          0 |       0|
|MARTIN | SALESMAN  |        0 |        1 |      0 |          0 |       0|
|WARD   | SALESMAN  |        0 |        1 |      0 |          0 |       0|

## Solution

Use a `CASE` expression to evaluate each employee’s `JOB`, and return a **1** or **0** to signify their `JOB`. You’ll need to write one `CASE` expression, and thus create one column for each possible job:

```SQL
SELECT ename,
       job,
       CASE WHEN job = 'CLERK'
            THEN 1 ELSE 0
       END AS is_clerk,
       CASE WHEN job = 'SALESMAN'
            THEN 1 ELSE 0
       END AS is_sales,
       CASE WHEN job = 'MANAGER'
            THEN 1 ELSE 0
       END AS is_mgr,
       CASE WHEN job = 'ANALYST'
            THEN 1 ELSE 0
       END AS is_analyst,
       CASE WHEN job = 'MANAGER'
            THEN 1 ELSE 0
       END AS is_prez
  FROM emp
 ORDER BY 2;        
```

## Discussion

The solution code is pretty much self-explanatory. If you are having trouble under‐ standing it, simply add `JOB` to the `SELECT` clause:

```SQL
SELECT ename,
       job,
       CASE WHEN job = 'CLERK'
            THEN 1 ELSE 0
       END AS is_clerk,
       CASE WHEN job = 'SALESMAN'
            THEN 1 ELSE 0
       END AS is_sales,
       CASE WHEN job = 'MANAGER'
            THEN 1 ELSE 0
       END AS is_mgr,
       CASE WHEN job = 'ANALYST'
            THEN 1 ELSE 0
       END AS is_analyst,
       CASE WHEN job = 'MANAGER'
            THEN 1 ELSE 0
       END AS is_prez
  FROM emp
 ORDER BY 2;        
```

|ename  |    job    | is_clerk | is_sales | is_mgr | is_analyst | is_prez|
|:-----:|:---------:|:--------:|:--------:|:------:|:----------:|:-------:|
|SCOTT  | ANALYST   |        0 |        0 |      0 |          1 |       0|
|FORD   | ANALYST   |        0 |        0 |      0 |          1 |       0|
|MILLER | CLERK     |        1 |        0 |      0 |          0 |       0|
|ADAMS  | CLERK     |        1 |        0 |      0 |          0 |       0|
|JAMES  | CLERK     |        1 |        0 |      0 |          0 |       0|
|SMITH  | CLERK     |        1 |        0 |      0 |          0 |       0|
|CLARK  | MANAGER   |        0 |        0 |      1 |          0 |       1|
|JONES  | MANAGER   |        0 |        0 |      1 |          0 |       1|
|BLAKE  | MANAGER   |        0 |        0 |      1 |          0 |       1|
|KING   | PRESIDENT |        0 |        0 |      0 |          0 |       0|
|TURNER | SALESMAN  |        0 |        1 |      0 |          0 |       0|
|ALLEN  | SALESMAN  |        0 |        1 |      0 |          0 |       0|
|MARTIN | SALESMAN  |        0 |        1 |      0 |          0 |       0|
|WARD   | SALESMAN  |        0 |        1 |      0 |          0 |       0|
