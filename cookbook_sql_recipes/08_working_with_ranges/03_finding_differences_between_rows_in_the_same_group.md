# Finding Differences Between Rows in the Same Group or Partition

You want to return the
- `DEPTNO`, `ENAME`, and `SAL` of **each employee** along with the
- **difference in** `SAL` **between employees in the same department** (i.e., having the same value for `DEPTNO`).

The **difference** should be `between` each **current employee** `and` **the employee hired immediately afterward** (you want to see if there is a correlation between seniority and salary on a “per department” basis).

```console
cookbook=# SELECT deptno, ename, sal, hiredate
cookbook-#   FROM emp
cookbook-#  ORDER BY deptno, hiredate;
```

| deptno | ename  | sal  |  hiredate|
|:------:|:------:|:----:|:---------:|
|     10 | CLARK  | 2450 | 2006-06-09|
|     10 | KING   | 5000 | 2006-11-17|
|     10 | MILLER | 1300 | 2007-01-23|
|     20 | JONES  | 2975 | 2006-04-02|
|     20 | FORD   | 3000 | 2006-12-03|
|     20 | SCOTT  | 3000 | 2007-12-09|
|     20 | ADAMS  | 1100 | 2008-01-12|
|     20 | SMITH  |  800 | 2015-12-17|
|     30 | ALLEN  | 1600 | 2006-01-20|
|     30 | WARD   | 1250 | 2006-02-22|
|     30 | BLAKE  | 2850 | 2006-05-01|
|     30 | TURNER | 1500 | 2006-09-08|
|     30 | MARTIN | 1250 | 2006-09-28|
|     30 | JAMES  |  950 | 2006-12-03|


For **each employee hired last** in his department, return “`N/A`” for the difference. The result set should look like this:


## Solution

The is another example of where the window functions `LEAD OVER` and `LAG OVER` come in handy. You can easily access next and prior rows without additional joins. Alternative methods such as subqueries or self-joins are possible but awkward:

- **Solution No Duplicates**:

```SQL
WITH emp_next_s AS (
  SELECT deptno, ename, sal, hiredate,
         LEAD(sal) OVER(PARTITION BY deptno
                            ORDER BY hiredate) AS next_sal
    FROM emp
)
SELECT deptno, ename, sal, hiredate,
         COALESCE((sal - next_sal)::VARCHAR,'N/A') AS sal_next_diff
  FROM emp_next_s;
```

- **Solution DUPLICATES**:


```SQL
WITH emp_next_s AS (
  SELECT deptno, ename, sal, hiredate,empno,
         COUNT(*) OVER (PARTITION BY deptno, hiredate
                            ORDER BY hiredate)::INTEGER AS cnt,
         ROW_NUMBER() OVER (PARTITION BY deptno, hiredate
                                ORDER BY sal)::INTEGER rn
    FROM emp
),
temp AS (
  SELECT deptno, ename, sal, hiredate,empno,
         LEAD(sal, cnt - rn + 1) OVER(PARTITION BY deptno
                            ORDER BY hiredate) AS next_sal
    FROM emp_next_s
)
SELECT deptno, ename, sal, hiredate,
        LPAD(COALESCE((sal - next_sal)::VARCHAR,'N/A'),10) AS sal_next_diff
  FROM temp;
```


## Discussion

The first step is to use the `LEAD OVER` window function to find the “next” salary for each employee within their department. The employees hired last in each department will have a `NULL` value for `NEXT_SAL`:

```SQL
SELECT deptno, ename, sal, hiredate,
       LEAD(sal) OVER(PARTITION BY deptno
                          ORDER BY hiredate) AS next_sal
  FROM emp;
```

|deptno | ename  | sal  |  hiredate  | next_sal|
|:-----:|:------:|:----:|:----------:|:-------:|
|    10 | CLARK  | 2450 | 2006-06-09 |     5000|
|    10 | KING   | 5000 | 2006-11-17 |     1300|
|    10 | MILLER | 1300 | 2007-01-23 ||
|    20 | JONES  | 2975 | 2006-04-02 |     3000|
|    20 | FORD   | 3000 | 2006-12-03 |     3000|
|    20 | SCOTT  | 3000 | 2007-12-09 |     1100|
|    20 | ADAMS  | 1100 | 2008-01-12 |      800|
|    20 | SMITH  |  800 | 2015-12-17 ||
|    30 | ALLEN  | 1600 | 2006-01-20 |     1250|
|    30 | WARD   | 1250 | 2006-02-22 |     2850|
|    30 | BLAKE  | 2850 | 2006-05-01 |     1500|
|    30 | TURNER | 1500 | 2006-09-08 |     1250|
|    30 | MARTIN | 1250 | 2006-09-28 |      950|
|    30 | JAMES  |  950 | 2006-12-03 ||

