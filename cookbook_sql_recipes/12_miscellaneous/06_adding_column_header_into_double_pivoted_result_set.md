# Adding a Column Header into a Double Pivoted Result Set


You want to
- `stack` **two result sets** and then
- `pivot` them **into two columns**.

Additionally, you want to add a “`header`” **for each group of rows in each column**.

## Problem

For example, you have two tables containing information about `employees` working in different areas of development in your company (say, in `research` and `applications`):

- **it_research** table:

```SQL
CREATE TABLE it_research (
  deptno INTEGER,
  ename VARCHAR(20)
);

INSERT INTO it_research
       (deptno, ename)
VALUES (100,'HOPKINS'),
       (100,'JONES'),
       (100,'TONEY'),
       (200,'MORALES'),
       (200,'P.WHITAKER'),
       (200,'MARCIANO'),
       (200,'ROBINSON'),
       (300,'LACY'),
       (300,'WRIGHT'),
       (300,'J.TAYLOR');
```

|deptno |   ename|
|:-----:|:--------:|
|   100 | HOPKINS|
|   100 | JONES|
|   100 | TONEY|
|   200 | MORALES|
|   200 | P.WHITAKER|
|   200 | MARCIANO|
|   200 | ROBINSON|
|   300 | LACY|
|   300 | WRIGHT|
|   300 | J.TAYLOR|


- **it_apps** table:

```SQL
CREATE TABLE it_apps (
  deptno INTEGER,
  ename VARCHAR(20)
);

INSERT INTO it_apps
       (deptno, ename)
VALUES (400,'CORRALES'),
       (400,'MAYWEATHER'),
       (400,'CASTILLO'),
       (400,'MARQUEZ'),
       (400,'MOSLEY'),
       (500,'GATTI'),
       (500,'CALZAGHE'),
       (600,'LAMOTTA'),
       (600,'HAGLER'),
       (600,'HEARNS'),
       (600,'FRAZIER'),
       (700,'GUINN'),
       (700,'JUDAH'),
       (700,'MARGARITO');
```

|deptno |   ename|
|:-----:|:-----------:|
|   400 | CORRALES|
|   400 | MAYWEATHER|
|   400 | CASTILLO|
|   400 | MARQUEZ|
|   400 | MOSLEY|
|   500 | GATTI|
|   500 | CALZAGHE|
|   600 | LAMOTTA|
|   600 | HAGLER|
|   600 | HEARNS|
|   600 | FRAZIER|
|   700 | GUINN|
|   700 | JUDAH|
|   700 | MARGARITO|

You would like to create a report listing the employees from each table in two columns. You want to return the `DEPTNO` followed by `ENAME` for each. Ultimately, you want to return the following result set:


```console
research    |    apps
------------+-------------
100         | 400
 JONES      |  CORRALES
 TONEY      |  MARQUEZ
 HOPKINS    |  MAYWEATHER
200         |  MOSLEY
 MORALES    |  CASTILLO
 P.WHITAKER | 500
 ROBINSON   |  GATTI
 MARCIANO   |  CALZAGHE
300         | 600
 LACY       |  HAGLER
 WRIGHT     |  HEARNS
 J.TAYLOR   |  LAMOTTA
            |  FRAZIER
            | 700
            |  JUDAH
            |  MARGARITO
            |  GUINN
```

## Solution

