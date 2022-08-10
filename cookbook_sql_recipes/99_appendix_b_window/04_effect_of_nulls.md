# Effect of NULLs

Like the `GROUP BY` clause, the `PARTITION BY` clause lumps all the `NULLs` into one group or partition. Thus, the effect from `NULLs` when using `PARTITION BY` is similar to that from using `GROUP BY`.

The following query uses a window function to **count the number of employees with each distinct commission** (returning `–1` **in place of** `NULL` **for readability**):

```SQL
SELECT COALESCE(comm,-1) AS comm,
       COUNT(*) OVER(PARTITION BY comm) AS cnt
  FROM emp;
```

|comm | cnt|
|:---:|:---:|
|   0 |   1|
| 300 |   1|
| 500 |   1|
|1400 |   1|
|  -1 |  10|
|  -1 |  10|
|  -1 |  10|
|  -1 |  10|
|  -1 |  10|
|  -1 |  10|
|  -1 |  10|
|  -1 |  10|
|  -1 |  10|
|  -1 |  10|

- (14 rows) = 10 (# -1) + 1 (# 1400) + 1 (# 500) + 1 (# 300) + 1 (# 0)

Because `COUNT(*)` is used, **the function counts rows**. You can see that there are 10 employees having NULL commissions. Use `COMM` instead of `*`, however, and you get quite different results:

```SQL
SELECT COALESCE(comm,-1) AS comm,
       COUNT(comm) OVER(PARTITION BY comm) AS cnt
  FROM emp;
```

|comm | cnt|
|:---:|:---:|
|   0 |   1|
| 300 |   1|
| 500 |   1|
|1400 |   1|
|  -1 |   0|
|  -1 |   0|
|  -1 |   0|
|  -1 |   0|
|  -1 |   0|
|  -1 |   0|
|  -1 |   0|
|  -1 |   0|
|  -1 |   0|
|  -1 |   0|

(14 rows)

This query uses `COUNT(COMM)`, **which means that only the** `non-NULL` **values in the** `COMM` **column are counted**.

There is one employee with a commission of `0`, one employee with a commission of `300`, and `so forth`. But notice the counts for those with `NULL` commissions! Those counts are `0`. Why? **Because aggregate functions ignore** `NULL` values, or more accurately, **aggregate functions count only** `non-NULL` **values**.

>Note: When using COUNT, consider whether you want to include NULLs. Use COUNT(column) to avoid counting NULLs. Use COUNT(*) if you do want to include NULLs (since you are no longer counting actual column values, you are counting rows).
