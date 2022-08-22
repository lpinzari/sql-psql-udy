# Pivoting a Result Set into Multiple Rows

You want to **turn rows into columns** by
- creating a column corresponding to each of the values in a single given column.

However, unlike in the previous recipe, you need **multiple rows of output**.

Like the earlier recipe, pivoting into multiple rows is a fundamental method of reshaping data.


## Problem


- **Problem 1**:

For example, you want to return `each employee` and their position (`JOB`), and you currently use a query that returns the following result set:

```SQL
SELECT job, ename
  FROM emp
 ORDER BY job, ename;
```

|job    | ename|
|:--------:|:-----:|
|ANALYST   | FORD|
|ANALYST   | SCOTT|
|CLERK     | ADAMS|
|CLERK     | JAMES|
|CLERK     | MILLER|
|CLERK     | SMITH|
|MANAGER   | BLAKE|
|MANAGER   | CLARK|
|MANAGER   | JONES|
|PRESIDENT | KING|
|SALESMAN  | ALLEN|
|SALESMAN  | MARTIN|
|SALESMAN  | TURNER|
|SALESMAN  | WARD|

You would like to format the result set such that each job gets its own column:

|clerks | analysts | mgrs  | prez | sales|
|:-----:|:---------:|:----:|:----:|:----:|
|ADAMS  | FORD     | BLAKE | KING | ALLEN|
|JAMES  | SCOTT    | CLARK |      | MARTIN|
|MILLER |          | JONES |      | TURNER|
|SMITH  |          |       |      | WARD|


- **Problem 2**:

```SQL
SELECT deptno, job, ename
  FROM emp
 ORDER BY deptno, job, ename;
```

|deptno |    job    | ename|
|:-----:|:---------:|:-----:|
|    10 | CLERK     | MILLER|
|    10 | MANAGER   | CLARK|
|    10 | PRESIDENT | KING|
|    20 | ANALYST   | FORD|
|    20 | ANALYST   | SCOTT|
|    20 | CLERK     | ADAMS|
|    20 | CLERK     | SMITH|
|    20 | MANAGER   | JONES|
|    30 | CLERK     | JAMES|
|    30 | MANAGER   | BLAKE|
|    30 | SALESMAN  | ALLEN|
|    30 | SALESMAN  | MARTIN|
|    30 | SALESMAN  | TURNER|
|    30 | SALESMAN  | WARD|

You would like to format the result set such that each job gets its own column:

|deptno |    job    |  d10   |  d20  |  d30   | clerks | analysts | mgrs  | prez | sales|
|:--------:|:-----------:|:--------:|:-------:|:--------:|:--------:|:----------:|:-------:|:------:|:--------:|
|10 | CLERK     | MILLER |       |        | MILLER |          |       |      ||
|10 | MANAGER   | CLARK  |       |        |        |          | CLARK |      ||
|10 | PRESIDENT | KING   |       |        |        |          |       | KING ||
|20 | ANALYST   |        | SCOTT |        |        | SCOTT    |       |      ||
|20 | ANALYST   |        | FORD  |        |        | FORD     |       |      ||
|20 | CLERK     |        | SMITH |        | SMITH  |          |       |      ||
|20 | CLERK     |        | ADAMS |        | ADAMS  |          |       |      ||
|20 | MANAGER   |        | JONES |        |        |          | JONES |      ||
|30 | CLERK     |        |       | JAMES  | JAMES  |          |       |      ||
|30 | MANAGER   |        |       | BLAKE  |        |          | BLAKE |      ||
|30 | SALESMAN  |        |       | ALLEN  |        |          |       |      | ALLEN|
|30 | SALESMAN  |        |       | WARD   |        |          |       |      | WARD|
|30 | SALESMAN  |        |       | TURNER |        |          |       |      | TURNER|
|30 | SALESMAN  |        |       | MARTIN |        |          |       |      | MARTIN|



## Solution

Unlike the first recipe in this chapter, the result set for this recipe consists of more than one row. Using the previous recipe’s technique will not work for this recipe, as the `MAX(ENAME)` for each JOB would be returned, which would result in one `ENAME` for each `JOB` (i.e., one row will be returned as in the first recipe). To solve this problem, you must make each `JOB/ENAME` **combination unique**.

Then, when you apply an aggregate function to remove `NULLs`, you don’t lose any `ENAMEs`.
Use the ranking function `ROW_NUMBER OVER` to make each `JOB/ENAME` combination unique. Pivot the result set using a `CASE` expression and the aggregate function `MAX` while grouping on the value returned by the window function:

