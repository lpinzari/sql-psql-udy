# Calculating Subtotals for All Possible Expression Combinations


You want to find the `sum of all salaries`
- **by DEPTNO**, and
- **by JOB**, for every `JOB/ DEPTNO` combination.

You also want a `grand total` for **all salaries in table** `EMP`.

You want to return the following result set:

|deptno |    job    |       category        |  sal|
|:-----:|:---------:|:---------------------:|:-----:|
|    10 | CLERK     | TOTAL BY DEPT AND JOB |  1300|
|    10 | MANAGER   | TOTAL BY DEPT AND JOB |  2450|
|    10 | PRESIDENT | TOTAL BY DEPT AND JOB |  5000|
|    20 | ANALYST   | TOTAL BY DEPT AND JOB |  6000|
|    20 | CLERK     | TOTAL BY DEPT AND JOB |  1900|
|    20 | MANAGER   | TOTAL BY DEPT AND JOB |  2975|
|    30 | CLERK     | TOTAL BY DEPT AND JOB |   950|
|    30 | MANAGER   | TOTAL BY DEPT AND JOB |  2850|
|    30 | SALESMAN  | TOTAL BY DEPT AND JOB |  5600|
|       | ANALYST   | TOTAL BY JOB          |  6000|
|       | CLERK     | TOTAL BY JOB          |  4150|
|       | MANAGER   | TOTAL BY JOB          |  8275|
|       | PRESIDENT | TOTAL BY JOB          |  5000|
|       | SALESMAN  | TOTAL BY JOB          |  5600|
|    10 |           | TOTAL BY DEPT         |  8750|
|    20 |           | TOTAL BY DEPT         | 10875|
|    30 |           | TOTAL BY DEPT         |  9400|
|       |           | GRAND TOTAL FOR TABLE | 29025|


## Solution

Extensions added to `GROUP BY` in recent years make this a fairly easy problem to solve. If your platform does not supply such extensions for computing various levels of subtotals, then you must compute them manually (via self-joins or scalar subqueries).

Use the CUBE extension to the GROUP BY clause with the concatenation operator:

```SQL
SELECT deptno,
       job,
       CASE GROUPING(deptno)::CHAR || GROUPING(job)::CHAR
            WHEN '00' THEN 'TOTAL BY DEPT AND JOB'
            WHEN '01' THEN 'TOTAL BY DEPT'
            WHEN '10' THEN 'TOTAL BY JOB'
            WHEN '11' THEN 'GRAND TOTAL FOR TABLE'
       END AS category,
       SUM(sal) AS sal
  FROM emp
 GROUP BY CUBE(deptno, job)
 ORDER BY GROUPING(job), GROUPING(deptno),deptno, job;
```

Use `GROPING SETS` clause:

```SQL
SELECT deptno,
       job,
       CASE GROUPING(deptno)::CHAR || GROUPING(job)::CHAR
            WHEN '00' THEN 'TOTAL BY DEPT AND JOB'
            WHEN '01' THEN 'TOTAL BY DEPT'
            WHEN '10' THEN 'TOTAL BY JOB'
            WHEN '11' THEN 'GRAND TOTAL FOR TABLE'
       END AS category,
       SUM(sal) AS sal
  FROM emp
 GROUP BY GROUPING SETS((deptno),(job),(deptno,job),())
 ORDER BY GROUPING(job), GROUPING(deptno), deptno, job;
```

## Discussion

```SQL
SELECT deptno, SUM(sal) AS sal            SELECT job, SUM(sal) AS sal        
  FROM emp                                  FROM emp
 GROUP BY ROLLUP(deptno)                   GROUP BY ROLLUP(job)
 ORDER BY deptno;                          ORDER BY job;
```
```console
|deptno |  sal |                   | job      |  sal |
|:-----:|:----:|                   |:--------:|:----:|
|    10 |  8750|                   |ANALYST   |  6000|
|    20 | 10875|                   |CLERK     |  4150|
|    30 |  9400|                   |MANAGER   |  8275|
|       | 29025|                   |PRESIDENT |  5000|
                                   |SALESMAN  |  5600|
                                   |          | 29025|
```

The first step is to use the aggregate function `SUM` and **group by** both `DEPTNO` and `JOB` to find the total salaries for each `DEPTNO` and `JOB` combination:

```SQL
SELECT deptno, job,    
       SUM(sal)
  FROM emp
 GROUP BY deptno, job
 ORDER BY deptno, job;

SELECT job, deptno,    
       SUM(sal)
  FROM emp
 GROUP BY job, deptno
 ORDER BY deptno, job;
```

