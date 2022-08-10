# When Order Matters

Sometimes **the order in which rows are treated by a window function is material to the results that you want to obtain from a query**.

For this reason, window function syntax includes an `ORDER BY` **subclause that you can place within an** `OVER` clause. Use the `ORDER BY` clause to **specify how the rows are ordered with a partition** before the computation (remember, “partition” in the **absence of** a `PARTITION BY` clause means the `entire result set`).

**Some window functions require** you to impose `order on the partitions` of rows being affected. Thus, for some window functions, an `ORDER BY` clause **is mandatory**.

When you use an `ORDER BY` clause in the `OVER` clause of a window function, you are specifying two things:

- **How** the `rows in the partition are ordered`
- **What** `rows are included in the computation`

Consider the following query, which sums and **computes a running total of salaries for employees in** `DEPTNO 10`:

```SQL
SELECT deptno,
       ename,
       hiredate,
       sal,
       SUM(sal) OVER(PARTITION BY deptno) AS total1,
       SUM(sal) OVER() AS total2,
       SUM(sal) OVER(ORDER BY hiredate) AS running_total
  FROM emp
 WHERE deptno = 10;
```

|deptno | ename  |  hiredate  | sal  | total1 | total2 | running_total|
|:-----:|:------:|:----------:|:----:|:------:|:------:|:------------:|
|    10 | CLARK  | 2006-06-09 | 2450 |   8750 |   8750 |          2450|
|    10 | KING   | 2006-11-17 | 5000 |   8750 |   8750 |          7450|
|    10 | MILLER | 2007-01-23 | 1300 |   8750 |   8750 |          8750|

Just to keep you on your toes, I’ve included a sum with empty parentheses. Notice how `TOTAL1` and `TOTAL2` have the same values.

Why? Once again, the order in which window functions are evaluated answers the question. The `WHERE` clause filters the result set such that only salaries from `DEPTNO 10` are considered for summation. In this case, there is only one partition — the entire result set, **which consists of only salaries from** `DEPTNO 10`. Thus `TOTAL1`, and `TOTAL2` are the same.

Looking at the values returned by column `SAL`, you can easily see where the values for `RUNNING_TOTAL` come from. You can eyeball the values and add them yourself to compute the running total. But more importantly, why did including an `ORDER BY` in the `OVER` clause create a running total in the first place? The reason is, when you use `ORDER BY` in the `OVER` clause, you are specifying a default “**moving**” or “**sliding**” **window within the partition even though you don’t see it**.

The `ORDER BY HIREDATE` clause **terminates summation at the** `HIREDATE` in the cur‐ rent row.

The following query is the same as the previous one, but uses the `RANGE BETWEEN` clause (which you’ll learn more about later) to explicitly specify the default behavior that results from `ORDER BY HIREDATE`:

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

The `RANGE BETWEEN` clause that you see in this query is termed the **framing clause** by ANSI, and we’ll use that term here. Now, it should be easy to see why specifying an `ORDER BY` in the `OVER` clause created a running total; we’ve (by default) told the query to **sum all rows starting from the current row and include all prior rows** (“`prior`” as defined in the `ORDER BY`, in this case **ordering the rows by** `HIREDATE`).
