# Computing an Average

You want to **compute the average value in a column**, either for all rows in a table or for some subset of rows.

## Problem

```console
cookbook=> \d emp
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

For example, you might want to find the `average salary` **for all** `employees` as well as the `average salary for each department`.

## Solution

When computing the **average of all employee salaries**, simply apply the [AVG](https://github.com/lpinzari/sql-psql-udy/blob/master/04_sql_aggregations/07_avg.md) function to the column containing those salaries.

By **excluding** a `WHERE` clause, the `average is computed against` **all non-NULL values**:

```SQL
SELECT AVG(sal) AS avg_sal
  FROM emp;
```

|avg_sal|
|:---------------------:|
|2073.2142857142857143|

Let's round the result to 4 decimal digits.

```SQL
SELECT ROUND(AVG(sal),4) AS avg_sal
  FROM emp;
```

|avg_sal|
|:---------:|
|2073.2143|

To compute the `average salary` **for each** `department`, use the **GROUP BY** clause to create a `group corresponding` to **each** `department`:

```SQL
SELECT deptno,
       ROUND(AVG(sal),4) AS avg_sal
  FROM emp
 GROUP BY deptno;
```

|deptno |  avg_sal|
|:-----:|:--------:|
|    30 | 1566.6667|
|    10 | 2916.6667|
|    20 | 2175.0000|

## Discussion

When finding an `average` where **the whole table is the group or window**, simply apply the **AVG** function to the column you are interested in **without** using the `GROUP BY` clause.

It is important to realize that the function `AVG` **ignores** `NULLs`. The effect of `NULL` values being ignored can be seen here:

```SQL
CREATE TABLE t2(sal INTEGER);

INSERT INTO t2 VALUES (10);
INSERT INTO t2 VALUES (20);
INSERT INTO t2 VALUES (NULL);
```

|sal|
|:----:|
|  10|
|  20|
|NULL|

```SQL
SELECT AVG(sal) AS not_null1         SELECT DISTINCT 30/2 AS _30_div_2;
  FROM t2;                             
```

```console

not_null1                               _30_div_2
----------                              ----------
      15                                   15
```

```SQL
SELECT sal, COALESCE(sal,0) AS colaesce_sal
  FROM t2;
```

|sal  | colaesce_sal|
|:---:|:------------:|
|  10 |           10|
|  20 |           20|
|NULL |            0|


```SQL
SELECT ROUND(AVG(COALESCE(sal,0)),2) AS null_zero   
  FROM t2;                               
```

```console

null_zero                                _30_div_3
---------------------                    ----------
10.00                                        10
```

The [COALESCE](https://github.com/lpinzari/sql-psql-udy/blob/master/07_data_cleaning/10_coalesce.md) function **will return the first** `non-NULL` **value found in the list of values that you pass**. When `NULL` SAL values are **converted to zero**, the average changes. When invoking aggregate functions, always give thought to how you want NULLs handled.

The second part of the solution uses `GROUP BY` to divide employee records into groups based on department affiliation. `GROUP BY` automatically causes aggregate functions such as `AVG` to **execute and return a result for each group**. In this example, `AVG` would execute once for each **department-based group of employee records**.

It is not necessary, by the way, to include `GROUP BY` columns in your select list. For example:

```SQL
SELECT ROUND(AVG(sal),4) AS avg_sal
  FROM emp
 GROUP BY deptno;
```

|avg_sal|
|:---------:|
|1566.6667|
|2916.6667|
|2175.0000|

You are still grouping by `DEPTNO` even though it is not in the `SELECT` clause. **Including the column you are grouping by** in the `SELECT` clause often improves **readability, but is not mandatory**.

```console
cookbook=> SELECT ename, AVG(sal)
cookbook->   FROM emp
cookbook->  GROUP BY deptno;
ERROR:  column "emp.ename" must appear in the GROUP BY clause or be used in an aggregate function
LINE 1: SELECT ename, AVG(sal)
               ^
```

**It is mandatory**, however, **to avoid placing columns in your** `SELECT` **list that are not also in your** `GROUP BY` clause.


## Remark

The (arithmetic) mean of an attribute (also called average in popular parlance, and expectation or expected value in statistics) in a dataset is simply the sum of the values divided by the number of `non-NULL` values. In all SQL systems, as we have seen, there is an aggregate function, `AVG()`, that calculates this:

```SQL
SELECT AVG(Attr) AS mean
  FROM data;
```

Note that, by definition, this is the same as:

```SQL
SELECT SUM(Attr) / (COUNT(Attr) * 1.0) AS mean
  FROM data;
```

We are using once again the trick of multiplying by 1.0 to make sure the system uses floating point division, not integer division.