|deptno |    job    | sum|
|:-----:|:---------:|:---:|
|    10 | CLERK     | 1300|
|    10 | MANAGER   | 2450|
|    10 | PRESIDENT | 5000|
|    20 | ANALYST   | 6000|
|    20 | CLERK     | 1900|
|    20 | MANAGER   | 2975|
|    30 | CLERK     |  950|
|    30 | MANAGER   | 2850|
|    30 | SALESMAN  | 5600|

The next step is to create `subtotals` by `DEPTNO` and `JOB` along with the **grand total** for `the whole table`. Similarly, create `subtotals` by `JOB` and `DEPTNO`.

```SQL
SELECT deptno, job,               SELECT job, deptno,
       SUM(sal)                          SUM(sal)
  FROM emp                          FROM emp
 GROUP BY ROLLUP(deptno, job)      GROUP BY ROLLUP(job, deptno)
 ORDER BY deptno,job;              ORDER BY job,deptno;
```

```console
                  GROUPING(DEPTNO)                       GROUPING(JOB)
                  deptno_subtotals                       job_subtotals
+--------------------------+         +--------------------------+
|deptno |    job    |  sum | CUBE    |job       | deptno | sum  | CUBE
|:-----:|:---------:|:----:|         |:--------:|:------:|:----:|
|    10 | CLERK     |  1300|         |ANALYST   |     20 |  6000|
|    10 | MANAGER   |  2450|         |ANALYST   |        |  6000|<--*
|    10 | PRESIDENT |  5000|         |CLERK     |     10 |  1300|
|    10 |           |  8750|<--*     |CLERK     |     20 |  1900|
|    20 | ANALYST   |  6000|         |CLERK     |     30 |   950|
|    20 | CLERK     |  1900|         |CLERK     |        |  4150|<--*
|    20 | MANAGER   |  2975|         |MANAGER   |     10 |  2450|
|    20 |           | 10875|<--*     |MANAGER   |     20 |  2975|
|    30 | CLERK     |   950|         |MANAGER   |     30 |  2850|
|    30 | MANAGER   |  2850|         |MANAGER   |        |  8275|<--*
|    30 | SALESMAN  |  5600|         |PRESIDENT |     10 |  5000|
|    30 |           |  9400|<--*     |PRESIDENT |        |  5000|<--*
|       |           | 29025|<--*     |SALESMAN  |     30 |  5600|
+--------------------------+         |SALESMAN  |        |  5600|<--*
                                     |          |        | 29025|<--*
                                     +--------------------------+
```