```SQL
WITH temp AS (
  SELECT job, ename,
         ROW_NUMBER () OVER(PARTITION BY job ORDER BY ename) AS rn
    FROM emp
)
SELECT MAX(CASE WHEN job = 'CLERK'
            THEN ename ELSE NULL END) AS clerks,
       MAX(CASE WHEN job = 'ANALYST'
            THEN ename ELSE NULL END) AS analysts,
       MAX(CASE WHEN job = 'MANAGER'
            THEN ename ELSE NULL END) AS mgrs,
       MAX(CASE WHEN job = 'PRESIDENT'
            THEN ename ELSE NULL END) AS prez,
       MAX(CASE WHEN job = 'SALESMAN'
            THEN ename ELSE NULL END) AS sales
  FROM temp
 GROUP BY rn
 ORDER BY rn;
```

## Discussion

The first step is to use the **window function** `ROW_NUMBER OVER` to help make each `JOB/ENAME` **combination unique**:

```SQL
SELECT job, ename,
       ROW_NUMBER () OVER(PARTITION BY job ORDER BY ename) AS rn
  FROM emp
 ORDER BY job, ename;
```

```console
job    | ename  | rn
-----------+--------+----
ANALYST   | FORD   |  1
ANALYST   | SCOTT  |  2
------------------------
CLERK     | ADAMS  |  1
CLERK     | JAMES  |  2
CLERK     | MILLER |  3
CLERK     | SMITH  |  4
-------------------------
MANAGER   | BLAKE  |  1
MANAGER   | CLARK  |  2
MANAGER   | JONES  |  3
------------------------
PRESIDENT | KING   |  1
------------------------
SALESMAN  | ALLEN  |  1
SALESMAN  | MARTIN |  2
SALESMAN  | TURNER |  3
SALESMAN  | WARD   |  4
```

Giving each `ENAME` a **unique “row number”** `within a given job` **prevents any problems that might otherwise result from two employees having the same name and job**.

The goal here is to be able to `group on row number` (on `RN`) without dropping any employees from the result set due to the use of `MAX`. This step is the most important step in solving the problem. Without this first step, the aggregation in the outer query will remove necessary rows.

Consider what the result set would look like without using `ROW_NUMBER OVER`, using the same technique as shown in the first recipe:


```SQL
SELECT MAX(CASE WHEN job = 'CLERK'
                THEN ename ELSE NULL END) AS clerks,
       MAX(CASE WHEN job = 'ANALYST'
                THEN ename ELSE NULL END) AS analysts,
       MAX(CASE WHEN job = 'MANAGER'
                THEN ename ELSE NULL END) AS mgrs,
       MAX(CASE WHEN job = 'PRESIDENT'
                THEN ename ELSE NULL END) AS prez,
       MAX(CASE WHEN job = 'SALESMAN'
                THEN ename ELSE NULL END) AS sales
  FROM emp;
```

|clerks | analysts | mgrs  | prez | sales|
|:-----:|:--------:|:-----:|:----:|:-----:|
|SMITH  | SCOTT    | JONES | KING | WARD|


Unfortunately, only one row is returned for each `JOB`: the employee with the `MAX ENAME`. When it comes time to pivot the result set, using `MIN` or `MAX` should serve as a means to remove `NULLs` from the result set, not restrict the `ENAMEs` returned.

How this works will be come clearer as you continue through the explanation.

```SQL
WITH temp AS (
  SELECT job, ename,
         ROW_NUMBER () OVER(PARTITION BY job ORDER BY ename) AS rn
    FROM emp
)
SELECT rn,
       CASE WHEN job = 'CLERK'
            THEN ename ELSE NULL END AS clerks,
       CASE WHEN job = 'ANALYST'
            THEN ename ELSE NULL END AS analysts,
       CASE WHEN job = 'MANAGER'
            THEN ename ELSE NULL END AS mgrs,
       CASE WHEN job = 'PRESIDENT'
            THEN ename ELSE NULL END AS prez,
       CASE WHEN job = 'SALESMAN'
            THEN ename ELSE NULL END AS sales
  FROM temp;
```


The next step uses a `CASE` expression to organize the `ENAMEs` into their proper column (`JOB`):

|rn | clerks | analysts | mgrs  | prez | sales|
|:--:|:-----:|:--------:|:-----:|:-----:|:-------:|
| 1 |        | FORD     |       |      ||
| 2 |        | SCOTT    |       |      ||
| 1 | ADAMS  |          |       |      ||
| 2 | JAMES  |          |       |      ||
| 3 | MILLER |          |       |      ||
| 4 | SMITH  |          |       |      ||
| 1 |        |          | BLAKE |      ||
| 2 |        |          | CLARK |      ||
| 3 |        |          | JONES |      ||
| 1 |        |          |       | KING ||
| 1 |        |          |       |      | ALLEN|
| 2 |        |          |       |      | MARTIN|
| 3 |        |          |       |      | TURNER|
| 4 |        |          |       |      | WARD|