The next step is to take the difference between each employee’s salary and the salary of the employee hired immediately after them in the same department:

```SQL
WITH emp_next_s AS (
  SELECT deptno, ename, sal, hiredate,
         LEAD(sal) OVER(PARTITION BY deptno
                            ORDER BY hiredate) AS next_sal
    FROM emp
)
SELECT deptno, ename, sal, hiredate,
         sal - next_sal AS sal_next_diff
  FROM emp_next_s;
```

|deptno | ename  | sal  |  hiredate  | sal_next_diff|
|:-----:|:------:|:----:|:----------:|:------------:|
|    10 | CLARK  | 2450 | 2006-06-09 |         -2550|
|    10 | KING   | 5000 | 2006-11-17 |          3700|
|    10 | MILLER | 1300 | 2007-01-23 ||
|    20 | JONES  | 2975 | 2006-04-02 |           -25|
|    20 | FORD   | 3000 | 2006-12-03 |             0|
|    20 | SCOTT  | 3000 | 2007-12-09 |          1900|
|    20 | ADAMS  | 1100 | 2008-01-12 |           300|
|    20 | SMITH  |  800 | 2015-12-17 ||
|    30 | ALLEN  | 1600 | 2006-01-20 |           350|
|    30 | WARD   | 1250 | 2006-02-22 |         -1600|
|    30 | BLAKE  | 2850 | 2006-05-01 |          1350|
|    30 | TURNER | 1500 | 2006-09-08 |           250|
|    30 | MARTIN | 1250 | 2006-09-28 |           300|
|    30 | JAMES  |  950 | 2006-12-03 ||


The next step is to use the `COALESCE` function to insert “`N/A`” when there is no next salary. To be able to return “`N/A`” you must cast the value of `DIFF` to a string:

```SQL
WITH emp_next_s AS (
  SELECT deptno, ename, sal, hiredate,
         LEAD(sal) OVER(PARTITION BY deptno
                            ORDER BY hiredate) AS next_sal
    FROM emp
)
SELECT deptno, ename, sal, hiredate,
         COALESCE((sal - next_sal)::VARCHAR,'N/A') AS sal_next_diff
  FROM emp_next_s;
```

|deptno | ename  | sal  |  hiredate  | sal_next_diff|
|:-----:|:------:|:-----:|:---------:|:-------------:|
|    10 | CLARK  | 2450 | 2006-06-09 | -2550|
|    10 | KING   | 5000 | 2006-11-17 | 3700|
|    10 | MILLER | 1300 | 2007-01-23 | N/A|
|    20 | JONES  | 2975 | 2006-04-02 | -25|
|    20 | FORD   | 3000 | 2006-12-03 | 0|
|    20 | SCOTT  | 3000 | 2007-12-09 | 1900|
|    20 | ADAMS  | 1100 | 2008-01-12 | 300|
|    20 | SMITH  |  800 | 2015-12-17 | N/A|
|    30 | ALLEN  | 1600 | 2006-01-20 | 350|
|    30 | WARD   | 1250 | 2006-02-22 | -1600|
|    30 | BLAKE  | 2850 | 2006-05-01 | 1350|
|    30 | TURNER | 1500 | 2006-09-08 | 250|
|    30 | MARTIN | 1250 | 2006-09-28 | 300|
|    30 | JAMES  |  950 | 2006-12-03 | N/A|

The scenario involving duplicates when using the `LEAD OVER` function in this manner must be discussed. In the simple sample data in table `EMP`, **no employees have duplicate** `HIREDATEs`, yet this is an unlikely situation. Normally, we would not discuss a “what if ” situation such as duplicates (since there aren’t any in table `EMP`), but the workaround involving `LEAD` **may not be immediately obvious**.

Consider the following query, which returns the difference in `SAL` between the employees in `DEPTNO 10` (the difference is performed in the order in which they were hired):

```SQL
WITH emp_next_s AS (
  SELECT deptno, ename, sal, hiredate,empno,
         LEAD(sal) OVER(PARTITION BY deptno
                            ORDER BY hiredate) AS next_sal
    FROM emp
)
SELECT deptno, ename, sal, hiredate,
        LPAD(COALESCE((sal - next_sal)::VARCHAR,'N/A'),10) AS sal_next_diff
  FROM emp_next_s
  WHERE deptno = 10 AND empno > 10;
```

