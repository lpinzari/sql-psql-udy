# Suppressing Duplicates

You want to find the **different job types** in table `EMP` but **do not want to see `duplicates`.

```SQL
SELECT ename, job
  FROM emp
 ORDER BY job;
```

|ename  |    job|
|:-----:|:-------:|
|SCOTT  | ANALYST|
|FORD   | ANALYST|
|MILLER | CLERK|
|ADAMS  | CLERK|
|JAMES  | CLERK|
|SMITH  | CLERK|
|CLARK  | MANAGER|
|JONES  | MANAGER|
|BLAKE  | MANAGER|
|KING   | PRESIDENT|
|TURNER | SALESMAN|
|ALLEN  | SALESMAN|
|MARTIN | SALESMAN|
|WARD   | SALESMAN|

The result set should be as follows:

|job|
|:---------:|
|CLERK|
|PRESIDENT|
|MANAGER|
|SALESMAN|
|ANALYST|

## Solution

All of the RDBMSs support the keyword `DISTINCT`, and it arguably is the easiest mechanism for suppressing duplicates from the result set. However, this recipe will also cover two additional methods for suppressing duplicates.

```SQL
SELECT DISTINCT job
  FROM emp;
```

The **traditional method** of using `DISTINCT` and sometimes `GROUP BY` certainly works.

Additionally, it is also possible to use `GROUP BY` to suppress duplicates:

```SQL
SELECT job
  FROM emp
 GROUP BY job;
```

The following solution is an alternative that makes use of the window function `ROW_NUMBER OVER`:

```SQL
WITH t AS (
  SELECT job,
         ROW_NUMBER() OVER(PARTITION BY job ORDER BY job) AS rn
    FROM emp
)
SELECT job
  FROM t
 WHERE rn = 1;
```

## Discussion

This solution depends on some outside-the-box thinking about partitioned window functions. By using `PARTITION BY` in the `OVER` clause of `ROW_NUMBER`, you can **reset the value returned** by `ROW_NUMBER` to **1** `whenever a new job is encoun‐ tered`.

```SQL
SELECT job,
       ROW_NUMBER() OVER(PARTITION BY job ORDER BY job) AS rn
  FROM emp;
```

|job    | rn|
|:--------:|:--:|
|ANALYST   |  1|
|ANALYST   |  2|
|CLERK     |  1|
|CLERK     |  2|
|CLERK     |  3|
|CLERK     |  4|
|MANAGER   |  1|
|MANAGER   |  2|
|MANAGER   |  3|
|PRESIDENT |  1|
|SALESMAN  |  1|
|SALESMAN  |  2|
|SALESMAN  |  3|
|SALESMAN  |  4|

Each row is given an increasing, **sequential number**, and that **number is reset to one whenever the job changes**. To `filter out the duplicates`, all you must do is **keep the rows where RN is 1**.

An `ORDER BY` clause is mandatory when using `ROW_NUMBER OVER` but doesn’t affect the result. Which job is returned is irrelevant so long as you return one of each job.

- **Traditional alternatives**

The first solution shows how to use the keyword `DISTINCT` to suppress duplicates from a result set. Keep in mind that `DISTINCT` **is applied to the whole** `SELECT` list: **additional columns can and will change the result set**.

Consider the difference between these two queries:

```SQL
SELECT DISTINCT job
  FROM emp;
```

|job|
|:---------:|
|CLERK|
|PRESIDENT|
|MANAGER|
|SALESMAN|
|ANALYST|

```SQL
SELECT DISTINCT job, deptno
  FROM emp;
```

|job    | deptno|
|:--------:|:-----:|
|CLERK     |     30|
|MANAGER   |     10|
|CLERK     |     10|
|PRESIDENT |     10|
|SALESMAN  |     30|
|ANALYST   |     20|
|CLERK     |     20|
|MANAGER   |     30|
|MANAGER   |     20|

By adding `DEPTNO` to the `SELECT` list, what you return is each `DISTINCT` pair of `JOB/DEPTNO` values from table `EMP`.

The second solution uses `GROUP BY` to suppress duplicates. While using `GROUP BY` in this way is not uncommon, keep in mind that `GROUP BY` and `DISTINCT` are two very different clauses that are not interchangeable. I’ve included `GROUP BY` in this solution for completeness, as you will no doubt come across it at some point.
