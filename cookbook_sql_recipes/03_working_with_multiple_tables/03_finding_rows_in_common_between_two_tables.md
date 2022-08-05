# Finding Rows in Common Between Two Tables Problem

You want to find **common rows between two tables**, but there are multiple columns on which you can join.

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



For example, consider the following [view](https://github.com/lpinzari/sql-psql-udy/tree/master/09_view) v created from the `EMP` table for teaching purposes:

```SQL
CREATE VIEW v AS
       SELECT ename,job,sal
         FROM emp
        WHERE job = 'CLERK';
```
```SQL
SELECT * FROM v;
```

| ename  |  job  | sal|
|:------:|:-----:|:----:|
| SMITH  | CLERK |  800|
| ADAMS  | CLERK | 1100|
| JAMES  | CLERK |  950|
| MILLER | CLERK | 1300|

**(4 rows)**


Only clerks are returned from view `v`. However, the view **does not show all possible** `EMP` columns. You want to return the **EMPNO**, `ENAME`, `JOB`, `SAL`, and **DEPTNO** of all employees in `EMP` that match the rows from view v.

You want the result set to be the following:


|empno | ename  |  job  | sal  | deptno|
|:----:|:------:|:-----:|:----:|:-----:|
| 7369 | SMITH  | CLERK |  800 |     20|
| 7876 | ADAMS  | CLERK | 1100 |     20|
| 7900 | JAMES  | CLERK |  950 |     30|
| 7934 | MILLER | CLERK | 1300 |     10|

**(4 rows)**


## Solution

Join the tables on all the columns necessary to return the correct result. Alternatively, use the set operation `INTERSECT` to avoid performing a join and instead return the intersection (common rows) of the two tables.

```console

   |  v  |         |   emp e  |
   |-----|         |----------|
 * |ename|         |empno     |  
 * |job  |        *|ename     |
 * |sal  |        *|job       |
                   |mgr       |
                   |hiredate  |
                  *|sal       |
                   |comm      |
                   |deptno    |
```

```SQL
SELECT e.empno,
       e.ename,
       e.job,
       e.sal,
       e.deptno
  FROM emp e, v
 WHERE e.ename = v.ename
       AND e.job   = v.job
       AND e.sal   = v.sal;
```

Alternatively, you can perform the same join via the `JOIN` clause:

```SQL
SELECT e.empno,
       e.ename,
       e.job,
       e.sal,
       e.deptno
  FROM emp e
  JOIN v ON ( e.ename AND e.job AND e.sal);
```

If you do not actually need to return columns from view `v`, you may use the set operation [INTERSECT](https://github.com/lpinzari/sql-psql-udy/blob/master/03_set_operators/02_intersect.md) along with an [IN](https://github.com/lpinzari/sql-psql-udy/blob/master/01_basic_sql/16_in_not_in.md) predicate:

```SQL
SELECT empno,
       ename,
       job,
       sal,
       deptno
  FROM emp
 WHERE (ename,job,sal) IN (
        SELECT ename,job,sal
          FROM emp
        INTERSECT
        SELECT ename,job,sal
          FROM v);
```

## Discussion

When performing joins, you must consider the proper columns to join in order to return correct results. This is especially important when rows can have common values for some columns while having different values for others.
The set operation `INTERSECT` will return rows common to both row sources. When using `INTERSECT`, you are required to **compare the same number of items**, having the **same data type**, from two tables. When working with set operations, keep in mind that, by default, **duplicate rows will not be returned**.
