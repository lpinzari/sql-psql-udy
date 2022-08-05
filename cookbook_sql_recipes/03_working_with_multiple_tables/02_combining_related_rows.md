# Combining Related Rows Problem

You want to return rows from **multiple tables by** `joining` on a **known common column** or **joining on columns that share common values**.


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
 deptno   | integer               |***********|          |
Indexes:
    "emp_pkey" PRIMARY KEY, btree (empno)
```

**dept** table:

```console
cookbook=> \d dept
                       Table "public.dept"
 Column |         Type          | Collation | Nullable | Default
--------+-----------------------+-----------+----------+---------
 deptno | integer               |***********| not null |
 dname  | character varying(14) |           |          |
 loc    | character varying(13) |<----------|          |
Indexes:
    "dept_pkey" PRIMARY KEY, btree (deptno)
```

For example, you want to display the names of all employees in department `10` along with the `location` of each employee’s department, but that data is stored in two separate tables. You want the result set to be the following:

|ename  |   loc     |
|:------:|:--------:|
| CLARK  | NEW YORK|
| KING   | NEW YORK|
| MILLER | NEW YORK|

**(3 rows)**

## Solution

Join table `EMP` to table `DEPT` on `DEPTNO`:


```SQL
SELECT e.ename, d.loc
  FROM emp e, dept d
 WHERE e.deptno = d.deptno
       AND e.deptno = 10;
```

## Discussion

The solution is an example of a [join](https://github.com/lpinzari/sql-psql-udy/blob/master/02_joins_sql/03_what_is_a_join.md), or more accurately an **equi-join**, which is a type of [inner join](https://github.com/lpinzari/sql-psql-udy/blob/master/02_joins_sql/07_inner_join.md).

A join is an operation that combines rows from two tables into one. An **equi-join** is one in which the join condition is based on an equality condition (e.g., where one department number equals another).

An inner join is the original type of join; each row returned contains data from each table.

Conceptually, the result set from a join is produced by first creating a [Cartesian product](https://github.com/lpinzari/sql-psql-udy/blob/master/02_joins_sql/04_cross_join.md) (all possible combinations of rows) from the tables listed in the `FROM` clause, as shown here:

```SQL
SELECT e.ename,
       d.loc,
       e.deptno AS emp_deptno,
       d.deptno AS dept_deptno
  FROM emp e, dept d
 WHERE e.deptno = 10;
```

|ename  |   loc    | emp_deptno | dept_deptno|
|:-----:|:--------:|:----------:|:----------:|
|CLARK  | NEW YORK |         **10** |          **10**|
|KING   | NEW YORK |         **10** |          **10**|
|MILLER | NEW YORK |         **10** |          **10**|
|CLARK  | DALLAS   |         10 |          20|
|KING   | DALLAS   |         10 |          20|
|MILLER | DALLAS   |         10 |          20|
|CLARK  | CHICAGO  |         10 |          30|
|KING   | CHICAGO  |         10 |          30|
|MILLER | CHICAGO  |         10 |          30|
|CLARK  | BOSTON   |         10 |          40|
|KING   | BOSTON   |         10 |          40|
|MILLER | BOSTON   |         10 |          40|

**(12 rows)**

Every employee in table `EMP` (in department `10`) is returned along with every department in table `DEPT`. Then, the expression in the `WHERE` clause involving `e.deptno` and `d.deptno` (the join) restricts the result set such that the only rows returned are the ones where `EMP.DEPTNO` and `DEPT.DEPTNO` are equal:

```SQL
SELECT e.ename, d.loc,
       e.deptno as emp_deptno,
       d.deptno as dept_deptno
  FROM emp e, dept d
 WHERE e.deptno = d.deptno
       AND e.deptno = 10;
```

|ename  |   loc    | emp_deptno | dept_deptno|
|:-----:|:--------:|:----------:|:----------:|
|CLARK  | NEW YORK |         **10** |          **10**|
|KING   | NEW YORK |         **10** |          **10**|
|MILLER | NEW YORK |         **10** |          **10**|

An alternative solution makes use of an explicit `JOIN` clause (the **INNER** keyword is optional):

```SQL
SELECT e.ename, d.loc
  FROM emp e
 INNER JOIN dept d ON (e.deptno = d.deptno)
 WHERE e.deptno = 10;
```

Use the `JOIN` clause if you prefer to have the join logic in the `FROM` clause rather than the `WHERE` clause. Both styles are ANSI compliant and work on all the latest versions of the RDBMSs in this book.