|deptno | ename  | sal  |  hiredate  | sal_next_diff|
|:-----:|:------:|:----:|:----------:|:------------:|
|    10 | CLARK  | 2450 | 2006-06-09 |      -2550|
|    10 | KING   | 5000 | 2006-11-17 |       3700|
|    10 | MILLER | 1300 | 2007-01-23 |        N/A|

This solution is correct considering the data in table `EMP`, but if there were duplicate rows, the solution would fail. Consider the following example, which shows four more employees hired on the same day as `KING`:

```SQL
INSERT INTO emp
       (empno, ename, deptno, sal, hiredate)
VALUES (1,'ANT',10,1000,'2006-11-17'),
       (2,'JOE',10,1500,'2006-11-17'),
       (3,'JIM',10,1600,'2006-11-17'),
       (4,'JON',10,1700,'2006-11-17');
```

NOw, let's run the query again.

```SQL
WITH emp_next_s AS (
  SELECT deptno, ename, sal, hiredate,empno,
         LEAD(sal) OVER(PARTITION BY deptno
                            ORDER BY hiredate) AS next_sal
    FROM emp
)
SELECT deptno, ename, sal, hiredate,
        LPAD(COALESCE((sal - next_sal)::VARCHAR,'N/A'),10) AS sal_next_diff
  FROM emp_next_s
  WHERE deptno = 10;
```

|deptno | ename  | sal  |  hiredate  | sal_next_diff|
|:-----:|:------:|:----:|:----------:|:------------:|
|    10 | CLARK  | 2450 | 2006-06-09 |        750|
|    10 | JON    | 1700 | 2006-11-17 |        100|
|    10 | JIM    | 1600 | 2006-11-17 |        100|
|    10 | JOE    | 1500 | 2006-11-17 |        500|
|    10 | ANT    | 1000 | 2006-11-17 |      -4000|
|    10 | KING   | 5000 | 2006-11-17 |       3700|
|    10 | MILLER | 1300 | 2007-01-23 |        N/A|

You’ll notice that with the exception of employee `KING`, all employees hired on the same date (November 17) **evaluate their salary against another employee hired on the same date!** This is `incorrect`. All employees hired on November 17 should have the difference of salary computed against `MILLER’s salary`, not another employee hired on November 17.

Take, for example, employee ANT. The value for `SAL_NEXT_DIFF` for `ANT` is **–4000** because `ANT’s SAL` is compared with `KING’s SAL` and is -4000 less than `KING’s SAL`, hence the value of **-4000**.

The correct value for `SAL_NEXT_DIFF` for employee `ANT` should be **–300** because `ANT` makes 300 less than `MILLER`, who is the next employee hired by `HIREDATE`.

The reason the solution seems to not work is due to the default behavior of `LEAD OVER` function. By default, `LEAD OVER` **looks ahead only one row**. So, for employee `ANT`, the next `SAL` based on `HIREDATE` is `KING’s SAL`, because `LEAD OVER` simply **looks one row ahead and doesn’t skip duplicates**.

Fortunately, PostgreSql planned for such a situation and allows you to pass an **additional parameter** to `LEAD OVER` to **determine how far ahead it should look**. In the previous example, the solution is simply a **matter of counting**: find the distance from each employee hired on November 17 to January 23 (`MILLER’s HIREDATE`). The following shows how to accomplish this:

```SQL
WITH emp_next_s AS (
  SELECT deptno, ename, sal, hiredate,empno,
         COUNT(*) OVER (PARTITION BY deptno, hiredate
                            ORDER BY hiredate)::INTEGER AS cnt,
         ROW_NUMBER() OVER (PARTITION BY deptno, hiredate
                                ORDER BY sal)::INTEGER rn
    FROM emp
)
SELECT *
  FROM emp_next_s
  WHERE deptno = 10;
```

```console
deptno | ename  | sal  |  hiredate  | empno | cnt | rn
--------+--------+------+------------+-------+-----+----
    10 | CLARK  | 2450 | 2006-06-09 |  7782 |   1 |  1
    --------------------------------------------------
    10 | ANT    | 1000 | 2006-11-17 |     1 |   5 |  1
    10 | JOE    | 1500 | 2006-11-17 |     2 |   5 |  2
    10 | JIM    | 1600 | 2006-11-17 |     3 |   5 |  3
    10 | JON    | 1700 | 2006-11-17 |     4 |   5 |  4
    10 | KING   | 5000 | 2006-11-17 |  7839 |   5 |  5
    --------------------------------------------------
    10 | MILLER | 1300 | 2007-01-23 |  7934 |   1 |  1
```

