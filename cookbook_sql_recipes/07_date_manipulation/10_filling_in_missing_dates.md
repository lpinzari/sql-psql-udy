# Filling In Missing Dates

You need to **generate a row for every**

- `date` (or every `month`, `week`, or `year`) **within a given range**.

Such rowsets are often used to generate **summary reports**.

```console
cookbook=# \d emp
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

## Problem

For example, you want to count the number of employees hired every month of every year in which any employee has been hired. Examining the dates of all the employees hired, there have been hirings from `2006` to `2015`:

```SQL
SELECT DISTINCT EXTRACT(YEAR FROM hiredate) AS year
  FROM emp
 ORDER BY year;  
```

|year|
|:---:|
|2006|
|2007|
|2008|
|2015|

You want to determine the number of employees hired each month from `2006` to `2015`.

|yr_hr |  mth_hr   | counts_hr|
|:----:|:---------:|:--------:|
| 2006 | JANUARY   |         1|
| 2006 | FEBRUARY  |         1|
| 2006 | MARCH     |         0|
| 2006 | APRIL     |         1|
| 2006 | MAY       |         1|
| 2006 | JUNE      |         1|
| 2006 | JULY      |         0|
| 2006 | AUGUST    |         0|
| 2006 | SEPTEMBER |         2|
| 2006 | OCTOBER   |         0|
| 2006 | NOVEMBER  |         1|
| 2006 | DECEMBER  |         2|
| 2007 | JANUARY   |         1|
| 2007 | FEBRUARY  |         0|
| 2007 | MARCH     |         0|
| 2007 | APRIL     |         0|
| 2007 | MAY       |         0|
| 2007 | JUNE      |         0|
| 2007 | JULY      |         0|
| 2007 | AUGUST    |         0|
| 2007 | SEPTEMBER |         0|
| 2007 | OCTOBER   |         0|
| 2007 | NOVEMBER  |         0|
| 2007 | DECEMBER  |         1|
| .... | ........  | .......  |
| 2015 | NOVEMBER  |         0|
| 2015 | DECEMBER  |         1|


## Solution

The trick here is that you want to return a row for each month even if no employee was hired (i.e., the count would be zero). Because there isn’t an employee hired every month between 2006 and 2015, you must generate those months yourself and then outer join to table `EMP` on `HIREDATE` (truncating the actual HIREDATE to its month so it can match the generated months when possible).

Use `Recursive CTE` to generate each month between the start and end dates,and then `LEFT OUTER JOIN` on the `EMP` table using the month and year of each generated month to enable the COUNT of the number of hiredates in each period:

```SQL
WITH RECURSIVE temp (curr_date, end_date) AS (
  SELECT DATE_TRUNC('YEAR',min_hd)::DATE,
        (DATE_TRUNC('YEAR',max_hd)::DATE + INTERVAL '12 months')::DATE - 1 AS end_date
    FROM (SELECT MIN(hiredate) AS min_hd,
                 MAX(hiredate) AS max_hd
            FROM emp) mm
  UNION ALL
  SELECT (curr_date + INTERVAL '1 month')::DATE,
          end_date
    FROM temp
   WHERE curr_date <= (end_date - INTERVAL '2 month')::DATE + 1
)
SELECT EXTRACT('YEAR' FROM t.curr_date) AS yr_hr,
       TO_CHAR(t.curr_date,'MONTH') AS mth_hr,
       COUNT(hiredate) AS counts_hr
  FROM temp t
  LEFT JOIN emp e
    ON EXTRACT('MONTH' FROM t.curr_date) = EXTRACT('MONTH' FROM e.hiredate) AND
       EXTRACT('YEAR' FROM t.curr_date) = EXTRACT('YEAR' FROM e.hiredate)
 GROUP BY t.curr_date
 ORDER BY curr_date;
```



## Discussion

The first step is to generate every month (actually the first day of each month) from 2006 to 2015. Start using the `DATE_TRUNC` function on the MIN and MAX HIREDATEs to find the **boundary months**:

```SQL
WITH mm AS (
  SELECT MIN(hiredate) AS min_hd,
         MAX(hiredate) AS max_hd
    FROM emp
),
range AS (
  SELECT DATE_TRUNC('YEAR',min_hd)::DATE AS start_date,
         (DATE_TRUNC('YEAR',max_hd)::DATE + INTERVAL '12 months')::DATE - 1 AS end_date
    FROM mm
)
SELECT *
  FROM range;
```

|start_date |  end_date|
|:---------:|:---------:|
|2006-01-01 | 2015-12-31|



```SQL
WITH RECURSIVE temp (curr_date, end_date) AS (
  SELECT DATE_TRUNC('YEAR',min_hd)::DATE,
        (DATE_TRUNC('YEAR',max_hd)::DATE + INTERVAL '12 months')::DATE - 1 AS end_date
    FROM (SELECT MIN(hiredate) AS min_hd,
                 MAX(hiredate) AS max_hd
            FROM emp) mm
  UNION ALL
  SELECT (curr_date + INTERVAL '1 month')::DATE,
          end_date
    FROM temp
   WHERE curr_date <= (end_date - INTERVAL '2 month')::DATE + 1
)
SELECT *
  FROM temp;