```SQL
WITH x AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_apps
),
t AS (
  SELECT x.*, id,
         ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
    FROM x, (SELECT GENERATE_SERIES(1,2) AS id) y
),
x2 AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_research
),
t2 AS (
  SELECT x2.*, id,
         ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
    FROM x2, (SELECT GENERATE_SERIES(1,2) AS id) y
),
t3 AS (
  SELECT SUM(flag1) OVER (PARTITION BY flag2 ORDER BY flag2, deptno, rn) AS flag,
         it_dept, flag2, flag1
    FROM (
      SELECT 1 flag1, 0 flag2, deptno, rn,
             CASE WHEN rn = 1
                  THEN deptno::VARCHAR
                  ELSE ' ' || ename
             END AS it_dept
        FROM t
       WHERE rn <= cnt + 1
      UNION ALL
      SELECT 1 flag1, 1 flag2, deptno, rn,
             CASE WHEN rn = 1
                  THEN deptno::VARCHAR
                  ELSE ' ' || ename
             END AS it_dept
        FROM t2
       WHERE rn <= cnt + 1
    ) w
    ORDER BY flag2 DESC, flag
),
t4 AS (
  SELECT CASE WHEN flag2 = 1 THEN it_dept END AS research,
         CASE WHEN flag2 = 0 THEN it_dept END AS apps,
         flag
  FROM t3
)
SELECT MAX(research) AS research,
       MAX(apps) AS apps
  FROM t4
 GROUP BY flag
 ORDER BY flag;  
```

## Discussion

Like many of the other warehousing/report type queries, the solution presented looks quite convoluted, but once broken down, you’ll seen it’s nothing more than a `stack ’n’ pivot with a Cartesian twist` (on the rocks, with a little umbrella). The way to break down this query is to work on each part of the `UNION ALL` first and then bring it together for the pivot. Let’s start with the **upper portion** of the `UNION ALL`:

```SQL
WITH x AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_apps
),
t AS (
  SELECT x.*, id,
         ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
    FROM x, (SELECT GENERATE_SERIES(1,2) AS id) y
)
SELECT 1 flag1, 1 flag2,
       CASE WHEN rn = 1
            THEN deptno::VARCHAR
            ELSE ' ' || ename
       END AS it_dept
  FROM t
 WHERE rn <= cnt + 1;
```

Breaking down the previous query to its simplest components. The results are as follows:

```SQL
SELECT deptno,
       ename,
       COUNT(*) OVER(PARTITION BY deptno) AS cnt
  FROM it_apps;
```

```console
|deptno |   ename    | cnt|
|:-----:|:----------:|:---:|
|   400 | CORRALES   |   5|
|   400 | MAYWEATHER |   5|
|   400 | CASTILLO   |   5|
|   400 | MARQUEZ    |   5|
|   400 | MOSLEY     |   5|
-----------------------------
|   500 | GATTI      |   2|
|   500 | CALZAGHE   |   2|
----------------------------
|   600 | LAMOTTA    |   4|
|   600 | HAGLER     |   4|
|   600 | HEARNS     |   4|
|   600 | FRAZIER    |   4|
----------------------------
|   700 | GUINN      |   3|
|   700 | JUDAH      |   3|
|   700 | MARGARITO  |   3|
```

The next step is to create a `Cartesian product` between the rows returned from The CTE `X` and two rows generated from `GENERATE_SERIES` function.

```SQL
WITH x AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_apps
)
SELECT x.*, id
  FROM x, (SELECT GENERATE_SERIES(1,2) AS id) y;
```

```console
|deptno |   ename    | cnt | id|
|:-----:|:----------:|:---:|:--:|
|   400 | CORRALES   |   5 |  1|
|   400 | CORRALES   |   5 |  2|
|                          -----
|   400 | MAYWEATHER |   5 |  1|
|   400 | MAYWEATHER |   5 |  2|
|                          -----
|   400 | CASTILLO   |   5 |  1|
|   400 | CASTILLO   |   5 |  2|
|                          -----
|   400 | MARQUEZ    |   5 |  1|
|   400 | MARQUEZ    |   5 |  2|
|                          -----
|   400 | MOSLEY     |   5 |  1|
|   400 | MOSLEY     |   5 |  2|
|                          -----
---------------------------------                            
|   500 | GATTI      |   2 |  1|
|   500 | GATTI      |   2 |  2|
|                          -----
|   500 | CALZAGHE   |   2 |  1|
|   500 | CALZAGHE   |   2 |  2|
|                          -----
--------------------------------
|   600 | LAMOTTA    |   4 |  1|
|   600 | LAMOTTA    |   4 |  2|
|                          -----
|   600 | HAGLER     |   4 |  1|
|   600 | HAGLER     |   4 |  2|
|                          -----
|   600 | HEARNS     |   4 |  1|
|   600 | HEARNS     |   4 |  2|
|                          -----
|   600 | FRAZIER    |   4 |  1|
|   600 | FRAZIER    |   4 |  2|
|                          -----
--------------------------------
|   700 | GUINN      |   3 |  1|
|   700 | GUINN      |   3 |  2|
|                          -----
|   700 | JUDAH      |   3 |  1|
|   700 | JUDAH      |   3 |  2|
|                          -----
|   700 | MARGARITO  |   3 |  1|
|   700 | MARGARITO  |   3 |  2|
--------------------------------
```

