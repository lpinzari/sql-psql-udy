# Stacking One Rowset atop Another Problem

You want to **return data stored in more than one table, conceptually stacking one result set atop the other**.

The tables `do not necessarily have a common key`, but their columns do have the **same data types**.

**t1** table:

```console
cookbook=> \d t1
                 Table "public.t1"
 Column |  Type   | Collation | Nullable | Default
--------+---------+-----------+----------+---------
 id     | integer |           |          |
```


**emp** table:

```console
cookbook=> \d emp
                        Table "public.emp"
  Column  |         Type          | Collation | Nullable | Default
----------+-----------------------+-----------+----------+---------
 empno    | integer               |           | not null |
 ename    | character varying(10) |<----------|          |
 job      | character varying(9)  |           |          |
 mgr      | integer               |           |          |
 hiredate | date                  |           |          |
 sal      | integer               |           |          |
 comm     | integer               |           |          |
 deptno   | integer               |<----------|          |
Indexes:
    "emp_pkey" PRIMARY KEY, btree (empno)
```

**dept** table:

```console
cookbook=> \d dept
                       Table "public.dept"
 Column |         Type          | Collation | Nullable | Default
--------+-----------------------+-----------+----------+---------
 deptno | integer               |<----------| not null |
 dname  | character varying(14) |<----------|          |
 loc    | character varying(13) |           |          |
Indexes:
    "dept_pkey" PRIMARY KEY, btree (deptno)
```


For example, you want to display
- the `name` and `department number` of the employees in department `10` in table `EMP`, along with
- the `name` and `department number` of each department in table `DEPT`. You want the result set to look like the following:

**Results**

|ename_and_dname | deptno|
|:--------------:|:------:|
|CLARK           |     10|
|KING            |     10|
|MILLER          |     10|
|----------      |  NULL;|
|ACCOUNTING      |     10|
|RESEARCH        |     20|
|SALES           |     30|
|OPERATIONS      |     40|

**(8 rows)**


## Solution

Use the set operation [UNION ALL](https://github.com/lpinzari/sql-psql-udy/blob/master/03_set_operators/01_union.md) to **combine rows from multiple tables**:


```SQL
SELECT ename as ename_and_dname,
       deptno
  FROM emp
 WHERE deptno = 10

UNION ALL

SELECT '----------',
       NULL
  FROM t1

UNION ALL

SELECT dname,
       deptno
  FROM dept;
```

## Discussion

**UNION ALL** combines rows from multiple row sources into one result set. As with all set operations, the items in all the `SELECT` lists must match in number and data type. For example, both of the following queries will fail:

```SQL
SELECT deptno     |  SELECT deptno, dname
  FROM dept       |    FROM dept
 UNION ALL        |  UNION ALL
SELECT ename      |  SELECT deptno
  FROM emp        |    FROM emp
```

It is important to note, `UNION ALL` **will include duplicates if they exist**.

If you want to **filter out duplicates**, use the `UNION` operator. For example, a `UNION` between `EMP.DEPTNO` and `DEPT.DEPTNO` returns only four rows:

```SQL
SELECT deptno
  FROM emp
UNION
SELECT deptno
  FROM dept;
```

|deptno|
|:------:|
|    10|
|    30|
|    40|
|    20|

**(4 rows)**

Specifying `UNION` rather than `UNION ALL` will most likely result in a sort **operation to eliminate duplicates**.

Keep this in mind when working with large result sets. Using `UNION` is roughly equivalent to the following query, which applies [DISTINCT](https://github.com/lpinzari/sql-psql-udy/blob/master/02_joins_sql/14_distinct_duplicates.md) to the output from a `UNION ALL`:

```SQL
SELECT DISTINCT deptno
  FROM (SELECT deptno
          FROM emp
    UNION ALL
        SELECT deptno
          FROM dept );
```

You wouldn’t use `DISTINCT` in a query unless you had to, and the same rule applies for `UNION`: don’t use it instead of `UNION ALL` unless you have to. 
