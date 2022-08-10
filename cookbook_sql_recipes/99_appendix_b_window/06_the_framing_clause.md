# The Framing Clause

```SQL
SELECT deptno,
       ename,
       hiredate,
       sal,
       SUM(sal) OVER(PARTITION BY deptno) AS total1,
       SUM(sal) OVER() AS total2,
       SUM(sal) OVER(ORDER BY hiredate
                        RANGE BETWEEN UNBOUNDED PRECEDING
                          AND CURRENT ROW) AS running_total
 FROM emp
WHERE deptno = 10;
```

|deptno | ename  |  hiredate  | sal  | total1 | total2 | running_total|
|:-----:|:------:|:----------:|:----:|:------:|:------:|:------------:|
|    10 | CLARK  | 2006-06-09 | 2450 |   8750 |   8750 |          2450|
|    10 | KING   | 2006-11-17 | 5000 |   8750 |   8750 |          7450|
|    10 | MILLER | 2007-01-23 | 1300 |   8750 |   8750 |          8750|

Let’s apply the framing clause from the preceding query to the result set, starting with the first employee hired, who is named `CLARK`:

1. Starting with CLARK’s salary, `2450`, and including all employees hired before `CLARK`, compute a sum. Since `CLARK` was the first employee hired in `DEPTNO 10`, the sum is simply `CLARK’s` salary, `2450`, which is the first value returned by `RUNNING_TOTAL`.

2. Let’s move to the next employee based on `HIREDATE`, named `KING`, and apply the framing clause once again. Compute a sum on `SAL` starting with the current row, `5000` (KING’s salary), and include all prior rows (all employees hired before KING). `CLARK` is the only one hired before `KING`, so the sum is `5000 + 2450`, which is `7450`, the second value returned by `RUNNING_TOTAL`.

3. Moving on to `MILLER`, the last employee in the partition based on `HIREDATE`, let’s one more time apply the framing clause. Compute a sum on `SAL` starting with the current row, `1300` (MILLER’s salary), and include all prior rows (all employees hired before MILLER). `CLARK` and `KING` were both hired before `MILLER`, and thus their salaries are included in `MILLER’s RUNNING_TOTAL`: `2450 + 5000 + 1300` is `8750`, which is the value for `RUNNING_TOTAL` for `MILLER`.

As you can see, it is really the framing clause that produces the running total. The `ORDER BY` defines the order of evaluation and happens to also imply a default framing.

In general, the framing clause allows you to define different “`subwindows`” of data to include in your computations. There are many ways to specify such **subwindows**.

Consider the following query:

```SQL
SELECT deptno,
       ename,
       sal,
       SUM(sal) OVER(ORDER BY hiredate
                        RANGE BETWEEN UNBOUNDED PRECEDING
                          AND CURRENT ROW) AS run_total1,
       SUM(sal) OVER(ORDER BY hiredate
                         ROWS BETWEEN 1 PRECEDING
                          AND CURRENT ROW) AS run_total2,
       SUM(sal) OVER(ORDER BY hiredate
                        RANGE BETWEEN CURRENT ROW
                          AND UNBOUNDED FOLLOWING) AS run_total3,
       SUM(sal) OVER(ORDER BY hiredate
                         ROWS BETWEEN CURRENT ROW
                          AND 1 FOLLOWING) AS run_total4
 FROM emp
WHERE deptno = 10;
```

|deptno | ename  | sal  | run_total1 | run_total2 | run_total3 | run_total4|
|:-----:|:------:|:----:|:----------:|:----------:|:----------:|:---------:|
|    10 | CLARK  | 2450 |       2450 |       2450 |       8750 |       7450|
|    10 | KING   | 5000 |       7450 |       7450 |       6300 |       6300|
|    10 | MILLER | 1300 |       8750 |       6300 |       1300 |       1300|

Don’t be intimidated here; this query is not as bad as it looks. You’ve already seen `RUN_TOTAL1` and the effects of the framing clause `UNBOUNDED PRECEDING AND CURRENT ROW`. Here’s a quick description of what’s happening in the other examples:

- **RUN_TOTAL2**:

```console
SUM(sal) OVER(ORDER BY hiredate
                  ROWS BETWEEN 1 PRECEDING
                   AND CURRENT ROW) AS run_total2,
```

Rather than the keyword `RANGE`, this framing clause specifies `ROWS`, which means the **frame**, or **window**, is going to be constructed by counting some number of rows. The `1` `PRECEDING` means that **the frame will begin with the row immediately preceding the current row**. The range continues through the `CURRENT ROW`. So what you get in `RUN_TOTAL2` is the **sum of the current employee’s salary** `and` **that of the preceding employee**, based on `HIREDATE`.

>Note: It so happens that `RUN_TOTAL1` and `RUN_TOTAL2` are the same for both `CLARK` and `KING`. Why? Think about which values are being summed for each of those employees, for each of the two window functions. Think carefully, and you’ll get the answer.

- **RUN_TOTAL3**:

```console
SUM(sal) OVER(ORDER BY hiredate
                 RANGE BETWEEN CURRENT ROW
                   AND UNBOUNDED FOLLOWING) AS run_total3
```

The window function for `RUN_TOTAL3` works just the opposite of that for `RUN_TOTAL1`; rather than starting with the current row and including all prior rows in the summation, **summation begins with the current row** `and` **includes all subsequent rows in the summation**.

- **RUN_TOTAL4**

```console
SUM(sal) OVER(ORDER BY hiredate
                  ROWS BETWEEN CURRENT ROW
                   AND 1 FOLLOWING) AS run_total4
```

This is the inverse of `RUN_TOTAL2`; rather than starting from the current row and including one prior row in the summation, **start with the current row** `and` **include one subsequent row in the summation**.
