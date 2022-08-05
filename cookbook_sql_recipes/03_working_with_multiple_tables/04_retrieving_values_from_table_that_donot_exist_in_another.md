# Retrieving Values from One Table That Do Not Exist in Another

You want to find **those values in one table**, call it the `source table`, that do **not also exist** in some `target table`.


## Problem

For example, you want to find which departments (if any) in table `DEPT` do not exist in table `EMP`. In the example data, `DEPTNO 40` from table `DEPT` does not exist in table `EMP`,

```console
cookbook=> SELECT DISTINCT(deptno) FROM dept;
 deptno
--------
     40
     10
     30
     20
(4 rows)

cookbook=> SELECT DISTINCT(deptno) FROM emp;
 deptno
--------
     30
     10
     20
(3 rows)
```

so the result set should be the following:

|deptno|
|:------:|
|    40|

## Solution

Having functions that perform set difference is particularly useful for this problem. `DB2`, `PostgreSQL`, `SQL Server`, and `Oracle` all support set difference operations. If your DBMS does not support a set difference function, use a subquery


### DB2, PostgreSQL, and SQL Server

```SQL
SELECT deptno
  FROM dept
EXCEPT
SELECT deptno
  FROM emp;
```

Use a subquery to return all `DEPTNOs` from table `EMP` into an outer query that searches table `DEPT` for rows that are not among the rows returned from the subquery (**The following solution does not work with NULL values, see the Discussion section**):

```SQL
SELECT deptno
  FROM dept
 WHERE deptno NOT IN (SELECT deptno
                        FROM emp);
```

