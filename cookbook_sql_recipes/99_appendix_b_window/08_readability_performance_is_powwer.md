# Readability + Performance = Power

As you can see, window functions are extremely powerful as they allow you to write queries that contain both detailed and aggregate information.

Using window functions allows you **to write smaller, more efficient queries** as compared to using `multiple self-join and/or scalar subqueries`.

Consider the following query, which easily answers all of the following questions:
- **What is the number of employees in each department?**
- **How many different types of employees are in each department** (e.g., how many clerks are in department 10)**?**
- **How many total employees are in table EMP?**”

```SQL
SELECT deptno,
       job,
       COUNT(*) OVER (PARTITION BY deptno) AS emp_cnt,
       COUNT(job) OVER (PARTITION BY deptno,job) AS job_cnt,
       COUNT(*) OVER () AS total
 FROM emp;
```

|deptno |    job    | emp_cnt | job_cnt | total|
|:-----:|:---------:|:-------:|:-------:|:----:|
|    10 | CLERK     |       3 |       1 |    14|
|    10 | MANAGER   |       3 |       1 |    14|
|    10 | PRESIDENT |       3 |       1 |    14|
|    20 | ANALYST   |       5 |       2 |    14|
|    20 | ANALYST   |       5 |       2 |    14|
|    20 | CLERK     |       5 |       2 |    14|
|    20 | CLERK     |       5 |       2 |    14|
|    20 | MANAGER   |       5 |       1 |    14|
|    30 | CLERK     |       6 |       1 |    14|
|    30 | MANAGER   |       6 |       1 |    14|
|    30 | SALESMAN  |       6 |       4 |    14|
|    30 | SALESMAN  |       6 |       4 |    14|
|    30 | SALESMAN  |       6 |       4 |    14|
|    30 | SALESMAN  |       6 |       4 |    14|

Returning the same result set without using window functions would require a bit more work:

```SQL
SELECT a.deptno,
       a.job,
       (SELECT COUNT(*) FROM emp b
         WHERE b.deptno = a.deptno) AS emp_cnt,
       (SELECT COUNT(*) FROM emp b
         WHERE b.deptno = a.deptno AND b.job = a.job) AS job_cnt,
       (SELECT COUNT(*) FROM emp) AS total
  FROM emp a
 ORDER BY 1,2;
```

The nonwindow solution is obviously not difficult to write, yet it certainly is not as clean or efficient (you won’t see performance differences with a 14-row table, but try these queries with, say, a `1,000` - or `10,000-row` **table**, and then you’ll **see the benefit of using window functions** `over multiple self-joins` and `scalar subqueries`).
