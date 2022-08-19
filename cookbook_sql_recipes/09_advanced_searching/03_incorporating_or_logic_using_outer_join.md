# Incorporating OR Logic When Using Outer Joins

You want to return
- the `name` and `department` information for **all employees**
  1. `in` **departments 10** and **20**
  2. along with department information for **departments 30** and **40** (**but no employee information**).

**emp** table:

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

|ename  | deptno|
|:-----:|:-----:|
|MILLER |     10|
|CLARK  |     10|
|KING   |     10|
|SCOTT  |     20|
|JONES  |     20|
|SMITH  |     20|
|ADAMS  |     20|
|FORD   |     20|
|WARD   |     30|
|TURNER |     30|
|ALLEN  |     30|
|BLAKE  |     30|
|MARTIN |     30|
|JAMES  |     30|

**dept** table:

```console
cookbook=# \d dept
                       Table "public.dept"
 Column |         Type          | Collation | Nullable | Default
--------+-----------------------+-----------+----------+---------
 deptno | integer               |           | not null |
 dname  | character varying(14) |           |          |
 loc    | character varying(13) |           |          |
Indexes:
    "dept_pkey" PRIMARY KEY, btree (deptno)
```

|deptno |   dname    |   loc|
|:-----:|:----------:|:-------:|
|    10 | ACCOUNTING | NEW YORK|
|    20 | RESEARCH   | DALLAS|
|    30 | SALES      | CHICAGO|
|    40 | OPERATIONS | BOSTON|


you would like the result set to be the following:

|ename  | deptno |   dname    |   loc|
|:-----:|:------:|:----------:|:-------:|
|MILLER |     10 | ACCOUNTING | NEW YORK|
|CLARK  |     10 | ACCOUNTING | NEW YORK|
|KING   |     10 | ACCOUNTING | NEW YORK|
|SCOTT  |     20 | RESEARCH   | DALLAS|
|JONES  |     20 | RESEARCH   | DALLAS|
|SMITH  |     20 | RESEARCH   | DALLAS|
|ADAMS  |     20 | RESEARCH   | DALLAS|
|FORD   |     20 | RESEARCH   | DALLAS|
|       |     30 | SALES      | CHICAGO|
|       |     40 | OPERATIONS | BOSTON|

## Solution

```SQL
SELECT e.ename, d.deptno, d.dname, d.loc
  FROM dept d
  LEFT JOIN emp e  
    ON (d.deptno = e.deptno AND (d.deptno = 10 OR d.deptno = 20))
 ORDER BY 2;  
```

- **Solution 2**:

```SQL
WITH emp2 AS (
  SELECT ename, deptno
    FROM emp
   WHERE deptno IN (10,20)
)
SELECT e.ename, d.deptno, d.dname, d.loc
  FROM dept d
  LEFT JOIN emp2 e USING(deptno)
 ORDER BY 2;
```

## Discussion

```SQL
SELECT e.ename, d.deptno, d.dname, d.loc
  FROM dept d
 INNER JOIN emp e USING (deptno)
 ORDER BY 2;  
```

|ename  | deptno |   dname    |   loc|
|:-----:|:------:|:----------:|:-------:|
|MILLER |     10 | ACCOUNTING | NEW YORK|
|CLARK  |     10 | ACCOUNTING | NEW YORK|
|KING   |     10 | ACCOUNTING | NEW YORK|
|SCOTT  |     20 | RESEARCH   | DALLAS|
|JONES  |     20 | RESEARCH   | DALLAS|
|SMITH  |     20 | RESEARCH   | DALLAS|
|ADAMS  |     20 | RESEARCH   | DALLAS|
|FORD   |     20 | RESEARCH   | DALLAS|
|WARD   |     30 | SALES      | CHICAGO|
|TURNER |     30 | SALES      | CHICAGO|
|ALLEN  |     30 | SALES      | CHICAGO|
|BLAKE  |     30 | SALES      | CHICAGO|
|MARTIN |     30 | SALES      | CHICAGO|
|JAMES  |     30 | SALES      | CHICAGO|