To avoid the problem with `NOT IN` and `NULLs`, use a correlated subquery in con‐ junction with [NOT EXISTS](https://github.com/lpinzari/sql-psql-udy/blob/master/05_subquery_cte/06_exists.md).

```SQL
SELECT d.deptno
  FROM dept d
 WHERE NOT EXISTS (
       SELECT 1
         FROM emp e
        WHERE d.deptno = e.deptno;
)
```


Use a `LEFT JOIN` to return to return all `DEPTNOs` from table `DEPT`:

```SQL
SELECT d.deptno
  FROM dept d
  LEFT JOIN emp e ON d.deptno = e.deptno
  WHERE e.deptno IS NULL;
```

## Discussion

**DB2, PostgreSQL, and SQL Server**

Set difference functions make this operation easy. The [EXCEPT](https://github.com/lpinzari/sql-psql-udy/blob/master/03_set_operators/03_except.md) operator takes the first result set and removes from it all rows found in the second result set. The operation is very much like a subtraction.
There are restrictions on the use of set operators, including `EXCEPT`. Data types and number of values to compare must match in both `SELECT` lists. Additionally, EXCEPT will not return duplicates and, unlike a subquery using NOT IN, NULLs do not present a problem. The EXCEPT operator will return rows from the upper query (the query before the EXCEPT) that do not exist in the lower query (the query after the EXCEPT).

```SQL
SELECT deptno
  FROM dept
 WHERE deptno NOT IN (SELECT deptno
                        FROM emp);
```

The subquery will return all `DEPTNOs` from table `EMP`. The outer query returns all `DEPTNOs` from table `DEPT` that are “not in” or “**not included in**” the result set returned from the subquery.

**Duplicate elimination** is something you’ll want to consider when using this solution. The `EXCEPT`-based solution eliminates duplicate rows from the result set, ensuring that each `DEPTNO` is reported only one time. Of course, that can only be the case anyway, as `DEPTNO` **is a key field in my example data**.

Were `DEPTNO` **not a key field**, you could use `DISTINCT` as follows to ensure that each `DEPTNO` value missing from `EMP` is reported only once:

```SQL
SELECT DISTINCT deptno
  FROM dept
 WHERE deptno NOT IN (SELECT deptno
                        FROM emp);
```

Be mindful of `NULLs` when using `NOT IN`. Consider the following table, `NEW_DEPT`:

```SQL
CREATE TABLE new_dept(deptno integer);
INSERT INTO new_dept VALUES (10);
INSERT INTO new_dept VALUES (50);
INSERT INTO new_dept VALUES (NULL);
```

```SQL
SELECT * FROM new_dept;
```

|deptno|
|:----:|
|    10|
|    50|
| NULL;|

```SQL
SELECT * FROM dept;
```

|deptno|
|:-----:|
|    40|
|    10|
|    30|
|    20|

If you try to find the `DEPTNOs` in table `DEPT` that do not exist in table `NEW_DEPT` and use a subquery with `NOT IN`, you’ll find that the query returns no rows:

```SQL
SELECT *
  FROM dept
 WHERE deptno NOT IN (SELECT deptno
                        FROM new_dept);
```

```console
deptno | dname | loc
--------+-------+-----
(0 rows)
```

DEPTNOs `20`, `30`, and `40` are not in table `NEW_DEPT`, yet were not returned by the query.

Why? The reason is the `NULL` value present in table `NEW_DEPT`. Three rows are returned by the subquery, with `DEPTNOs` of `10`, `50`, and `NULL`. `IN` and `NOT IN` are essentially `OR` operations and will yield different results because of how `NULL` values are treated by logical `OR` evaluations.

To understand [this](https://github.com/lpinzari/sql-psql-udy/blob/master/01_basic_sql/19_is_null_not_null.md), examine these truth tables (Let T=true, F=false, N=null):

|OR|T|F|N|
|:-:|:-:|:-:|:-:|
|T|T|T|T|
|F|T|F|N|
|N|T|N|N|

|NOT||
|:-:|:-:|
|T|F|
|F|T|
|N|N|

|AND|T|F|N|
|:-:|:-:|:-:|:-:|
|T|T|F|N|
|F|F|F|F|
|N|N|F|N|

Now consider the following example using `IN` and its equivalent using `OR`:

```SQL
SELECT * FROM dept;
```

|deptno|
|:-----:|
|    40|
|    10|
|    30|
|    20|


```SQL
SELECT deptno
  FROM dept
 WHERE deptno in ( 10,50,NULL);
```

```SQL
SELECT deptno
  FROM dept
 WHERE (deptno = 10 or deptno = 50 or deptno = NULL);
```

|deptno|
|:-----:|
|    10|

Why was only DEPTNO `10` returned? There are four DEPTNOs in DEPT, (10, 20, 30, 40), and each one is evaluated against the predicate `(deptno=10 or deptno=50 or deptno=null)`. According to the preceding truth tables, for each DEPTNO (10, 20, 30, 40), the predicate yields:

```console
DEPTNO=10
    (deptno=10 or deptno=50 or deptno=null)
    = (10=10 or 10=50 or 10=null)
    = (T or F or N)
    = (T or N)
    = (T)
```

```console
DEPTNO=20
    (deptno=10 or deptno=50 or deptno=null)
    = (20=10 or 20=50 or 20=null)
    = (F or F or N)
    = (F or N)
    = (N)
```

```console
DEPTNO=30
    (deptno=10 or deptno=50 or deptno=null)
    = (30=10 or 30=50 or 30=null)
    = (F or F or N)
    = (F or N)
    = (N)
```

```console
DEPTNO=40
    (deptno=10 or deptno=50 or deptno=null)
    = (40=10 or 40=50 or 40=null)
    = (F or F or N)
    = (F or N)
    = (N)
```

Now it is obvious why only DEPTNO 10 was returned when using IN and OR. Next, consider the same example using **NOT IN** and **NOT OR**:

```SQL
SELECT deptno
  FROM dept
 WHERE deptno NOT IN ( 10,50,NULL);
```

```SQL
SELECT deptno
  FROM dept
 WHERE NOT (deptno = 10 OR deptno = 50 OR deptno = NULL);
```

```console
deptno | dname | loc
--------+-------+-----
(0 rows)
```

Why are no rows returned? Let’s check the truth tables:

```console
DEPTNO=10
    NOT (deptno=10 or deptno=50 or deptno=null)
    = NOT (10=10 or 10=50 or 10=null)
    = NOT (T or F or N)
    = NOT (T or N)
    = NOT (T)
    = (F)
```

```console
DEPTNO=20
    NOT (deptno=10 or deptno=50 or deptno=null)
    = NOT (20=10 or 20=50 or 20=null)
    = NOT (F or F or N)
    = NOT (F or N)
    = NOT (N)
    = (N)
```

```console
DEPTNO=30
    NOT (deptno=10 or deptno=50 or deptno=null)
    = NOT (30=10 or 30=50 or 30=null)
    = NOT (F or F or N)
    = NOT (F or N)
    = NOT (N)
    = (N)
```

```console
DEPTNO=40
    NOT (deptno=10 or deptno=50 or deptno=null)
    = NOT (40=10 or 40=50 or 40=null)
    = NOT (F or F or N)
    = NOT (F or N)
    = NOT (N)
    = (N)
```

In SQL, “`TRUE or NULL`” is `TRUE`, but “`FALSE or NULL`” is `NULL`! You must keep this in mind when using `IN` predicates, and when performing logical `OR` evaluations and `NULL` values are involved.
To avoid the problem with `NOT IN` and `NULLs`, use a correlated subquery in con‐ junction with [NOT EXISTS](https://github.com/lpinzari/sql-psql-udy/blob/master/05_subquery_cte/06_exists.md). The term correlated subquery is used because rows from the outer query are referenced in the subquery. The following example is an alternative solution that will not be affected by `NULL` rows (going back to the original query from the “Problem” section):

```SQL
SELECT d.deptno
  FROM dept d
 WHERE NOT EXISTS (
       SELECT 1
         FROM emp e
        WHERE d.deptno = e.deptno);
```

|deptno|
|:------:|
|    40|

```SQL
SELECT d.deptno
  FROM dept d
 WHERE NOT EXISTS (
       SELECT 1
         FROM new_dept nd
        WHERE d.deptno = nd.deptno);
```

|deptno|
|:-----:|
|    20|
|    30|
|    40|

Conceptually, the outer query in this solution considers each row in the `DEPT` table. For each DEPT row, the following happens:

1. The subquery is executed to see whether the department number exists in the `EMP` table. Note the condition `D.DEPTNO = E.DEPTNO`, which brings together the department numbers from the two tables.
2. If the **subquery returns results**, then `EXISTS (...)` evaluates to true and `NOT EXISTS (...)` thus **evaluates to FALSE**, and the row being considered by the outer query is discarded.
3. If the **subquery returns no results**, then `NOT EXISTS (...)` evaluates to **TRUE**, and the row being considered by the outer query is returned (because it is for a department not represented in the EMP table).

The items in the `SELECT` list of the subquery are unimportant when using a **correlated subquery** with `EXISTS/NOT EXISTS`, which is why we chose to select NULL, to force you to focus on the join in the subquery rather than the items in the `SELECT` list.