As you can see from these results, each row from CTE `X` is now **returned twice** due to the Cartesian product with the two rows table y. The reason a Cartesian is needed will become clear shortly.

```SQL
WITH x AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_apps
)
SELECT x.*, id,
       ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
  FROM x, (SELECT GENERATE_SERIES(1,2) AS id) y;
```

The next step is to take the current result set and rank each employee within his DEPTNO by ID (ID has a value of 1 or 2 as was returned by the Cartesian product). The result of this ranking is shown in the output from the above query:

```console
deptno |   ename    | cnt | id | rn
--------+------------+-----+----+----
   400 | CASTILLO   |   5 |  1 |  1 | ---> 400
   400 | CORRALES   |   5 |  1 |  2            CORRALES
   400 | MARQUEZ    |   5 |  1 |  3            MARQUEZ
   400 | MAYWEATHER |   5 |  1 |  4            MAYWEATHER
   400 | MOSLEY     |   5 |  1 |  5            MOSELY
                          ------ rn = cnt + 1  CASTILLO
   400 | CASTILLO   |   5 |  2 |  6           
   400 | CORRALES   |   5 |  2 |  7
   400 | MARQUEZ    |   5 |  2 |  8
   400 | MAYWEATHER |   5 |  2 |  9
   400 | MOSLEY     |   5 |  2 | 10
   --------------------------------
   500 | CALZAGHE   |   2 |  1 |  1 | ---> 500
   500 | GATTI      |   2 |  1 |  2
                          ------ rn = cnt + 1
   500 | CALZAGHE   |   2 |  2 |  3
   500 | GATTI      |   2 |  2 |  4
   --------------------------------
   600 | FRAZIER    |   4 |  1 |  1 | ---> 600
   600 | HAGLER     |   4 |  1 |  2
   600 | HEARNS     |   4 |  1 |  3
   600 | LAMOTTA    |   4 |  1 |  4
                          ------ rn = cnt + 1
   600 | FRAZIER    |   4 |  2 |  5
   600 | HAGLER     |   4 |  2 |  6
   600 | HEARNS     |   4 |  2 |  7
   600 | LAMOTTA    |   4 |  2 |  8
   --------------------------------
   700 | GUINN      |   3 |  1 |  1 | ---> 700
   700 | JUDAH      |   3 |  1 |  2
   700 | MARGARITO  |   3 |  1 |  3
                          ------ rn = cnt + 1
   700 | GUINN      |   3 |  2 |  4
   700 | JUDAH      |   3 |  2 |  5
   700 | MARGARITO  |   3 |  2 |  6
```


Each employee is ranked; then `his duplicate` **is ranked**. The result set contains duplicates for all employees in table `IT_APP`, along **with their ranking within their** `DEPTNO`.

The reason you need to generate these extra rows is because you need a slot in the result set to slip in the `DEPTNO` in the `ENAME` column. If you Cartesian join `IT_APPS` with a one-row table, you get no extra rows (because cardinality of any table × 1 = cardinality of that table).

```SQL
WITH x AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_apps
),
t AS (
  SELECT x.*, id,
         ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
    FROM x, (SELECT GENERATE_SERIES(1,2) AS id) y
)
SELECT deptno, ename, cnt, rn,
       CASE WHEN rn = 1
            THEN deptno::VARCHAR
            ELSE ' ' || ename
       END AS it_dept
  FROM t
 WHERE rn <= cnt + 1;
```

