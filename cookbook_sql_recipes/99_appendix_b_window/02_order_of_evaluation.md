# Order of Evaluation

Before digging deeper into the **OVER** clause, it is important to note that **window functions are performed as the last step** in `SQL processing` prior to the `ORDER BY` clause.

As an example of how window functions **are processed last**, let’s take the query from the preceding section and use a `WHERE` clause to filter out employees from `DEPTNO 20` and `30`:

```SQL
SELECT ename,
       deptno,
       COUNT(*) OVER() AS cnt
  FROM emp
 WHERE deptno = 10
 ORDER BY 2;
```

|ename  | deptno | cnt|
|:-----:|:------:|:--:|
|CLARK  |     10 |   3|
|KING   |     10 |   3|
|MILLER |     10 |   3|

The value for `CNT` for each row is no longer `14`, it is now `3`. In this example, it is the `WHERE` clause that restricts the result set to three rows; hence, the window function will count only three rows (there are only three rows available to the window function by the time processing reaches the SELECT portion of the query). From this example you can see that **window functions perform their computations after clauses** such as `WHERE` and `GROUP BY` are evaluated.