```

Your next step is to repeatedly add months to START_DATE to return all the months necessary for the final result set. The value for END_DATE is one day more than it should be. This is OK. As you recursively add months to START_DATE, you can stop before you hit END_DATE.

```console
|curr_date  |  end_date|
|:---------:|:---------:|
|2006-01-01 | 2015-12-31|
|2006-02-01 | 2015-12-31|
|2006-03-01 | 2015-12-31|
|2006-04-01 | 2015-12-31|
|2006-05-01 | 2015-12-31|
|2006-06-01 | 2015-12-31|
|2006-07-01 | 2015-12-31|
|2006-08-01 | 2015-12-31|
|2006-09-01 | 2015-12-31|
|2006-10-01 | 2015-12-31|
|2006-11-01 | 2015-12-31|
|2006-12-01 | 2015-12-31|
|2007-01-01 | 2015-12-31|
|2007-02-01 | 2015-12-31|
|...........|...........|
|2015-11-01 | 2015-12-31|                   (end_date - INTERVAL '2 month')::DATE + 1
|2015-12-01 | 2015-12-31|<--- 2015-12-01 <=  2015-11-01 STOP
```

```SQL
SELECT hiredate,
       EXTRACT('MONTH' FROM hiredate) AS month,
       ename
  FROM emp
 ORDER BY hiredate;
```
The partial output for year `2006`:

```console
hiredate   | month | ename
------------+-------+-------
2006-01-20 |     1 | ALLEN
----------------------------
2006-02-22 |     2 | WARD
----------------------------
MISSING          3
----------------------------
2006-04-02 |     4 | JONES
----------------------------
2006-05-01 |     5 | BLAKE
----------------------------
2006-06-09 |     6 | CLARK
----------------------------
MISSING          7
----------------------------
MISSING          8
----------------------------
2006-09-08 |     9 | TURNER
2006-09-28 |     9 | MARTIN
-----------------------------
MISSING         10
-----------------------------
2006-11-17 |    11 | KING
-----------------------------
2006-12-03 |    12 | FORD
2006-12-03 |    12 | JAMES
------------------------------
.....
```

The output shows that no employees have been hired in the following months `3`,`7`,`8`,`10`.

```SQL
WITH RECURSIVE temp (curr_date, end_date) AS (
  SELECT DATE_TRUNC('YEAR',min_hd)::DATE,
        (DATE_TRUNC('YEAR',max_hd)::DATE + INTERVAL '12 months')::DATE - 1 AS end_date
    FROM (SELECT MIN(hiredate) AS min_hd,
                 MAX(hiredate) AS max_hd
            FROM emp) mm
  UNION ALL
  SELECT (curr_date + INTERVAL '1 month')::DATE,
          end_date
    FROM temp
   WHERE curr_date <= (end_date - INTERVAL '2 month')::DATE + 1
)
SELECT t.curr_date, hiredate, ename
  FROM temp t
  LEFT JOIN emp e
    ON EXTRACT('MONTH' FROM t.curr_date) = EXTRACT('MONTH' FROM e.hiredate) AND
       EXTRACT('YEAR' FROM t.curr_date) = EXTRACT('YEAR' FROM e.hiredate)
  ORDER BY curr_date;
```

The partial output for year `2006`:

```console
curr_date  |  hiredate  | ename                               COUNT
------------+------------+--------
2006-01-01 | 2006-01-20 | ALLEN                                 1
2006-02-01 | 2006-02-22 | WARD                                  1
2006-03-01 |            |       <--- FILLED IN MISSING MONTH    0
2006-04-01 | 2006-04-02 | JONES                                 1
2006-05-01 | 2006-05-01 | BLAKE                                 1
2006-06-01 | 2006-06-09 | CLARK                                 1
2006-07-01 |            |       <--- FILLED IN MISSING MONTH    0
2006-08-01 |            |       <--- FILLED IN MISSING MONTH    0
--------------------------------+
2006-09-01 | 2006-09-28 | MARTIN|    TWO PEOPLE HIRED           2
2006-09-01 | 2006-09-08 | TURNER|
--------------------------------+
2006-10-01 |            |       <--- FILLED IN MISSING MONTH    0
2006-11-01 | 2006-11-17 | KING                                  1
--------------------------------+
2006-12-01 | 2006-12-03 | FORD  |                               2
2006-12-01 | 2006-12-03 | JAMES |
```
At this point, you have all the months you need, and you can simply outer join to `EMP.HIREDATE`. Because the day for each `CURR_DATE` is the first of the month, truncate `EMP.HIREDATE` to the first day of its month. Finally, use the aggregate function `COUNT` on `EMP.HIREDATE`.

```SQL
WITH RECURSIVE temp (curr_date, end_date) AS (
  SELECT DATE_TRUNC('YEAR',min_hd)::DATE,
        (DATE_TRUNC('YEAR',max_hd)::DATE + INTERVAL '12 months')::DATE - 1 AS end_date
    FROM (SELECT MIN(hiredate) AS min_hd,
                 MAX(hiredate) AS max_hd
            FROM emp) mm
  UNION ALL
  SELECT (curr_date + INTERVAL '1 month')::DATE,
          end_date
    FROM temp
   WHERE curr_date <= (end_date - INTERVAL '2 month')::DATE + 1
)
SELECT EXTRACT('YEAR' FROM t.curr_date) AS yr_hr,
       TO_CHAR(t.curr_date,'MONTH') AS mth_hr,
       COUNT(hiredate) AS counts_hr
  FROM temp t
  LEFT JOIN emp e
    ON EXTRACT('MONTH' FROM t.curr_date) = EXTRACT('MONTH' FROM e.hiredate) AND
       EXTRACT('YEAR' FROM t.curr_date) = EXTRACT('YEAR' FROM e.hiredate)
 GROUP BY t.curr_date
 ORDER BY curr_date;
```
