# Calculating a Mode

You want to find the **mode** (for those of you who don’t recall, the mode in mathematics is **the element that appears most frequently for a given set of data**) of the values in a column.

## Problem

For example, you want to find the mode of the `salaries` in `DEPTNO 20`.
Based on the following salaries:

```SQL
SELECT sal
  FROM emp
 WHERE deptno = 20
 ORDER BY sal;
```

|sal|
|:--:|
| 800|
|1100|
|2975|
|3000|
|3000|

the mode is **3000**.

## Solution

**DB2, MySQL, PostgreSQL, and SQL Server**

Use the window function [DENSE_RANK](https://github.com/lpinzari/sql-psql-udy/blob/master/08_window_functions/08_dense_rank.md) to rank the counts of the salaries to facilitate extracting the mode:

```SQL
SELECT sal
  FROM (SELECT sal,
               DENSE_RANK() OVER( ORDER BY cnt DESC) AS rnk
          FROM (SELECT sal,
                       COUNT(*) AS cnt
                  FROM emp
                 WHERE deptno = 20
                 GROUP BY sal
                ) x
       ) y
 WHERE rnk = 1;
```

**CTE**

```SQL
WITH x AS (
  SELECT sal,
         COUNT(*) AS cnt
    FROM emp
   WHERE deptno = 20
   GROUP BY sal
),
y AS (
  SELECT sal,
         DENSE_RANK() OVER( ORDER BY cnt DESC) AS rnk
    FROM x
)
SELECT sal
  FROM y
 WHERE rnk = 1;
```

**Using max**

```SQL
WITH x AS (
  SELECT sal,
         COUNT(*) AS cnt
    FROM emp
   WHERE deptno = 20
   GROUP BY sal
)

SELECT sal
  FROM x
 WHERE x.cnt IN (SELECT MAX(cnt) max_cnt
                   FROM x);
```

**Alternative solution**

```SQL
WITH histogram AS (
  SELECT sal,
         COUNT(*) AS freq
    FROM emp
   WHERE deptno = 20
   GROUP BY sal
),
max_freq AS (
  SELECT MAX(freq) AS top
    FROM histogram
)
SELECT sal
  FROM histogram h, max_freq mf
 WHERE h.freq = mf.top;
```

Note that there can be several modes in a dataset. When we know that there is only one mode, the following is more efficient:

```SQL
SELECT sal,
       COUNT(*) AS freq
  FROM emp
 WHERE deptno = 20
 GROUP BY sal
 ORDER BY freq DESC
 LIMIT 1;
```

|sal  | freq|
|:---:|:---:|
|3000 |    2|

However, this is correct only when we know for sure the number of modes, if there are k modes, we can use `LIMIT k`. Otherwise, this approach is incorrect.

## Discussion

**CTE**

```SQL
WITH x AS (
  SELECT sal,
         COUNT(*) AS cnt
    FROM emp
   WHERE deptno = 20
   GROUP BY sal
),
y AS (
  SELECT sal,
         DENSE_RANK() OVER( ORDER BY cnt DESC) AS rnk
    FROM x
)
SELECT sal
  FROM y
 WHERE rnk = 1;
```

The **CTE** `X` returns each `SAL` and the number of times it occurs.

```SQL
SELECT sal,
       COUNT(*) AS cnt
  FROM emp
 WHERE deptno = 20
 GROUP BY sal
 ORDER BY cnt DESC;
```

|sal  | cnt|
|:---:|:---:|
|3000 |   2|
| 800 |   1|
|1100 |   1|
|2975 |   1|

The **CTE** `Y` uses the window function `DENSE_RANK` (**which allows for ties**) to sort the results.

```SQL
WITH x AS (
  SELECT sal,
         COUNT(*) AS cnt
    FROM emp
   WHERE deptno = 20
   GROUP BY sal
)
SELECT sal,
       DENSE_RANK() OVER( ORDER BY cnt DESC) AS rnk
  FROM x
 ORDER BY rnk;
```

The results are ranked based on the number of times each SAL occurs, as shown here:

|sal  | rnk|
|:---:|:---:|
|3000 |   1|
| 800 |   2|
|1100 |   2|
|2975 |   2|

```SQL
WITH x AS (
  SELECT sal,
         COUNT(*) AS cnt
    FROM emp
   WHERE deptno = 20
   GROUP BY sal
),
y AS (
  SELECT sal,
         DENSE_RANK() OVER( ORDER BY cnt DESC) AS rnk
    FROM x
)
SELECT sal
  FROM y
 WHERE rnk = 1;
```

The outermost portion of query simply keeps the row(s) where RNK is 1.

**Using Max**

```SQL
WITH x AS (
  SELECT sal,
         COUNT(*) AS cnt
    FROM emp
   WHERE deptno = 20
   GROUP BY sal
)

SELECT sal
  FROM x
 WHERE x.cnt IN (SELECT MAX(cnt) max_cnt
                   FROM x);
```


The **CTE** `X` returns each `SAL` and the number of times it occurs.

```SQL
SELECT sal,
       COUNT(*) AS cnt
  FROM emp
 WHERE deptno = 20
 GROUP BY sal
 ORDER BY cnt DESC;
```

|sal  | cnt|
|:---:|:---:|
|3000 |   2|
| 800 |   1|
|1100 |   1|
|2975 |   1|

The outermost portion of query simply keeps the row(s) where `cnt` is maximum in table x, (that is **the element/s that appears most frequently for a given set of data**).

## Example Multiple values Mode

```SQL
SELECT sal,
       COUNT(*) AS freq
  FROM emp
 GROUP BY sal
 ORDER BY freq DESC;
```

|sal  | freq|
|:---:|:----:|
|1250 |    2|
|3000 |    2|
| 950 |    1|
| 800 |    1|
|1100 |    1|
|2975 |    1|
|1600 |    1|
|5000 |    1|
|1500 |    1|
|1300 |    1|
|2850 |    1|
|2450 |    1|

```SQL
WITH x AS (
  SELECT sal,
         COUNT(*) AS cnt
    FROM emp
   GROUP BY sal
),
y AS (
  SELECT sal,
         DENSE_RANK() OVER( ORDER BY cnt DESC) AS rnk
    FROM x
)
SELECT sal
  FROM y
 WHERE rnk = 1;
```

|sal|
|:--:|
|3000|
|1250|