At this point, the rows are transposed into columns, and the last step is **to remove the NULLs** to make the result set more readable.

```SQL
WITH temp AS (
  SELECT job, ename,
         ROW_NUMBER () OVER(PARTITION BY job ORDER BY ename) AS rn
    FROM emp
)
SELECT rn,
       MAX(CASE WHEN job = 'CLERK'
            THEN ename ELSE NULL END) AS clerks
  FROM temp
 GROUP BY rn
 ORDER BY rn;
```

|rn | clerks|
|:-:|:-----:|
| 1 | ADAMS|
| 2 | JAMES|
| 3 | MILLER|
| 4 | SMITH|


To **remove the NULLs**, use the **aggregate function** `MAX` **and group by** `RN`. (You can use the function `MIN` as well. The choice to use `MAX` is arbitrary, as **you will only ever be aggregating one value per group**.)

```console

|rn | clerks |
|:--:|:-----:|
| 1 | NULL   |
| 2 | NULL   |
| 1 | ADAMS  |
| 2 | JAMES  |
| 3 | MILLER |
| 4 | SMITH  |
| 1 | NULL   |
| 2 | NULL   |
| 3 | NULL   |
| 1 | NULL   |
| 1 | NULL   |      
| 2 | NULL   |      
| 3 | NULL   |      
| 4 | NULL   |      


rn | clerks       rn | clerks     rn | clerks    rn | clerks
----+--------    ----+--------   ----+-------    ---+-------
 1 | NULL          2 | NULL        3 | MILLER     4 | SMITH
 1 | ADAMS         2 | JAMES       3 | NULL       4 | NULL
 1 | NULL          2 | NULL        3 | NULL      
 1 | NULL          2 | NULL          
 1 | NULL              

 rn | clerks
 ---+-------
  1 | ADAMS  = MAX (NULL,'ADAMS',NULL,NULL,NULL)
  2 | JAMES  = MAX (NULL, 'JAMES', NULL, NULL)
  3 | MILLER = MAX ('MILLER', NULL, NULL)
  4 | SMITH  = MAX ('SMITH',NULL)
```

There is `only one value` for each `RN/JOB/ENAME` combination. Grouping by `RN` in conjunction with the `CASE` expressions embedded within the calls to `MAX` ensures that each call to `MAX` results in **picking only one name from a group of otherwise NULL values**:

```SQL
WITH temp AS (
  SELECT job, ename,
         ROW_NUMBER () OVER(PARTITION BY job ORDER BY ename) AS rn
    FROM emp
)
SELECT rn,
       MAX(CASE WHEN job = 'CLERK'
            THEN ename ELSE NULL END) AS clerks,
       MAX(CASE WHEN job = 'ANALYST'
            THEN ename ELSE NULL END) AS analysts,
       MAX(CASE WHEN job = 'MANAGER'
            THEN ename ELSE NULL END) AS mgrs,
       MAX(CASE WHEN job = 'PRESIDENT'
            THEN ename ELSE NULL END) AS prez,
       MAX(CASE WHEN job = 'SALESMAN'
            THEN ename ELSE NULL END) AS sales
  FROM temp
 GROUP BY rn
 ORDER BY rn;
```

|rn | clerks | analysts | mgrs  | prez | sales|
|:-:|:------:|:--------:|:-----:|:----:|:-----:|
| 1 | ADAMS  | FORD     | BLAKE | KING | ALLEN|
| 2 | JAMES  | SCOTT    | CLARK |      | MARTIN|
| 3 | MILLER |          | JONES |      | TURNER|
| 4 | SMITH  |          |       |      | WARD|

## Problem 2

The technique of using `ROW_NUMBER OVER` to create unique combinations of rows is extremely useful for formatting query results. Consider the following query that creates a sparse report showing employees by `DEPTNO` and `JOB`:

```SQL
WITH temp AS (
  SELECT deptno, job, ename,
         ROW_NUMBER () OVER(PARTITION BY deptno ORDER BY ename) AS rn_deptno
    FROM emp
)
SELECT deptno, job, rn_deptno,
       CASE WHEN deptno = 10
            THEN ename ELSE NULL END AS d10,
       CASE WHEN deptno = 20
            THEN ename ELSE NULL END AS d20,
       CASE WHEN deptno = 30
            THEN ename ELSE NULL END AS d30,
       CASE WHEN job = 'CLERK'
            THEN ename ELSE NULL END AS clerks,
       CASE WHEN job = 'ANALYST'
            THEN ename ELSE NULL END AS analysts,
       CASE WHEN job = 'MANAGER'
            THEN ename ELSE NULL END AS mgrs,
       CASE WHEN job = 'PRESIDENT'
            THEN ename ELSE NULL END AS prez,
       CASE WHEN job = 'SALESMAN'
            THEN ename ELSE NULL END AS sales
  FROM temp
 ORDER BY deptno, rn_deptno;
```

