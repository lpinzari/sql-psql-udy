# Counting Rows in a Table

You want to **count the number of rows in a table**, or you want to **count the number of values in a column**.

## Problem

For example, you want to find the **total** `number of employees` as well as `the number of employees` in **each** `department`.

## Solution

When **counting rows** where the `whole table is the group or window`, simply use the `COUNT` function **along with the** `*` **character**:

```SQL
SELECT COUNT(*) count_all
  FROM emp;
```

|count_all|
|-------|
|   14|

When **creating multiple groups**, or windows of data, use the `COUNT` function with the `GROUP BY` clause:

```SQL
SELECT deptno,
       COUNT(*)
  FROM emp
 GROUP BY deptno
 ORDER BY deptno;
```

|deptno | count|
|:-----:|:----:|
|    10 |     3|
|    20 |     5|
|    30 |     6|

## Discussion

When `counting the number of employees` **for each** `department`, you are creating `groups or “windows” of data`. Each employee found increments the count by one to produce a total for their respective department. This is an example of aggregation in SQL because detailed information, such as each individual employee’s salary or job, is not the focus; **the focus is the end result for each department**.


It is important to note that the `COUNT` function

- **will ignore** `NULLs` **when passed a column name as an argument**,
- but **will include** `NULLs` **when passed the * character or any constant**;

consider the following:

```SQL
SELECT deptno, comm
  FROM emp
 ORDER BY deptno, comm;
```

|deptno | comm|
|:-----:|:-----:|
|    10 | NULL|
|    10 | NULL|
|    10 | NULL|
|    20 | NULL|
|    20 | NULL|
|    20 | NULL|
|    20 | NULL|
|    20 | NULL|
|    30 |    0|
|    30 |  300|
|    30 |  500|
|    30 | 1400|
|    30 | NULL|
|    30 | NULL|

**(14 rows)**

```SQL
SELECT COUNT(*) AS tot_rows,
       COUNT(deptno) AS tot_deptno,
       COUNT(comm) AS tot_comm,
       COUNT('hello') AS count_hello
  FROM emp;
```

|tot_rows | tot_deptno | tot_comm | count_hello|
|:-------:|:----------:|:--------:|:-----:|
|      14 |         14 |        4 |    14|

```SQL
SELECT deptno,
       COUNT(*) AS tot_rows,
       COUNT(comm) AS tot_comm,
       COUNT('hello') AS count_hello
  FROM emp
 GROUP BY deptno
 ORDER BY deptno;
```

|deptno | tot_rows | tot_comm | count_hello|
|:-----:|:--------:|:----------:|:----------:|
|    10 |        3 |          0 |           3|
|    20 |        5 |          0 |           5|
|    30 |        6 |          4 |           6|

|deptno | comm|
|:-----:|:-----:|
|    10 | NULL|
|    10 | NULL|
|    10 | NULL|


If all rows are `null` for the column passed to `COUNT` or if the table is empty, `COUNT` **will return zero**.

```console
cookbook=> \d emp
                        Table "public.emp"
  Column  |         Type          | Collation | Nullable | Default
----------+-----------------------+-----------+----------+---------
 empno    | integer               |           | not null |
 ename    | character varying(10) |           |          |
 job      | character varying(9)  |           |          |
 mgr      | integer               |           |          |
 hiredate | date                  |           |          |
 sal      | integer               |           |          |
 comm     | integer               |           |          |
 deptno   | integer               |           |          |
Indexes:
    "emp_pkey" PRIMARY KEY, btree (empno)
```

```SQL
SELECT COUNT(*)
  FROM emp;
```

```SQL
SELECT COUNT(*)
  FROM (SELECT DISTINCT empno,ename,job,mgr,hiredate,sal,comm,deptno
          FROM emp) AS temp;
```

```SQL
SELECT COUNT(empno)
  FROM emp;
```

It should also be noted that, the `COUNT(*)` function counts the **number of records in the table** or `cardinality`. This function is equivalent to count the number of distinct rows in the table or **the number of keys value in the table**.