The value for `CNT` represents, for each employee with a duplicate `HIREDATE`, **how many duplicates there are in total for their** `HIREDATE`. The value for `RN` represents a **ranking for the employees** in `DEPTNO 10`.

The rank is partitioned by `DEPTNO` and `HIREDATE` so only employees with a `HIREDATE` that another employee has will have a value greater than one. The ranking is sorted by `SAL` (this is arbitrary; `SAL` is convenient, but we could have just as easily chosen `EMPNO`). Now that you know how many total duplicates there are and you have a ranking of each duplicate, the distance to MILLER is simply the total number of duplicates minus the current rank plus one (**CNT-RN+1**).

```SQL
WITH emp_next_s AS (
  SELECT deptno, ename, sal, hiredate,empno,
         COUNT(*) OVER (PARTITION BY deptno, hiredate
                            ORDER BY hiredate)::INTEGER AS cnt,
         ROW_NUMBER() OVER (PARTITION BY deptno, hiredate
                                ORDER BY sal)::INTEGER rn
    FROM emp
),
temp AS (
  SELECT deptno, ename, sal, hiredate,empno,
         LEAD(sal, cnt - rn + 1) OVER(PARTITION BY deptno
                            ORDER BY hiredate) AS next_sal
    FROM emp_next_s
)
SELECT *
  FROM temp
  WHERE deptno = 10;
```

the expression passed to `LEAD OVER`; **CNT-RN+1** is simply the `distance from each employee hired on November 17 to MILLER`.

The results of the distance calculation and its effect on `LEAD OVER` are shown here:

```console
deptno | ename  | sal  |  hiredate  | empno | next_sal
--------+--------+------+------------+-------+----------
    10 | CLARK  | 2450 | 2006-06-09 |  7782 |     1000
    --------------------------------------------------
    10 | ANT    | 1000 | 2006-11-17 |     1 |     1300
    10 | JOE    | 1500 | 2006-11-17 |     2 |     1300
    10 | JIM    | 1600 | 2006-11-17 |     3 |     1300
    10 | JON    | 1700 | 2006-11-17 |     4 |     1300
    10 | KING   | 5000 | 2006-11-17 |  7839 |     1300
    --------------------------------------------------
    10 | MILLER | 1300 | 2007-01-23 |  7934 |
```

Now you can clearly see the effect that you have when you pass the correct distance to `LEAD OVER`. The rows for `INCORRECT` represent the values returned by `LEAD OVER` using a default distance of one. The rows for `CORRECT` represent the values returned by `LEAD OVER` using the proper distance for each employee with a duplicate `HIREDATE` to `MILLER`. At this point, all that is left is to find the difference between `CORRECT` and `SAL` for each row, which has already been shown.

```SQL
WITH emp_next_s AS (
  SELECT deptno, ename, sal, hiredate,empno,
         COUNT(*) OVER (PARTITION BY deptno, hiredate
                            ORDER BY hiredate)::INTEGER AS cnt,
         ROW_NUMBER() OVER (PARTITION BY deptno, hiredate
                                ORDER BY sal)::INTEGER rn
    FROM emp
),
temp AS (
  SELECT deptno, ename, sal, hiredate,empno,
         LEAD(sal, cnt - rn + 1) OVER(PARTITION BY deptno
                            ORDER BY hiredate) AS next_sal
    FROM emp_next_s
)
SELECT deptno, ename, sal, hiredate,
        LPAD(COALESCE((sal - next_sal)::VARCHAR,'N/A'),10) AS sal_next_diff
  FROM temp
  WHERE deptno = 10;
```

|deptno | ename  | sal  |  hiredate  | sal_next_diff|
|:-----:|:------:|:----:|:----------:|:------------:|
|    10 | CLARK  | 2450 | 2006-06-09 |       1450|
|    10 | ANT    | 1000 | 2006-11-17 |       -300|
|    10 | JOE    | 1500 | 2006-11-17 |        200|
|    10 | JIM    | 1600 | 2006-11-17 |        300|
|    10 | JON    | 1700 | 2006-11-17 |        400|
|    10 | KING   | 5000 | 2006-11-17 |       3700|
|    10 | MILLER | 1300 | 2007-01-23 |        N/A|

Now the solution is correct. As you can see, all the employees hired on November 17 now have their salaries compared with `MILLER’s salary`. Inspecting the results, employee `ANT` now has a value of `–300` for `SAL_NEXT_DIFF`, which is what we were hoping for.
