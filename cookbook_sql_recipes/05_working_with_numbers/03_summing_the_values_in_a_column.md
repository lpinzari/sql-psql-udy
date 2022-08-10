# Summing the Values in a Column

You want to compute the **sum of all values**, such as all `employee salaries`, in a column.

## Solution

When computing a **sum** where the `whole table is the group or window`, just apply the `SUM` function to the **columns you are interested in** without using the GROUP BY clause:

```SQL
SELECT ROUND(SUM(sal),2) tot_sal
  FROM emp;
```

|tot_sal|
|:--------:|
|29025.00|

When creating **multiple groups or windows of data**, use the `SUM` function with the `GROUP BY` clause. The following example **sums** employee `salaries` **by department**:

```SQL
SELECT deptno,
       SUM(sal) AS total_for_dept
  FROM emp
 GROUP BY deptno;
```

|deptno | total_for_dept|
|:-----:|:-------------:|
|    30 |           9400|
|    10 |           8750|
|    20 |          10875|

## Discussion

When searching for the **sum** of `all salaries` **for each department**, you are `creating groups or “windows” of data`.

Each employee’s salary is added together to produce a total for their respective department. This is an example of aggregation in SQL because detailed information, such as each individual employee’s salary, is not the focus; **the focus is the end result for each department**.

```SQL
SELECT deptno, comm
  FROM emp
 WHERE deptno IN (10,30)
 ORDER BY 1;
```

|deptno | comm|
|:-----:|:---:|
|    10 | NULL|
|    10 | NULL|
|    10 | NULL|
|    30 | NULL|
|    30 | NULL|
|    30 |  300|
|    30 |    0|
|    30 |  500|
|    30 | 1400|

It is important to note that the `SUM` **function will ignore** `NULLs`, but you can `have NULL groups`, which can be seen here. `DEPTNO 10` does not have any employees who earn a commission; thus, grouping by `DEPTNO 10` while attempting to `SUM` the values in `COMM` will result in a group with a `NULL` value returned by `SUM`:

```SQL
SELECT SUM(comm)
  FROM emp;
```

|sum|
|:----:|
|2200|

```SQL
SELECT deptno,
       SUM(comm)
  FROM emp
 WHERE deptno IN (10,30)
 GROUP BY deptno;
```

|deptno | sum|
|:-----:|:----:|
|    10 | NULL|
|    30 | 2200|

```SQL
SELECT deptno,
       SUM(COALESCE(comm,0))
  FROM emp
 WHERE deptno IN (10,30)
 GROUP BY deptno;
```

|deptno | sum|
|:-----:|:----:|
|    10 |    0|
|    30 | 2200|