```console
deptno |    job    | rn_deptno |  d10   |  d20  |  d30   | clerks | analysts | mgrs  | prez | sales
--------+-----------+-----------+--------+-------+--------+--------+----------+-------+------+--------
    10 | MANAGER   |         1 | CLARK  |       |        |        |          | CLARK |      |
    10 | PRESIDENT |         2 | KING   |       |        |        |          |       | KING |
    10 | CLERK     |         3 | MILLER |       |        | MILLER |          |       |      |
    20 | CLERK     |         1 |        | ADAMS |        | ADAMS  |          |       |      |
    20 | ANALYST   |         2 |        | FORD  |        |        | FORD     |       |      |
    20 | MANAGER   |         3 |        | JONES |        |        |          | JONES |      |
    20 | ANALYST   |         4 |        | SCOTT |        |        | SCOTT    |       |      |
    20 | CLERK     |         5 |        | SMITH |        | SMITH  |          |       |      |
    30 | SALESMAN  |         1 |        |       | ALLEN  |        |          |       |      | ALLEN
    30 | MANAGER   |         2 |        |       | BLAKE  |        |          | BLAKE |      |
    30 | CLERK     |         3 |        |       | JAMES  | JAMES  |          |       |      |
    30 | SALESMAN  |         4 |        |       | MARTIN |        |          |       |      | MARTIN
    30 | SALESMAN  |         5 |        |       | TURNER |        |          |       |      | TURNER
    30 | SALESMAN  |         6 |        |       | WARD   |        |          |       |      | WARD
```

```SQL
WITH temp AS (
  SELECT deptno, job, ename,
         ROW_NUMBER () OVER(PARTITION BY deptno ORDER BY ename) AS rn_deptno
    FROM emp
)
SELECT deptno, job,
       MAX(CASE WHEN deptno = 10
            THEN ename ELSE NULL END) AS d10,
       MAX(CASE WHEN deptno = 20
            THEN ename ELSE NULL END) AS d20,
       MAX(CASE WHEN deptno = 30
            THEN ename ELSE NULL END) AS d30,
       MAX(CASE WHEN job = 'CLERK'
            THEN ename ELSE NULL END) AS clerks,
       MAX(CASE WHEN job = 'ANALYST'
            THEN ename ELSE NULL END) AS analysts,
       MAX(CASE WHEN job = 'MANAGER'
            THEN ename ELSE NULL END) AS mgrs,
       MAX(CASE WHEN job = 'PRESIDENT'
            THEN ename ELSE NULL END) AS prez,
       MAX(CASE WHEN job = 'SALESMAN'
            THEN ename ELSE NULL END) AS sales
  FROM temp
 GROUP BY deptno, job, rn_deptno
 ORDER BY deptno, job;
```

|deptno |    job    |  d10   |  d20  |  d30   | clerks | analysts | mgrs  | prez | sales|
|:--------:|:-----------:|:--------:|:-------:|:--------:|:--------:|:----------:|:-------:|:------:|:--------:|
|10 | CLERK     | MILLER |       |        | MILLER |          |       |      ||
|10 | MANAGER   | CLARK  |       |        |        |          | CLARK |      ||
|10 | PRESIDENT | KING   |       |        |        |          |       | KING ||
|20 | ANALYST   |        | SCOTT |        |        | SCOTT    |       |      ||
|20 | ANALYST   |        | FORD  |        |        | FORD     |       |      ||
|20 | CLERK     |        | SMITH |        | SMITH  |          |       |      ||
|20 | CLERK     |        | ADAMS |        | ADAMS  |          |       |      ||
|20 | MANAGER   |        | JONES |        |        |          | JONES |      ||
|30 | CLERK     |        |       | JAMES  | JAMES  |          |       |      ||
|30 | MANAGER   |        |       | BLAKE  |        |          | BLAKE |      ||
|30 | SALESMAN  |        |       | ALLEN  |        |          |       |      | ALLEN|
|30 | SALESMAN  |        |       | WARD   |        |          |       |      | WARD|
|30 | SALESMAN  |        |       | TURNER |        |          |       |      | TURNER|
|30 | SALESMAN  |        |       | MARTIN |        |          |       |      | MARTIN|