The number of rows returned for each `DEPTNO` is `CNT*2`, but all that is needed is `CNT+1`, which is the filter in the `WHERE` clause. `RN` is the ranking for each employee. The rows kept are all those ranked less than or equal to `CNT+1`; i.e., all employees in each `DEPTNO` plus one more (this extra employee is the employee who is ranked first in their `DEPTNO`). This extra row is where the `DEPTNO` will slide in.

By using `CASE` expression to evaluate the value of `RN`, you can slide the value of `DEPTNO` into the result set. The employee who was at position one (based on the value of `RN`) is still shown in the result set, but is now last in each `DEPTNO`. That pretty much **covers the lower part of the** `UNION ALL`.

```console
deptno |   ename    | cnt | rn |   it_dept
--------+------------+-----+----+-------------
   400 | CASTILLO   |   5 |  1 | 400
   400 | CORRALES   |   5 |  2 |  CORRALES
   400 | MARQUEZ    |   5 |  3 |  MARQUEZ
   400 | MAYWEATHER |   5 |  4 |  MAYWEATHER
   400 | MOSLEY     |   5 |  5 |  MOSLEY
   400 | CASTILLO   |   5 |  6 |  CASTILLO
   500 | CALZAGHE   |   2 |  1 | 500
   500 | GATTI      |   2 |  2 |  GATTI
   500 | CALZAGHE   |   2 |  3 |  CALZAGHE
   600 | FRAZIER    |   4 |  1 | 600
   600 | HAGLER     |   4 |  2 |  HAGLER
   600 | HEARNS     |   4 |  3 |  HEARNS
   600 | LAMOTTA    |   4 |  4 |  LAMOTTA
   600 | FRAZIER    |   4 |  5 |  FRAZIER
   700 | GUINN      |   3 |  1 | 700
   700 | JUDAH      |   3 |  2 |  JUDAH
   700 | MARGARITO  |   3 |  3 |  MARGARITO
   700 | GUINN      |   3 |  4 |  GUINN
```

Finally, we add two flag columns that comes into play later.

```SQL
WITH x AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_apps
),
t AS (
  SELECT x.*, id,
         ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
    FROM x, (SELECT GENERATE_SERIES(1,2) AS id) y
)
SELECT 1 flag1, 0 flag2, deptno, rn,
       CASE WHEN rn = 1
            THEN deptno::VARCHAR
            ELSE ' ' || ename
       END AS it_dept
  FROM t
 WHERE rn <= cnt + 1;
```

```console
flag1 | flag2 | deptno | rn |   it_dept
-------+-------+--------+----+-------------
    1 |     0 |    400 |  1 | 400
    1 |     0 |    400 |  2 |  CORRALES
    1 |     0 |    400 |  3 |  MARQUEZ
    1 |     0 |    400 |  4 |  MAYWEATHER
    1 |     0 |    400 |  5 |  MOSLEY
    1 |     0 |    400 |  6 |  CASTILLO
                 -------
    1 |     0 |    500 |  1 | 500
    1 |     0 |    500 |  2 |  GATTI
    1 |     0 |    500 |  3 |  CALZAGHE
                 -------
    1 |     0 |    600 |  1 | 600
    1 |     0 |    600 |  2 |  HAGLER
    1 |     0 |    600 |  3 |  HEARNS
    1 |     0 |    600 |  4 |  LAMOTTA
    1 |     0 |    600 |  5 |  FRAZIER
                 -------
    1 |     0 |    700 |  1 | 700
    1 |     0 |    700 |  2 |  JUDAH
    1 |     0 |    700 |  3 |  MARGARITO
    1 |     0 |    700 |  4 |  GUINN
```

### LOWER part UNION ALL

```SQL
WITH x AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_apps
),
t AS (
  SELECT x.*, id,
         ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
    FROM x, (SELECT GENERATE_SERIES(1,2) AS id) y
),
x2 AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_research
),
t2 AS (
  SELECT x2.*, id,
         ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
    FROM x2, (SELECT GENERATE_SERIES(1,2) AS id) y
)
SELECT 1 flag1, 1 flag2, deptno, rn,
       CASE WHEN rn = 1
            THEN deptno::VARCHAR
            ELSE ' ' || ename
       END AS it_research
  FROM t2
 WHERE rn <= cnt + 1;
```

