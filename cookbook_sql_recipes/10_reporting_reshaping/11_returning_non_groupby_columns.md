# Returning Non-GROUP BY Columns

You are executing a `GROUP BY` query, and you want to **return columns** in your select list that **are not also listed in your** `GROUP BY` **clause**.

This is not normally possible, as such `ungrouped columns` **would not represent a single value per row**.

## Problem

Say that you want to find the `employees` who **earn**
- the `highest` and `lowest` **salaries in each department**,

as well as the `employees` who **earn**
- the `highest` and `lowest` **salaries in each job**.

You want to see each employee’s `name`, the `department he works in`, his `job title`, and his `salary`.

```SQL
SELECT deptno,                     SELECT job,
       MAX(sal) AS max_dept,              MAX(sal) AS max_job,
       MIN(sal) AS min_dept               MIN(sal) AS min_job
  FROM emp                           FROM emp
 GROUP BY deptno                    GROUP BY job
 ORDER BY deptno;                   ORDER BY job;
```

```console

+-------+----------+---------+       +----------+---------+---------+
|deptno | max_dept | min_dept|       |   job    | max_job | min_job |
|:-----:|:--------:|:-------:|       |:--------:|:-------:|:-------:|
|    10 |     5000 |     1300|       |ANALYST   |    3000 |    3000 |
|    20 |     3000 |      800|       |CLERK     |    1300 |     800 |
|    30 |     2850 |      950|       |MANAGER   |    2975 |    2450 |
                                     |PRESIDENT |    5000 |    5000 |
                                     |SALESMAN  |    1600 |    1250 |
```


```SQL
WITH x AS (                        WITH x AS (
  SELECT deptno,                     SELECT job,
         MAX(sal) AS max_dept,              MAX(sal) AS max_job,
         MIN(sal) AS min_dept               MIN(sal) AS min_job
    FROM emp                           FROM emp
   GROUP BY deptno                    GROUP BY job
 )                                    )

SELECT e.deptno, e.ename, e.sal    SELECT e.job, e.ename, e.sal
  FROM emp e, x                      FROM emp e, x
 WHERE (e.deptno = x.deptno) AND    WHERE (e.job = x.job) AND
       (e.sal = x.max_dept OR             (e.sal = x.max_job OR
        e.sal = x.min_dept)                e.sal = x.min_job)
 ORDER BY deptno;                   ORDER BY job;
```

```console
deptno | ename  | sal         job    | ename  | sal
--------+--------+------  -----------+--------+------
    10 | KING   | 5000     ANALYST   | SCOTT  | 3000
    10 | MILLER | 1300     ANALYST   | FORD   | 3000
    20 | SCOTT  | 3000     CLERK     | SMITH  |  800
    20 | SMITH  |  800     MANAGER   | CLARK  | 2450
    20 | FORD   | 3000     MANAGER   | JONES  | 2975
    30 | JAMES  |  950     PRESIDENT | KING   | 5000
    30 | BLAKE  | 2850     SALESMAN  | MARTIN | 1250
                           SALESMAN  | WARD   | 1250
                           SALESMAN  | ALLEN  | 1600
```

You want to return the following result set:

|deptno | ename  |    job    | sal  |   dept_status   |   job_status|
|:-----:|:-------:|:--------:|:-----:|:--------------:|:--------------:|
|    10 | KING   | PRESIDENT | 5000 | TOP SAL IN DEPT | TOP SAL IN JOB|
|    10 | CLARK  | MANAGER   | 2450 |                 | LOW SAL IN JOB|
|    10 | MILLER | CLERK     | 1300 | LOW SAL IN DEPT | TOP SAL IN JOB|
|    20 | FORD   | ANALYST   | 3000 | TOP SAL IN DEPT | TOP SAL IN JOB|
|    20 | SCOTT  | ANALYST   | 3000 | TOP SAL IN DEPT | TOP SAL IN JOB|
|    20 | JONES  | MANAGER   | 2975 |                 | TOP SAL IN JOB|
|    20 | SMITH  | CLERK     |  800 | LOW SAL IN DEPT | LOW SAL IN JOB|
|    30 | BLAKE  | MANAGER   | 2850 | TOP SAL IN DEPT ||
|    30 | ALLEN  | SALESMAN  | 1600 |                 | TOP SAL IN JOB|
|    30 | WARD   | SALESMAN  | 1250 |                 | LOW SAL IN JOB|
|    30 | MARTIN | SALESMAN  | 1250 |                 | LOW SAL IN JOB|
|    30 | JAMES  | CLERK     |  950 | LOW SAL IN DEPT ||


## Solution

Use a CTE to find the high and low salaries by `DEPTNO` and `JOB`. Then keep only the employees who make those salaries.

Use the window functions `MAX OVER` and `MIN OVER` to find the highest and lowest salaries by `DEPTNO` and `JOB`. Then keep the rows where the salaries are those that are highest or lowest by `DEPTNO` or `JOB`:

```SQL
WITH x AS (
  SELECT deptno, ename, job, sal,
         MAX(sal) OVER(PARTITION BY deptno) AS max_sal_by_dept,
         MAX(sal) OVER(PARTITION BY job) AS max_sal_by_job,
         MIN(sal) OVER(PARTITION BY deptno) AS min_sal_by_dept,
         MIN(sal) OVER(PARTITION BY job) AS min_sal_by_job
    FROM emp
   ORDER BY deptno, sal DESC
)
SELECT deptno, ename, job, sal,
       CASE WHEN sal = max_sal_by_dept
            THEN 'TOP SAL IN DEPT'
            WHEN sal = min_sal_by_dept
            THEN 'LOW SAL IN DEPT'
       END AS dept_status,
       CASE WHEN sal = max_sal_by_job
            THEN 'TOP SAL IN JOB'
            WHEN sal = min_sal_by_job
            THEN 'LOW SAL IN JOB'
       END AS job_status
  FROM x
 WHERE sal IN (max_sal_by_dept, max_sal_by_job, min_sal_by_dept, min_sal_by_job);  
```