Next, use the [GROUPING](https://github.com/lpinzari/sql-psql-udy/blob/master/04_sql_aggregations/11_grouping_sets.md) function in conjunction with `CASE` to format the results into more meaningful output.

Use the `CUBE` extension to the `GROUP BY` clause to perform aggregations on SAL by `DEPTNO, JOB`, and for the whole table; as well as aggregations on SAL by `JOB, DEPTNO`.

Use the `CUBE` function to combine the use of the `ROLLUP(deptno, job)` and `ROLLUP(job, deptno)`.

Use the `GROUPING` function in the `DEPTNO` column to display a label for the subtotals by `department` and `grand total` for the whole table.

The value from `GROUPING(DEPTNO)` will be **1** or **0** depending on whether the values for `SAL` are due to the `GROUP BY` or the `CUBE`.

The `GROUPING(DEPTNO)` function returns bit
- **0** if the `argument is a member of the current grouping set`, (`DEPTNO`),and
- **1** `otherwise`, (`JOB`) in this case.

The same goes for `GROUPING(JOB)`.

The `GROUPING(JOB)` function returns bit
- **0** if the `argument is a member of the current grouping set`, (`JOB`),and
- **1** `otherwise`, (`DEPTNO`) in this case.

```SQL
SELECT deptno,
       job,
       GROUPING(deptno) is_deptno_subtotal,
       GROUPING(job) is_job_subtotal,
       SUM(sal) AS sal
  FROM emp
 GROUP BY CUBE(deptno, job)
 ORDER BY 3,4;
```

```console
+-----------------------------------------------------------------+
|deptno |    job    | is_deptno_subtotal | is_job_subtotal |  sal |
|:-----:|:---------:|:------------------:|:---------------:|:----:|
|    30 | CLERK     |                  0 |               0 |   950|
|    20 | CLERK     |                  0 |               0 |  1900|
|    30 | MANAGER   |                  0 |               0 |  2850|
|    10 | MANAGER   |                  0 |               0 |  2450|
|    10 | PRESIDENT |                  0 |               0 |  5000|
|    20 | ANALYST   |                  0 |               0 |  6000|
|    30 | SALESMAN  |                  0 |               0 |  5600|
|    10 | CLERK     |                  0 |               0 |  1300|
|    20 | MANAGER   |                  0 |               0 |  2975|
--------------------------------------------------------------------
|    10 |           |                  0 |               1 |  8750|
|    30 |           |                  0 |               1 |  9400|
|    20 |           |                  0 |               1 | 10875|
--------------------------------------------------------------------
|       | ANALYST   |                  1 |               0 |  6000|
|       | CLERK     |                  1 |               0 |  4150|
|       | PRESIDENT |                  1 |               0 |  5000|
|       | MANAGER   |                  1 |               0 |  8275|
|       | SALESMAN  |                  1 |               0 |  5600|
--------------------------------------------------------------------
|       |           |                  1 |               1 | 29025|
```

If `DEPTNO_SUBTOTALS` is **0** and `JOB_SUBTOTALS` is **1** (in which case `JOB` is `NULL`), the value of `SAL` **represents a subtotal of salaries by** `DEPTNO` created by `CUBE`.

If `JOB_SUBTOTALS` is **0** and `DEPTNO_SUBTOTALS` is **1** (in which case `DEPTNO` is `NULL`), the value of `SAL` **represents a subtotal of salaries by** `JOB` created by `CUBE`.

Rows with **0** for `both DEPTNO_SUBTOTALS and JOB_SUBTOTALS` **represent rows created by regular aggregation** (the sum of SAL for each `DEPTNO/JOB combination`).

The final step is to use a `CASE` expression to determine which category each row belongs to based on the values returned by `GROUPING(JOB)` and `GROUPING(DEPTNO)` concatenated:

```SQL
SELECT deptno,
       job,
       CASE GROUPING(deptno)::CHAR || GROUPING(job)::CHAR
            WHEN '00' THEN 'TOTAL BY DEPT AND JOB'
            WHEN '01' THEN 'TOTAL BY DEPT'
            WHEN '10' THEN 'TOTAL BY JOB'
            WHEN '11' THEN 'GRAND TOTAL FOR TABLE'
       END AS category,
       SUM(sal) AS sal
  FROM emp
 GROUP BY CUBE(deptno, job)
 ORDER BY GROUPING(job), GROUPING(deptno),deptno, job;
```

|deptno |    job    |       category        |  sal|
|:-----:|:---------:|:---------------------:|:-----:|
|    10 | CLERK     | TOTAL BY DEPT AND JOB |  1300|
|    10 | MANAGER   | TOTAL BY DEPT AND JOB |  2450|
|    10 | PRESIDENT | TOTAL BY DEPT AND JOB |  5000|
|    20 | ANALYST   | TOTAL BY DEPT AND JOB |  6000|
|    20 | CLERK     | TOTAL BY DEPT AND JOB |  1900|
|    20 | MANAGER   | TOTAL BY DEPT AND JOB |  2975|
|    30 | CLERK     | TOTAL BY DEPT AND JOB |   950|
|    30 | MANAGER   | TOTAL BY DEPT AND JOB |  2850|
|    30 | SALESMAN  | TOTAL BY DEPT AND JOB |  5600|
|       | ANALYST   | TOTAL BY JOB          |  6000|
|       | CLERK     | TOTAL BY JOB          |  4150|
|       | MANAGER   | TOTAL BY JOB          |  8275|
|       | PRESIDENT | TOTAL BY JOB          |  5000|
|       | SALESMAN  | TOTAL BY JOB          |  5600|
|    10 |           | TOTAL BY DEPT         |  8750|
|    20 |           | TOTAL BY DEPT         | 10875|
|    30 |           | TOTAL BY DEPT         |  9400|
|       |           | GRAND TOTAL FOR TABLE | 29025|

- **Solution 2**:

There is an additional extension to `GROUP BY` called `GROUPING SETS`; this extension is extremely useful. For example, you can use [GROUPING SETS](https://github.com/lpinzari/sql-psql-udy/blob/master/04_sql_aggregations/11_grouping_sets.md) to mimic the output created by `CUBE` as is shown here:

```SQL
SELECT deptno,
       job,
       CASE GROUPING(deptno)::CHAR || GROUPING(job)::CHAR
            WHEN '00' THEN 'TOTAL BY DEPT AND JOB'
            WHEN '01' THEN 'TOTAL BY DEPT'
            WHEN '10' THEN 'TOTAL BY JOB'
            WHEN '11' THEN 'GRAND TOTAL FOR TABLE'
       END AS category,
       SUM(sal) AS sal
  FROM emp
 GROUP BY GROUPING SETS((deptno),(job),(deptno,job),())
 ORDER BY GROUPING(job), GROUPING(deptno), deptno, job;
```

What’s great about `GROUPING SETS` is that it allows you to **define the groups**. The `GROUPING SETS` clause in the preceding query causes groups to be created by `DEPTNO`, by `JOB`, and by the `combination of DEPTNO and JOB`, and finally the `empty parentheses` requests a grand total.

`GROUPING SETS` gives you enormous flexibility for creating reports with different levels of aggregation; for example, if you wanted to modify the preceding example to **exclude the GRAND TOTAL**, simply modify the GROUPING SETS clause by excluding the empty parentheses:

```SQL
SELECT deptno,
       job,
       CASE GROUPING(deptno)::CHAR || GROUPING(job)::CHAR
            WHEN '00' THEN 'TOTAL BY DEPT AND JOB'
            WHEN '01' THEN 'TOTAL BY DEPT'
            WHEN '10' THEN 'TOTAL BY JOB'
            WHEN '11' THEN 'GRAND TOTAL FOR TABLE'
       END AS category,
       SUM(sal) AS sal
  FROM emp
 GROUP BY GROUPING SETS((deptno),(job),(deptno,job))
 ORDER BY GROUPING(job), GROUPING(deptno), deptno, job;
```

|deptno |    job    |       category        |  sal|
|:-----:|:---------:|:---------------------:|:----:|
|    10 | CLERK     | TOTAL BY DEPT AND JOB |  1300|
|    10 | MANAGER   | TOTAL BY DEPT AND JOB |  2450|
|    10 | PRESIDENT | TOTAL BY DEPT AND JOB |  5000|
|    20 | ANALYST   | TOTAL BY DEPT AND JOB |  6000|
|    20 | CLERK     | TOTAL BY DEPT AND JOB |  1900|
|    20 | MANAGER   | TOTAL BY DEPT AND JOB |  2975|
|    30 | CLERK     | TOTAL BY DEPT AND JOB |   950|
|    30 | MANAGER   | TOTAL BY DEPT AND JOB |  2850|
|    30 | SALESMAN  | TOTAL BY DEPT AND JOB |  5600|
|       | ANALYST   | TOTAL BY JOB          |  6000|
|       | CLERK     | TOTAL BY JOB          |  4150|
|       | MANAGER   | TOTAL BY JOB          |  8275|
|       | PRESIDENT | TOTAL BY JOB          |  5000|
|       | SALESMAN  | TOTAL BY JOB          |  5600|
|    10 |           | TOTAL BY DEPT         |  8750|
|    20 |           | TOTAL BY DEPT         | 10875|
|    30 |           | TOTAL BY DEPT         |  9400|

You can also eliminate a subtotal, such as the one on `DEPTNO`, simply by omitting (DEPTNO) from the `GROUPING SETS` clause:

```SQL
SELECT deptno,
       job,
       CASE GROUPING(deptno)::CHAR || GROUPING(job)::CHAR
            WHEN '00' THEN 'TOTAL BY DEPT AND JOB'
            WHEN '01' THEN 'TOTAL BY DEPT'
            WHEN '10' THEN 'TOTAL BY JOB'
            WHEN '11' THEN 'GRAND TOTAL FOR TABLE'
       END AS category,
       SUM(sal) AS sal
  FROM emp
 GROUP BY GROUPING SETS((job),(deptno,job))
 ORDER BY GROUPING(job), GROUPING(deptno), deptno, job;
```

|deptno |    job    |       category        | sal|
|:-----:|:---------:|:---------------------:|:---:|
|    10 | CLERK     | TOTAL BY DEPT AND JOB | 1300|
|    10 | MANAGER   | TOTAL BY DEPT AND JOB | 2450|
|    10 | PRESIDENT | TOTAL BY DEPT AND JOB | 5000|
|    20 | ANALYST   | TOTAL BY DEPT AND JOB | 6000|
|    20 | CLERK     | TOTAL BY DEPT AND JOB | 1900|
|    20 | MANAGER   | TOTAL BY DEPT AND JOB | 2975|
|    30 | CLERK     | TOTAL BY DEPT AND JOB |  950|
|    30 | MANAGER   | TOTAL BY DEPT AND JOB | 2850|
|    30 | SALESMAN  | TOTAL BY DEPT AND JOB | 5600|
|       | ANALYST   | TOTAL BY JOB          | 6000|
|       | CLERK     | TOTAL BY JOB          | 4150|
|       | MANAGER   | TOTAL BY JOB          | 8275|
|       | PRESIDENT | TOTAL BY JOB          | 5000|
|       | SALESMAN  | TOTAL BY JOB          | 5600|

As you can see, GROUPING SETS makes it easy indeed to play around with totals and subtotals to look at your data from different angles.