The lower part of the `UNION ALL` is processed in the same way as the upper part, so there’s no need to explain how that works.

```console
flag1 | flag2 | deptno | rn | it_research
-------+-------+--------+----+-------------
    1 |     1 |    100 |  1 | 100
    1 |     1 |    100 |  2 |  JONES
    1 |     1 |    100 |  3 |  TONEY
    1 |     1 |    100 |  4 |  HOPKINS
                --------
    1 |     1 |    200 |  1 | 200
    1 |     1 |    200 |  2 |  MORALES
    1 |     1 |    200 |  3 |  P.WHITAKER
    1 |     1 |    200 |  4 |  ROBINSON
    1 |     1 |    200 |  5 |  MARCIANO
                 -------
    1 |     1 |    300 |  1 | 300
    1 |     1 |    300 |  2 |  LACY
    1 |     1 |    300 |  3 |  WRIGHT
    1 |     1 |    300 |  4 |  J.TAYLOR
```

### Stacked results

Instead, let’s examine the result set returned when stacking the queries:

```SQL
WITH x AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_apps
),
t AS (
  SELECT x.*, id,
         ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
    FROM x, (SELECT GENERATE_SERIES(1,2) AS id) y
),
x2 AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_research
),
t2 AS (
  SELECT x2.*, id,
         ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
    FROM x2, (SELECT GENERATE_SERIES(1,2) AS id) y
)
SELECT 1 flag1, 0 flag2, deptno, rn,
       CASE WHEN rn = 1
            THEN deptno::VARCHAR
            ELSE ' ' || ename
       END AS it_dept
  FROM t
 WHERE rn <= cnt + 1
UNION ALL
SELECT 1 flag1, 1 flag2, deptno, rn,
       CASE WHEN rn = 1
            THEN deptno::VARCHAR
            ELSE ' ' || ename
       END AS it_research
  FROM t2
 WHERE rn <= cnt + 1
 ORDER BY flag2 DESC, deptno, rn;
```

```console
flag1 | flag2 | deptno | rn |   it_dept
-------+-------+--------+----+-------------
    1 |     1 |    100 |  1 | 100
    1 |     1 |    100 |  2 |  JONES
    1 |     1 |    100 |  3 |  TONEY
    1 |     1 |    100 |  4 |  HOPKINS
               ---------
    1 |     1 |    200 |  1 | 200
    1 |     1 |    200 |  2 |  MORALES
    1 |     1 |    200 |  3 |  P.WHITAKER
    1 |     1 |    200 |  4 |  ROBINSON
    1 |     1 |    200 |  5 |  MARCIANO
               ---------
    1 |     1 |    300 |  1 | 300
    1 |     1 |    300 |  2 |  LACY
    1 |     1 |    300 |  3 |  WRIGHT
    1 |     1 |    300 |  4 |  J.TAYLOR
               ---------
    --------------------------------------
    1 |     0 |    400 |  1 | 400
    1 |     0 |    400 |  2 |  CORRALES
    1 |     0 |    400 |  3 |  MARQUEZ
    1 |     0 |    400 |  4 |  MAYWEATHER
    1 |     0 |    400 |  5 |  MOSLEY
    1 |     0 |    400 |  6 |  CASTILLO
               ---------
    1 |     0 |    500 |  1 | 500
    1 |     0 |    500 |  2 |  GATTI
    1 |     0 |    500 |  3 |  CALZAGHE
               ---------
    1 |     0 |    600 |  1 | 600
    1 |     0 |    600 |  2 |  HAGLER
    1 |     0 |    600 |  3 |  HEARNS
    1 |     0 |    600 |  4 |  LAMOTTA
    1 |     0 |    600 |  5 |  FRAZIER
               ---------
    1 |     0 |    700 |  1 | 700
    1 |     0 |    700 |  2 |  JUDAH
    1 |     0 |    700 |  3 |  MARGARITO
    1 |     0 |    700 |  4 |  GUINN
```