## Discussion

The first step is to use the window functions `MAX OVER` and `MIN OVER` to find the **highest** and **lowest** salaries by `DEPTNO` and `JOB`:


```SQL
SELECT deptno, ename, job, sal,
       MAX(sal) OVER(PARTITION BY deptno) AS max_dept,
       MAX(sal) OVER(PARTITION BY job) AS max_job,
       MIN(sal) OVER(PARTITION BY deptno) AS min_dept,
       MIN(sal) OVER(PARTITION BY job) AS min_job
  FROM emp
 ORDER BY deptno, sal DESC;
```

|deptno | ename  |    job    | sal  | max_dept | max_job | min_dept | min_job|
|:-----:|:------:|:---------:|:----:|:--------:|:-------:|:--------:|:------:|
|    10 | KING   | PRESIDENT | 5000 |     5000 |    5000 |     1300 |    5000|
|    10 | CLARK  | MANAGER   | 2450 |     5000 |    2975 |     1300 |    2450|
|    10 | MILLER | CLERK     | 1300 |     5000 |    1300 |     1300 |     800|
|    20 | FORD   | ANALYST   | 3000 |     3000 |    3000 |      800 |    3000|
|    20 | SCOTT  | ANALYST   | 3000 |     3000 |    3000 |      800 |    3000|
|    20 | JONES  | MANAGER   | 2975 |     3000 |    2975 |      800 |    2450|
|    20 | ADAMS  | CLERK     | 1100 |     3000 |    1300 |      800 |     800|
|    20 | SMITH  | CLERK     |  800 |     3000 |    1300 |      800 |     800|
|    30 | BLAKE  | MANAGER   | 2850 |     2850 |    2975 |      950 |    2450|
|    30 | ALLEN  | SALESMAN  | 1600 |     2850 |    1600 |      950 |    1250|
|    30 | TURNER | SALESMAN  | 1500 |     2850 |    1600 |      950 |    1250|
|    30 | WARD   | SALESMAN  | 1250 |     2850 |    1600 |      950 |    1250|
|    30 | MARTIN | SALESMAN  | 1250 |     2850 |    1600 |      950 |    1250|
|    30 | JAMES  | CLERK     |  950 |     2850 |    1300 |      950 |     800|


At this point, every `salary` **can be compared with** the `highest` and `lowest` salaries by `DEPTNO` and `JOB`.

Notice that the grouping (the inclusion of multiple columns in the SELECT clause) does not affect the values returned by `MIN OVER` and `MAX OVER`. This is the beauty of window functions: the aggregate is computed over a defined “group” or partition and returns multiple rows for each group.

```SQL
WITH x AS (
  SELECT deptno, ename, job, sal,
         MAX(sal) OVER(PARTITION BY deptno) AS max_sal_by_dept,
         MAX(sal) OVER(PARTITION BY job) AS max_sal_by_job,
         MIN(sal) OVER(PARTITION BY deptno) AS min_sal_by_dept,
         MIN(sal) OVER(PARTITION BY job) AS min_sal_by_job
    FROM emp
   ORDER BY deptno, sal DESC
)
SELECT deptno, ename, job, sal,
       CASE WHEN sal = max_sal_by_dept
            THEN 'TOP SAL IN DEPT'
            WHEN sal = min_sal_by_dept
            THEN 'LOW SAL IN DEPT'
       END AS dept_status,
       CASE WHEN sal = max_sal_by_job
            THEN 'TOP SAL IN JOB'
            WHEN sal = min_sal_by_job
            THEN 'LOW SAL IN JOB'
       END AS job_status
  FROM x
 WHERE sal IN (max_sal_by_dept, max_sal_by_job, min_sal_by_dept, min_sal_by_job);  
```

The last step is to simply wrap the window functions in a CTE and keep only those rows that match the values returned by the window functions. Use a simple CASE expression to display the “status” of each employee in the final result set:

|deptno | ename  |    job    | sal  |   dept_status   |   job_status|
|:-----:|:-------:|:--------:|:-----:|:--------------:|:--------------:|
|    10 | KING   | PRESIDENT | 5000 | TOP SAL IN DEPT | TOP SAL IN JOB|
|    10 | CLARK  | MANAGER   | 2450 |                 | LOW SAL IN JOB|
|    10 | MILLER | CLERK     | 1300 | LOW SAL IN DEPT | TOP SAL IN JOB|
|    20 | FORD   | ANALYST   | 3000 | TOP SAL IN DEPT | TOP SAL IN JOB|
|    20 | SCOTT  | ANALYST   | 3000 | TOP SAL IN DEPT | TOP SAL IN JOB|
|    20 | JONES  | MANAGER   | 2975 |                 | TOP SAL IN JOB|
|    20 | SMITH  | CLERK     |  800 | LOW SAL IN DEPT | LOW SAL IN JOB|
|    30 | BLAKE  | MANAGER   | 2850 | TOP SAL IN DEPT ||
|    30 | ALLEN  | SALESMAN  | 1600 |                 | TOP SAL IN JOB|
|    30 | WARD   | SALESMAN  | 1250 |                 | LOW SAL IN JOB|
|    30 | MARTIN | SALESMAN  | 1250 |                 | LOW SAL IN JOB|
|    30 | JAMES  | CLERK     |  950 | LOW SAL IN DEPT ||
