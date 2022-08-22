# Pivoting a Result Set into One Row

You want to `take values` **from groups of rows** and `turn those values` **into columns** in a `single row per group`.

## Problem

```SQL
SELECT deptno, empno
  FROM emp
 ORDER BY deptno;
```

|deptno | empno|
|:-----:|:----:|
|    10 |  7934|
|    10 |  7782|
|    10 |  7839|
|    20 |  7788|
|    20 |  7566|
|    20 |  7369|
|    20 |  7876|
|    20 |  7902|
|    30 |  7521|
|    30 |  7844|
|    30 |  7499|
|    30 |  7698|
|    30 |  7654|
|    30 |  7900|

For example, you have a result set displaying the number of employees in each department:

```SQL
SELECT deptno,
       COUNT(empno) AS cnt
  FROM emp
 GROUP BY deptno
 ORDER BY deptno;
```

|deptno | cnt|
|:-----:|:---:|
|    10 |   3|
|    20 |   5|
|    30 |   6|

You would like to reformat the output so that the result set looks as follows:

|deptno_10 | deptno_20 | deptno_30|
|:--------:|:---------:|:--------:|
|        3 |         5 |         6|

## Solution

Transpose the result set using `CASE` and the **aggregate function** `SUM`:

```SQL
SELECT SUM(CASE WHEN deptno = 10 THEN 1 ELSE 0 END) AS deptno_10,
       SUM(CASE WHEN deptno = 20 THEN 1 ELSE 0 END) AS deptno_20,
       SUM(CASE WHEN deptno = 30 THEN 1 ELSE 0 END) AS deptno_30
  FROM emp;
```

- **Solution 2**

```SQL
WITH temp AS (
  SELECT deptno,
         COUNT(empno) AS emp_cnt
    FROM emp
   GROUP BY deptno
)
SELECT MAX(CASE WHEN deptno = 10 THEN emp_cnt ELSE NULL END) AS deptno_10,
       MAX(CASE WHEN deptno = 20 THEN emp_cnt ELSE NULL END) AS deptno_20,
       MAX(CASE WHEN deptno = 30 THEN emp_cnt ELSE NULL END) AS deptno_30
  FROM temp;
```


## Discussion


This example is an excellent introduction to **pivoting**.

1. The concept is simple: for `each row returned by the unpivoted query`, use a **CASE expression to separate the rows into columns**.

2. Then, because this particular problem is to count the number of employees per department, **use the aggregate function** `SUM` **to count the occurrence of each** `DEPTNO`.

If you’re having trouble understanding how this works exactly, execute the query with the aggregate function `SUM` and include `DEPTNO` for readability:

```SQL
SELECT deptno,
       CASE WHEN deptno = 10 THEN 1 ELSE 0 END AS deptno_10,
       CASE WHEN deptno = 20 THEN 1 ELSE 0 END AS deptno_20,
       CASE WHEN deptno = 30 THEN 1 ELSE 0 END AS deptno_30
  FROM emp
 ORDER BY 1;
```


```console
deptno | deptno_10 | deptno_20 | deptno_30    
--------+-----------+-----------+----------         
    10 |         1 |         0 |         0    
    10 |         1 |         0 |         0    
    10 |         1 |         0 |         0    
    -----------------
           Total 3 |    
    --------------------------------------
    20 |         0 |         1 |         0
    20 |         0 |         1 |         0
    20 |         0 |         1 |         0
    20 |         0 |         1 |         0
    20 |         0 |         1 |         0
    ----------------------------
                       Total 5 |
    --------------------------------------
    30 |         0 |         0 |         1
    30 |         0 |         0 |         1
    30 |         0 |         0 |         1
    30 |         0 |         0 |         1
    30 |         0 |         0 |         1
    30 |         0 |         0 |         1
    --------------------------------------
                                 Total   6
```

You can think of each `CASE` expression as a **flag** to determine which `DEPTNO` **a row belongs to**. At this point, the “**rows to columns**” `transformation is already done`;

- the next step is to simply sum the values returned by `DEPTNO_10`, `DEPTNO_20`, and `DEPTNO_30`, and then to group by `DEPTNO`. The following are the results:

```SQL
SELECT deptno,
       SUM(CASE WHEN deptno = 10 THEN 1 ELSE 0 END) AS deptno_10,
       SUM(CASE WHEN deptno = 20 THEN 1 ELSE 0 END) AS deptno_20,
       SUM(CASE WHEN deptno = 30 THEN 1 ELSE 0 END) AS deptno_30
  FROM emp
 GROUP BY deptno
 ORDER BY deptno;
```

|deptno | deptno_10 | deptno_20 | deptno_30|
|:-----:|:---------:|:---------:|:--------:|
|    10 |         3 |         0 |         0|
|    20 |         0 |         5 |         0|
|    30 |         0 |         0 |         6|


If you inspect this result set, you see that logically the output makes sense; for example, `DEPTNO 10` **has three employees** in `DEPTNO_10` and **zero in the other departments**.

```SQL
SELECT SUM(CASE WHEN deptno = 10 THEN 1 ELSE 0 END) AS deptno_10,
       SUM(CASE WHEN deptno = 20 THEN 1 ELSE 0 END) AS deptno_20,
       SUM(CASE WHEN deptno = 30 THEN 1 ELSE 0 END) AS deptno_30
  FROM emp;
```

Since the goal is to **return one row**, the last step is to remove the `DEPTNO` and `GROUP BY` clause and **simply sum the** `CASE` expressions:

|deptno_10 | deptno_20 | deptno_30|
|:--------:|:---------:|:--------:|
|        3 |         5 |         6|

**Solution 2**:

The following is another approach that you may sometimes see applied to this same sort of problem:

```SQL
SELECT deptno,
       COUNT(empno) AS emp_cnt
  FROM emp
 GROUP BY deptno;
```

|deptno | emp_cnt|
|:-----:|:------:|
|    30 |       6|
|    10 |       3|
|    20 |       5|


```SQL
WITH temp AS (
  SELECT deptno,
         COUNT(empno) AS emp_cnt
    FROM emp
   GROUP BY deptno
)
SELECT deptno,
       CASE WHEN deptno = 10 THEN emp_cnt ELSE NULL END AS deptno_10,
       CASE WHEN deptno = 20 THEN emp_cnt ELSE NULL END AS deptno_20,
       CASE WHEN deptno = 30 THEN emp_cnt ELSE NULL END AS deptno_30
  FROM temp
 ORDER BY 1;
```

|deptno | deptno_10 | deptno_20 | deptno_30|
|:-----:|:---------:|:----------:|:-------:|
|    10 |         3 |           ||
|    20 |           |         5 ||
|    30 |           |           |         6|

```SQL
WITH temp AS (
  SELECT deptno,
         COUNT(empno) AS emp_cnt
    FROM emp
   GROUP BY deptno
)
SELECT MAX(CASE WHEN deptno = 10 THEN emp_cnt ELSE NULL END) AS deptno_10,
       MAX(CASE WHEN deptno = 20 THEN emp_cnt ELSE NULL END) AS deptno_20,
       MAX(CASE WHEN deptno = 30 THEN emp_cnt ELSE NULL END) AS deptno_30
  FROM temp;
```

Then the MAX functions collapses the columns into one row:

|deptno_10 | deptno_20 | deptno_30|
|:--------:|:---------:|:--------:|
|        3 |         5 |         6|
