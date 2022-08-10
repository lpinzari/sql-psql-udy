# Providing a Base

Besides readability and performance, window functions are useful for providing a “**base**” `for more complex` “**report-style**” `queries`.

For example, consider the following “**report-style**” query that uses **window functions in an inline view** and then **aggregates the results in an outer query**.

Using window functions allows you to return detailed as well as aggregate data, which is **useful for reports**.

The following query uses window functions to **find counts using different partitions**. Because the aggregation is applied to multiple rows, the inline view returns all rows from `EMP`, which **the outer** `CASE` **expressions can use to transpose and create a formatted report**:

```SQL
WITH x AS (
  SELECT deptno,
         job,
         COUNT(*) OVER (PARTITION BY deptno) AS emp_cnt,
         COUNT(job) OVER (PARTITION BY deptno,job) AS job_cnt,
         COUNT(*) OVER () AS total
    FROM emp
)
SELECT deptno,
       emp_cnt AS dept_total,
       total,
       MAX(CASE WHEN job = 'CLERK'
                THEN job_cnt ELSE 0 END) AS clerks,
       MAX(CASE WHEN job = 'MANAGER'
                THEN job_cnt ELSE 0 END) AS mgrs,
       MAX(CASE WHEN job = 'PRESIDENT'
                THEN job_cnt ELSE 0 END) AS prez,
       MAX(CASE WHEN job = 'ANALYST'
                THEN job_cnt ELSE 0 END) AS anals,
       MAX(CASE WHEN job = 'SALESMAN'
                THEN job_cnt ELSE 0 END) AS smen
  FROM x
 GROUP BY deptno, emp_cnt, total;
```

|deptno | dept_total | total | clerks | mgrs | prez | anals | smen|
|:-----:|:----------:|:-----:|:------:|:-----:|:----:|:----:|:---:|
|    10 |          3 |    14 |      1 |    1 |    1 |     0 |    0|
|    30 |          6 |    14 |      1 |    1 |    0 |     0 |    4|
|    20 |          5 |    14 |      2 |    1 |    0 |     2 |    0|

The previous query returns each
- department,
- the total number of employees in `each department`, (total number of rows to be precise)
- the total number of employees in table `EMP`(number of rows!),
- and a breakdown of the number of different job types in each department.

All this is done in one query, without additional joins or temp tables!

As a final example of how easily multiple questions can be answered using window functions, consider the following query:

```SQL
SELECT ename AS name,
       sal,
       MAX(sal) OVER(PARTITION BY deptno) AS hiDpt,
       MIN(sal) OVER(PARTITION BY deptno) AS loDpt,
       MAX(sal) OVER(PARTITION BY job) AS hiJob,
       MIN(sal) OVER(PARTITION BY job) AS loJob,
       MAX(sal) OVER() AS hi,
       MIN(sal) OVER() AS lo,
       SUM(sal) OVER(PARTITION BY deptno
                         ORDER BY sal,empno) AS dptRT,
       SUM(sal) OVER(PARTITION BY deptno) AS dptSum,
       SUM(sal) OVER() AS ttl
 FROM emp
ORDER BY deptno,dptRT;
```

This query answers the following questions easily, efficiently, and readably (and without additional joins to EMP!). Simply match the employee and their salary with the different rows in the result set to determine:

- Who makes the highest salary of all employees (HI)
- Who makes the lowest salary of all employees (LO)
- Who makes the highest salary in the department (HIDPT)
- Who makes the lowest salary in the department (LODPT)
- Who makes the highest salary in their job (HIJOB)
- Who makes the lowest salary in their job (LOJOB)
- What is the sum of all salaries (TTL)
- What is the sum of salaries per department (DPTSUM)
- What is the running total of all salaries per department (DPTRT)

|name  | sal  | hidpt | lodpt | hijob | lojob |  hi  | lo  | dptrt | dptsum |  ttl|
|-----:|:-----:|:-----:|:----:|:-----:|:-----:|:-----:|:--:|:-----:|:------:|:----:|
|MILLER | 1300 |  5000 |  1300 |  1300 |   800 | 5000 | 800 |  1300 |   8750 | 29025|
|CLARK  | 2450 |  5000 |  1300 |  2975 |  2450 | 5000 | 800 |  3750 |   8750 | 29025|
|KING   | 5000 |  5000 |  1300 |  5000 |  5000 | 5000 | 800 |  8750 |   8750 | 29025|
|SMITH  |  800 |  3000 |   800 |  1300 |   800 | 5000 | 800 |   800 |  10875 | 29025|
|ADAMS  | 1100 |  3000 |   800 |  1300 |   800 | 5000 | 800 |  1900 |  10875 | 29025|
|JONES  | 2975 |  3000 |   800 |  2975 |  2450 | 5000 | 800 |  4875 |  10875 | 29025|
|SCOTT  | 3000 |  3000 |   800 |  3000 |  3000 | 5000 | 800 |  7875 |  10875 | 29025|
|FORD   | 3000 |  3000 |   800 |  3000 |  3000 | 5000 | 800 | 10875 |  10875 | 29025|
|JAMES  |  950 |  2850 |   950 |  1300 |   800 | 5000 | 800 |   950 |   9400 | 29025|
|WARD   | 1250 |  2850 |   950 |  1600 |  1250 | 5000 | 800 |  2200 |   9400 | 29025|
|MARTIN | 1250 |  2850 |   950 |  1600 |  1250 | 5000 | 800 |  3450 |   9400 | 29025|
|TURNER | 1500 |  2850 |   950 |  1600 |  1250 | 5000 | 800 |  4950 |   9400 | 29025|
|ALLEN  | 1600 |  2850 |   950 |  1600 |  1250 | 5000 | 800 |  6550 |   9400 | 29025|
|BLAKE  | 2850 |  2850 |   950 |  2975 |  2450 | 5000 | 800 |  9400 |   9400 | 29025|
