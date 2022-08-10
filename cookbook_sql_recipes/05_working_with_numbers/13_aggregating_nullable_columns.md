# Aggregating Nullable Columns

You want to **perform an aggregation on a column**, but the column is **nullable**.

You want the accuracy of your aggregation to be preserved, but are concerned because **aggregate functions ignore** `NULLs`.

## Problem

```SQL
SELECT deptno, comm
  FROM emp
 WHERE deptno = 30;
```

|deptno | comm|
|:-----:|:---:|
|    30 |  300|
|    30 |  500|
|    30 | 1400|
|    30 | NULL|
|    30 |    0|
|    30 | NULL|


For example, you want to determine the `average commission` for employees in `DEPTNO 30`, but there are some employees who do not earn a commission (**COMM** is `NULL` for those employees). Because NULLs are ignored by aggregates, **the accuracy of the output is compromised**.

You would like to somehow **include** `NULL` **values in your aggregation**.

## Solution

Use the [COALESCE](https://github.com/lpinzari/sql-psql-udy/blob/master/07_data_cleaning/10_coalesce.md) function to **convert** `NULLs` **to** `zero` so they will be included in the aggregation:

```SQL
SELECT ROUND(AVG(COALESCE(comm,0)),2) AS avg_comm
  FROM emp
 WHERE deptno = 30;
```

|avg_comm|
|:-------:|
|  366.67|

## Discussion

When working with aggregate functions, keep in mind that `NULLs` are ignored. Con‐ sider the output of the solution without using the `COALESCE` function:

```SQL
SELECT ROUND(AVG(comm),2) AS avg_comm
  FROM emp
 WHERE deptno = 30;
```

|avg_comm|
|:------:|
|  550.00|

This query shows an average commission of `550` for `DEPTNO 30`, but a quick exami‐ nation of those rows:

```SQL
SELECT ename, comm
  FROM emp
 WHERE deptno = 30
 ORDER BY comm DESC;  
```

|ename  | comm|
|:-----:|:---:|
|BLAKE  | NULL|
|JAMES  | NULL|
|MARTIN | 1400|
|WARD   |  500|
|ALLEN  |  300|
|TURNER |    0|

shows that only four of the six employees can earn a commission. The sum of all commissions in `DEPTNO 30` is `2200`, and the average should be `2200/6`, not `2200/4`.

By excluding the `COALESCE` function, you answer the question “**What is the average commission of employees in DEPTNO 30 who can earn a commission?**” rather than “**What is the average commission of all employees in DEPTNO 30?**” When working with aggregates, remember to treat NULLs accordingly.