Because the join in this query is an inner join, the result set does not include department information for DEPTNO 40.

```SQL
SELECT e.ename, d.deptno, d.dname, d.loc
  FROM dept d
  LEFT JOIN emp e USING (deptno)
 ORDER BY 2;  
```

|ename  | deptno |   dname    |   loc|
|:-----:|:------:|:----------:|:-------:|
|MILLER |     10 | ACCOUNTING | NEW YORK|
|CLARK  |     10 | ACCOUNTING | NEW YORK|
|KING   |     10 | ACCOUNTING | NEW YORK|
|SMITH  |     20 | RESEARCH   | DALLAS|
|JONES  |     20 | RESEARCH   | DALLAS|
|SCOTT  |     20 | RESEARCH   | DALLAS|
|ADAMS  |     20 | RESEARCH   | DALLAS|
|FORD   |     20 | RESEARCH   | DALLAS|
|WARD   |     30 | SALES      | CHICAGO|
|TURNER |     30 | SALES      | CHICAGO|
|ALLEN  |     30 | SALES      | CHICAGO|
|JAMES  |     30 | SALES      | CHICAGO|
|BLAKE  |     30 | SALES      | CHICAGO|
|MARTIN |     30 | SALES      | CHICAGO|
|       |     40 | OPERATIONS | BOSTON|

We want to exclude the employee's name in deptno `30` and `40`.

Your first attempt looks like this:

```SQL
SELECT e.ename, d.deptno, d.dname, d.loc
  FROM dept d
  LEFT JOIN emp e USING (deptno)
 WHERE (d.deptno = 10 OR d.deptno = 20)
 ORDER BY 2;  
```

|ename  | deptno |   dname    |   loc|
|:-----:|:------:|:----------:|:--------:|
|MILLER |     10 | ACCOUNTING | NEW YORK|
|CLARK  |     10 | ACCOUNTING | NEW YORK|
|KING   |     10 | ACCOUNTING | NEW YORK|
|SCOTT  |     20 | RESEARCH   | DALLAS|
|SMITH  |     20 | RESEARCH   | DALLAS|
|ADAMS  |     20 | RESEARCH   | DALLAS|
|JONES  |     20 | RESEARCH   | DALLAS|
|FORD   |     20 | RESEARCH   | DALLAS|

Move the OR condition into the JOIN clause:

```SQL
SELECT e.ename, d.deptno, d.dname, d.loc
  FROM dept d
  LEFT JOIN emp e  
    ON (d.deptno = e.deptno AND (d.deptno = 10 OR d.deptno = 20))
 ORDER BY 2;  
```

|ename  | deptno |   dname    |   loc|
|:-----:|:------:|:----------:|:-------:|
|CLARK  |     10 | ACCOUNTING | NEW YORK|
|KING   |     10 | ACCOUNTING | NEW YORK|
|MILLER |     10 | ACCOUNTING | NEW YORK|
|ADAMS  |     20 | RESEARCH   | DALLAS|
|FORD   |     20 | RESEARCH   | DALLAS|
|SMITH  |     20 | RESEARCH   | DALLAS|
|JONES  |     20 | RESEARCH   | DALLAS|
|SCOTT  |     20 | RESEARCH   | DALLAS|
|       |     30 | SALES      | CHICAGO|
|       |     40 | OPERATIONS | BOSTON|

Alternatively, you can filter on `EMP.DEPTNO` first and then outer join:

```SQL
WITH emp2 AS (
  SELECT ename, deptno
    FROM emp
   WHERE deptno IN (10,20)
)
SELECT e.ename, d.deptno, d.dname, d.loc
  FROM dept d
  LEFT JOIN emp2 e USING(deptno)
 ORDER BY 2;
```
