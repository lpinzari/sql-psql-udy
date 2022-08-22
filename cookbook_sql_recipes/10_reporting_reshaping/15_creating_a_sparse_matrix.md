# Creating a Sparse Matrix

You want to create a `sparse matrix`, such as the following one **transposing** the `DEPTNO` and `JOB` columns of table `EMP`:

```SQL
SELECT deptno, job, ename
  FROM emp
 ORDER BY deptno, job;
```

|deptno |    job    | ename|
|:-----:|:---------:|:-----:|
|    10 | CLERK     | MILLER|
|    10 | MANAGER   | CLARK|
|    10 | PRESIDENT | KING|
|    20 | ANALYST   | SCOTT|
|    20 | ANALYST   | FORD|
|    20 | CLERK     | ADAMS|
|    20 | CLERK     | SMITH|
|    20 | MANAGER   | JONES|
|    30 | CLERK     | JAMES|
|    30 | MANAGER   | BLAKE|
|    30 | SALESMAN  | MARTIN|
|    30 | SALESMAN  | WARD|
|    30 | SALESMAN  | TURNER|
|    30 | SALESMAN  | ALLEN|

The output:

| d10   |  d20  |  d30   | clerks |  mgr  | prz  | anals | sales|
|:-----:|:-----:|:------:|:------:|:-----:|:----:|:-----:|:------:|
|CLARK  | SMITH | ALLEN  | SMITH  | CLARK |      |       | ALLEN|
|KING   | JONES | WARD   |        | JONES | KING |       | WARD|
|MILLER | SCOTT | MARTIN | MILLER |       |      | SCOTT | MARTIN|
|      | ADAMS | BLAKE  | ADAMS  | BLAKE |      |       ||
|      | FORD  | TURNER |        |       |      | FORD  | TURNER|
|      |       | JAMES  | JAMES  |       |      |       ||

## Solution

Use CASE expressions to create a sparse row-to-column transformation:


```SQL
WITH x AS (
  SELECT deptno, job, ename,
         ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY empno) AS rn
   FROM emp
)
SELECT MAX(CASE deptno WHEN 10 THEN ename END) AS d10,
       MAX(CASE deptno WHEN 20 THEN ename END) AS d20,
       MAX(CASE deptno WHEN 30 THEN ename END) AS d30,
       MAX(CASE job WHEN 'CLERK' THEN ename END) AS clerks,
       MAX(CASE job WHEN 'MANAGER' THEN ename END) AS mgr,
       MAX(CASE job WHEN 'PRESIDENT' THEN ename END) AS prz,
       MAX(CASE job WHEN 'ANALYST' THEN ename END) AS anals,
       MAX(CASE job WHEN 'SALESMAN' THEN ename END) AS sales
  FROM x
 GROUP BY rn
 ORDER BY 1,2,3;
```

## Discussion

To transform the `DEPTNO` and `JOB` **rows to columns**, simply use a `CASE` expression to **evaluate the possible values returned by those rows**.

That’s all there is to it. As an aside, if you want to “densify” the report and get rid of some of those `NULL` rows, you would need to find something to group by. For example, use the window function `ROW_NUMBER OVER` to assign a ranking for each employee per `DEPTNO`, and then use the aggregate function `MAX` **to rub out some of the** `NULLs`:

```SQL
WITH x AS (
  SELECT deptno, job, ename,
         ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY empno) AS rn
   FROM emp
)
SELECT *
  FROM x;
```

```console
deptno |    job    | ename  | rn
--------+-----------+--------+----
    10 | MANAGER   | CLARK  |  1
    10 | PRESIDENT | KING   |  2
    10 | CLERK     | MILLER |  3
    20 | CLERK     | SMITH  |  1
    20 | MANAGER   | JONES  |  2
    20 | ANALYST   | SCOTT  |  3
    20 | CLERK     | ADAMS  |  4
    20 | ANALYST   | FORD   |  5
    30 | SALESMAN  | ALLEN  |  1
    30 | SALESMAN  | WARD   |  2
    30 | SALESMAN  | MARTIN |  3
    30 | MANAGER   | BLAKE  |  4
    30 | SALESMAN  | TURNER |  5
    30 | CLERK     | JAMES  |  6
(14 rows)
```

```SQL
WITH x AS (
  SELECT deptno, job, ename,
         ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY empno) AS rn
   FROM emp
)
SELECT rn,
       CASE deptno WHEN 10 THEN ename END AS d10,
       CASE deptno WHEN 20 THEN ename END AS d20,
       CASE deptno WHEN 30 THEN ename END AS d30,
       CASE job WHEN 'CLERK' THEN ename END AS clerks,
       CASE job WHEN 'MANAGER' THEN ename END AS mgr,
       CASE job WHEN 'PRESIDENT' THEN ename END AS prz,
       CASE job WHEN 'ANALYST' THEN ename END AS anals,
       CASE job WHEN 'SALESMAN' THEN ename END AS sales
  FROM x;
```

```console
rn |  d10   |  d20  |  d30   | clerks |  mgr  | prz  | anals | sales
----+--------+-------+--------+--------+-------+------+-------+--------
 1 | CLARK  |       |        |        | CLARK |      |       |
 2 | KING   |       |        |        |       | KING |       |
 3 | MILLER |       |        | MILLER |       |      |       |
 ------------------------------------------------------------------
 1 |        | SMITH |        | SMITH  |       |      |       |
 2 |        | JONES |        |        | JONES |      |       |
 3 |        | SCOTT |        |        |       |      | SCOTT |
 4 |        | ADAMS |        | ADAMS  |       |      |       |
 5 |        | FORD  |        |        |       |      | FORD  |
 ---------------------------------------------------------------------
 1 |        |       | ALLEN  |        |       |      |       | ALLEN
 2 |        |       | WARD   |        |       |      |       | WARD
 3 |        |       | MARTIN |        |       |      |       | MARTIN
 4 |        |       | BLAKE  |        | BLAKE |      |       |
 5 |        |       | TURNER |        |       |      |       | TURNER
 6 |        |       | JAMES  | JAMES  |       |      |       |
 ```

 ```SQL
 WITH x AS (
   SELECT deptno, job, ename,
          ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY empno) AS rn
    FROM emp
 )
 SELECT MAX(CASE deptno WHEN 10 THEN ename END) AS d10,
        MAX(CASE deptno WHEN 20 THEN ename END) AS d20,
        MAX(CASE deptno WHEN 30 THEN ename END) AS d30,
        MAX(CASE job WHEN 'CLERK' THEN ename END) AS clerks,
        MAX(CASE job WHEN 'MANAGER' THEN ename END) AS mgr,
        MAX(CASE job WHEN 'PRESIDENT' THEN ename END) AS prz,
        MAX(CASE job WHEN 'ANALYST' THEN ename END) AS anals,
        MAX(CASE job WHEN 'SALESMAN' THEN ename END) AS sales
   FROM x
  GROUP BY rn
  ORDER BY 1,2,3;
 ```

| d10   |  d20  |  d30   | clerks |  mgr  | prz  | anals | sales|
|:-----:|:-----:|:------:|:------:|:-----:|:----:|:-----:|:------:|
|CLARK  | SMITH | ALLEN  | SMITH  | CLARK |      |       | ALLEN|
|KING   | JONES | WARD   |        | JONES | KING |       | WARD|
|MILLER | SCOTT | MARTIN | MILLER |       |      | SCOTT | MARTIN|
|      | ADAMS | BLAKE  | ADAMS  | BLAKE |      |       ||
|      | FORD  | TURNER |        |       |      | FORD  | TURNER|
|      |       | JAMES  | JAMES  |       |      |       ||