At this point, it isn’t clear what FLAG1’s purpose is, but you can see that **FLAG2** `identifies which rows come from which part of the UNION ALL` (**0** for the `upper part`, **1** for the `lower part`).


```SQL
WITH x AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_apps
),
t AS (
  SELECT x.*, id,
         ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
    FROM x, (SELECT GENERATE_SERIES(1,2) AS id) y
),
x2 AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_research
),
t2 AS (
  SELECT x2.*, id,
         ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
    FROM x2, (SELECT GENERATE_SERIES(1,2) AS id) y
)
SELECT SUM(flag1) OVER (PARTITION BY flag2 ORDER BY flag2, deptno, rn) AS flag,
       it_dept, flag2, flag1
  FROM (
    SELECT 1 flag1, 0 flag2, deptno, rn,
           CASE WHEN rn = 1
                THEN deptno::VARCHAR
                ELSE ' ' || ename
           END AS it_dept
      FROM t
     WHERE rn <= cnt + 1
    UNION ALL
    SELECT 1 flag1, 1 flag2, deptno, rn,
           CASE WHEN rn = 1
                THEN deptno::VARCHAR
                ELSE ' ' || ename
           END AS it_dept
      FROM t2
     WHERE rn <= cnt + 1
  ) w
  ORDER BY flag2 DESC, flag;
```

The next step is to create a running total on `FLAG1` (finally, its purpose is revealed!), which will act as a ranking for each row in each stack. The results of the ranking (running total) are shown here:


```console
|flag |   it_dept   | flag2 | flag1|
|:---:|:-----------:|:-----:|:-----:|
|   1 | 100         |     1 |     1|
|   2 |  JONES      |     1 |     1|
|   3 |  TONEY      |     1 |     1|
|   4 |  HOPKINS    |     1 |     1|
|   5 | 200         |     1 |     1|
|   6 |  MORALES    |     1 |     1|
|   7 |  P.WHITAKER |     1 |     1|
|   8 |  ROBINSON   |     1 |     1|
|   9 |  MARCIANO   |     1 |     1|
|  10 | 300         |     1 |     1|
|  11 |  LACY       |     1 |     1|
|  12 |  WRIGHT     |     1 |     1|
|  13 |  J.TAYLOR   |     1 |     1|
--------------------------------------
|   1 | 400         |     0 |     1|
|   2 |  CORRALES   |     0 |     1|
|   3 |  MARQUEZ    |     0 |     1|
|   4 |  MAYWEATHER |     0 |     1|
|   5 |  MOSLEY     |     0 |     1|
|   6 |  CASTILLO   |     0 |     1|
|   7 | 500         |     0 |     1|
|   8 |  GATTI      |     0 |     1|
|   9 |  CALZAGHE   |     0 |     1|
|  10 | 600         |     0 |     1|
|  11 |  HAGLER     |     0 |     1|
|  12 |  HEARNS     |     0 |     1|
|  13 |  LAMOTTA    |     0 |     1|
|  14 |  FRAZIER    |     0 |     1|
|  15 | 700         |     0 |     1|
|  16 |  JUDAH      |     0 |     1|
|  17 |  MARGARITO  |     0 |     1|
|  18 |  GUINN      |     0 |     1|
```

The next step is to wrap the stacked result set in an CTE  and pivot the values returned into two columns.

```SQL
WITH x AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_apps
),
t AS (
  SELECT x.*, id,
         ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
    FROM x, (SELECT GENERATE_SERIES(1,2) AS id) y
),
x2 AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_research
),
t2 AS (
  SELECT x2.*, id,
         ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
    FROM x2, (SELECT GENERATE_SERIES(1,2) AS id) y
),
t3 AS (
  SELECT SUM(flag1) OVER (PARTITION BY flag2 ORDER BY flag2, deptno, rn) AS flag,
         it_dept, flag2, flag1
    FROM (
      SELECT 1 flag1, 0 flag2, deptno, rn,
             CASE WHEN rn = 1
                  THEN deptno::VARCHAR
                  ELSE ' ' || ename
             END AS it_dept
        FROM t
       WHERE rn <= cnt + 1
      UNION ALL
      SELECT 1 flag1, 1 flag2, deptno, rn,
             CASE WHEN rn = 1
                  THEN deptno::VARCHAR
                  ELSE ' ' || ename
             END AS it_dept
        FROM t2
       WHERE rn <= cnt + 1
    ) w
    ORDER BY flag2 DESC, flag
)
SELECT CASE WHEN flag2 = 1 THEN it_dept END AS research,
       CASE WHEN flag2 = 0 THEN it_dept END AS apps,
       flag
FROM t3;  
```

```console
research   |    apps     | flag
-------------+-------------+------
100         |             |    1
JONES      |             |    2
TONEY      |             |    3
HOPKINS    |             |    4
200         |             |    5
MORALES    |             |    6
P.WHITAKER |             |    7
ROBINSON   |             |    8
MARCIANO   |             |    9
300         |             |   10
LACY       |             |   11
WRIGHT     |             |   12
J.TAYLOR   |             |   13
           | 400         |    1
           |  CORRALES   |    2
           |  MARQUEZ    |    3
           |  MAYWEATHER |    4
           |  MOSLEY     |    5
           |  CASTILLO   |    6
           | 500         |    7
           |  GATTI      |    8
           |  CALZAGHE   |    9
           | 600         |   10
           |  HAGLER     |   11
           |  HEARNS     |   12
           |  LAMOTTA    |   13
           |  FRAZIER    |   14
           | 700         |   15
           |  JUDAH      |   16
           |  MARGARITO  |   17
           |  GUINN      |   18
```

Now let's get rid off the blank fields.

```SQL
WITH x AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_apps
),
t AS (
  SELECT x.*, id,
         ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
    FROM x, (SELECT GENERATE_SERIES(1,2) AS id) y
),
x2 AS (
  SELECT deptno,
         ename,
         COUNT(*) OVER(PARTITION BY deptno) AS cnt
    FROM it_research
),
t2 AS (
  SELECT x2.*, id,
         ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY id, ename) AS rn
    FROM x2, (SELECT GENERATE_SERIES(1,2) AS id) y
),
t3 AS (
  SELECT SUM(flag1) OVER (PARTITION BY flag2 ORDER BY flag2, deptno, rn) AS flag,
         it_dept, flag2, flag1
    FROM (
      SELECT 1 flag1, 0 flag2, deptno, rn,
             CASE WHEN rn = 1
                  THEN deptno::VARCHAR
                  ELSE ' ' || ename
             END AS it_dept
        FROM t
       WHERE rn <= cnt + 1
      UNION ALL
      SELECT 1 flag1, 1 flag2, deptno, rn,
             CASE WHEN rn = 1
                  THEN deptno::VARCHAR
                  ELSE ' ' || ename
             END AS it_dept
        FROM t2
       WHERE rn <= cnt + 1
    ) w
    ORDER BY flag2 DESC, flag
),
t4 AS (
  SELECT CASE WHEN flag2 = 1 THEN it_dept END AS research,
         CASE WHEN flag2 = 0 THEN it_dept END AS apps,
         flag
  FROM t3
)
SELECT MAX(research) AS research,
       MAX(apps) AS apps
  FROM t4
 GROUP BY flag
 ORDER BY flag;  
```

```console
research    |    apps
------------+-------------
100         | 400
 JONES      |  CORRALES
 TONEY      |  MARQUEZ
 HOPKINS    |  MAYWEATHER
200         |  MOSLEY
 MORALES    |  CASTILLO
 P.WHITAKER | 500
 ROBINSON   |  GATTI
 MARCIANO   |  CALZAGHE
300         | 600
 LACY       |  HAGLER
 WRIGHT     |  HEARNS
 J.TAYLOR   |  LAMOTTA
            |  FRAZIER
            | 700
            |  JUDAH
            |  MARGARITO
            |  GUINN
```
