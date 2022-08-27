# UPSERT (UP-dating AND In-SERT)

You want to `conditionally` **insert** or **update** records in a table `depending on` **whether corresponding records exist**.

- If a `record exists`, then **update**;
- if `not`, then **insert**.

## Problem

```SQL
CREATE TABLE emp_2 (
  empno INTEGER PRIMARY KEY,
  ename VARCHAR(10),
  job VARCHAR(9),
  mgr INTEGER,
  hiredate DATE,
  sal INTEGER,
  comm INTEGER,
  deptno INTEGER
);

INSERT INTO emp_2  
SELECT *
  FROM emp;

SELECT * FROM emp_2;
```

```console
+---------------------------------------------------------------------+
|empno | ename  |    job    | mgr  |  hiredate  | sal  | comm | deptno|
|------+--------+-----------+------+------------+------+------+-------|
| 7369 | SMITH  | CLERK     | 7902 | 2015-12-17 |  800 |      |     20|
| 7499 | ALLEN  | SALESMAN  | 7698 | 2006-01-20 | 1600 |  300 |     30|
| 7521 | WARD   | SALESMAN  | 7698 | 2006-02-22 | 1250 |  500 |     30|
| 7566 | JONES  | MANAGER   | 7839 | 2006-04-02 | 2975 |      |     20|
| 7654 | MARTIN | SALESMAN  | 7698 | 2006-09-28 | 1250 | 1400 |     30|
| 7698 | BLAKE  | MANAGER   | 7839 | 2006-05-01 | 2850 |      |     30|
| 7782 | CLARK  | MANAGER   | 7839 | 2006-06-09 | 2450 |      |     10|
| 7788 | SCOTT  | ANALYST   | 7566 | 2007-12-09 | 3000 |      |     20|
| 7839 | KING   | PRESIDENT |      | 2006-11-17 | 5000 |      |     10|
| 7844 | TURNER | SALESMAN  | 7698 | 2006-09-08 | 1500 |    0 |     30|
| 7876 | ADAMS  | CLERK     | 7788 | 2008-01-12 | 1100 |      |     20|
| 7900 | JAMES  | CLERK     | 7698 | 2006-12-03 |  950 |      |     30|
| 7902 | FORD   | ANALYST   | 7566 | 2006-12-03 | 3000 |      |     20|
| 7934 | MILLER | CLERK     | 7782 | 2007-01-23 | 1300 |      |     10|
+---------------------------------------------------------------------+
```

The blank fields in the `comm` column represents `NULL` values. This result is clear if we run the following query:

```SQL
SELECT empno, ename, job, mgr, hiredate, sal,
       CASE WHEN comm IS NULL
            THEN 'NULL'
            ELSE 'NOT NULL'
       END AS comm_d,
       comm, deptno
  FROM emp_2;
```

```console
+--------------------------------------------------------------------------------+
|empno | ename  |    job    | mgr  |  hiredate  | sal  |  comm_d  | comm | deptno|
|------+--------+-----------+------+------------+------+----------+------+-------|
| 7369 | SMITH  | CLERK     | 7902 | 2015-12-17 |  800 | NULL     |      |     20|
| 7499 | ALLEN  | SALESMAN  | 7698 | 2006-01-20 | 1600 | NOT NULL |  300 |     30|
| 7521 | WARD   | SALESMAN  | 7698 | 2006-02-22 | 1250 | NOT NULL |  500 |     30|
| 7566 | JONES  | MANAGER   | 7839 | 2006-04-02 | 2975 | NULL     |      |     20|
| 7654 | MARTIN | SALESMAN  | 7698 | 2006-09-28 | 1250 | NOT NULL | 1400 |     30|
| 7698 | BLAKE  | MANAGER   | 7839 | 2006-05-01 | 2850 | NULL     |      |     30|
| 7782 | CLARK  | MANAGER   | 7839 | 2006-06-09 | 2450 | NULL     |      |     10|
| 7788 | SCOTT  | ANALYST   | 7566 | 2007-12-09 | 3000 | NULL     |      |     20|
| 7839 | KING   | PRESIDENT |      | 2006-11-17 | 5000 | NULL     |      |     10|
| 7844 | TURNER | SALESMAN  | 7698 | 2006-09-08 | 1500 | NOT NULL |    0 |     30|
| 7876 | ADAMS  | CLERK     | 7788 | 2008-01-12 | 1100 | NULL     |      |     20|
| 7900 | JAMES  | CLERK     | 7698 | 2006-12-03 |  950 | NULL     |      |     30|
| 7902 | FORD   | ANALYST   | 7566 | 2006-12-03 | 3000 | NULL     |      |     20|
| 7934 | MILLER | CLERK     | 7782 | 2007-01-23 | 1300 | NULL     |      |     10|
+--------------------------------------------------------------------------------+
```

The first step is to set all the missing value commission to `0`.

```SQL
UPDATE emp_2
   SET comm = 0
 WHERE comm IS NULL;
```

Let's check the `comm` column again.

```SQL
SELECT * FROM emp_2;
```

```console
+---------------------------------------------------------------------+
|empno | ename  |    job    | mgr  |  hiredate  | sal  | comm | deptno|
|-------+--------+----------+------+------------+------+------+-------|
| 7499 | ALLEN  | SALESMAN  | 7698 | 2006-01-20 | 1600 |  300 |     30|
| 7521 | WARD   | SALESMAN  | 7698 | 2006-02-22 | 1250 |  500 |     30|
| 7654 | MARTIN | SALESMAN  | 7698 | 2006-09-28 | 1250 | 1400 |     30|
| 7844 | TURNER | SALESMAN  | 7698 | 2006-09-08 | 1500 |    0 |     30|
| 7369 | SMITH  | CLERK     | 7902 | 2015-12-17 |  800 |    0 |     20|
| 7566 | JONES  | MANAGER   | 7839 | 2006-04-02 | 2975 |    0 |     20|
| 7698 | BLAKE  | MANAGER   | 7839 | 2006-05-01 | 2850 |    0 |     30|
| 7782 | CLARK  | MANAGER   | 7839 | 2006-06-09 | 2450 |    0 |     10|
| 7788 | SCOTT  | ANALYST   | 7566 | 2007-12-09 | 3000 |    0 |     20|
| 7839 | KING   | PRESIDENT |      | 2006-11-17 | 5000 |    0 |     10|
| 7876 | ADAMS  | CLERK     | 7788 | 2008-01-12 | 1100 |    0 |     20|
| 7900 | JAMES  | CLERK     | 7698 | 2006-12-03 |  950 |    0 |     30|
| 7902 | FORD   | ANALYST   | 7566 | 2006-12-03 | 3000 |    0 |     20|
| 7934 | MILLER | CLERK     | 7782 | 2007-01-23 | 1300 |    0 |     10|
----------------------------------------------------------------------+
```

Foe example, suppose we have table `emp_commission` that contains information about employees' commission.

```SQL
CREATE TABLE emp_commission (
  empno INTEGER PRIMARY KEY,
  ename VARCHAR(10),
  deptno INTEGER,
  comm INTEGER
);

INSERT INTO emp_commission
SELECT empno, ename, deptno, comm
  FROM emp_2
 WHERE comm > 0;
```

```console
|empno | ename  | deptno | comm |
|------+--------+--------+------|
| 7499 | ALLEN  |     30 |  300 |
| 7521 | WARD   |     30 |  500 |
| 7654 | MARTIN |     30 | 1400 |
```
It's worth noting that all employees with a commission greater than zero are listed in the `emp_commission` table.

- **Problem 1**:

For example, you want to modify table `EMP_COMMISSION` such that:

- If any employee in `EMP_COMMISSION` also exists in table `EMP` and their `salary` is less than or equal to **1500** and commission is less than **1000**, then  increase of `50%` their commission (**update** their commission (`COMM`) 50%).

- Otherwise, **insert** the `EMPNO`, `ENAME`, and `DEPTNO` values from table `EMP` into table `EMP_COMMISSION` and add **500** dollars to comm where the `salary` is less than equal to **1000** otherwise add **100** dollars to comm.


The updated `EMP_COMMISSION` table is given below:


|empno | ename  | deptno | comm|
|:----:|:------:|:------:|:----:|
| 7654 | MARTIN |     30 | 1400|
| 7499 | ALLEN  |     30 |  450|
| 7521 | WARD   |     30 |  750|
| 7844 | TURNER |     30 |  100|
| 7369 | SMITH  |     20 |  500|
| 7566 | JONES  |     20 |  100|
| 7698 | BLAKE  |     30 |  100|
| 7782 | CLARK  |     10 |  100|
| 7788 | SCOTT  |     20 |  100|
| 7839 | KING   |     10 |  100|
| 7876 | ADAMS  |     20 |  100|
| 7900 | JAMES  |     30 |  500|
| 7902 | FORD   |     20 |  100|
| 7934 | MILLER |     10 |  100|

- **Explanation**

```console
                                           +------------------------------+
                                           |empno | ename  | deptno | comm|
                                           |:----:|:------:|:------:|:---:|
                                           | 7654 | MARTIN |     30 | 1400|
                                           | 7499 | ALLEN  |     30 |  450| ---+
                                           | 7521 | WARD   |     30 |  750| ---+
                                           +------------------------------+    |
                                                                               |
+-----------------------------+            +------------------------------+    |
|deptno | ename  | sal  | comm|            |empno | ename  | deptno | comm|    |
|------:|:------:|:----:|:---:|            |-----:|:------:|:------:|:---:|    |
|30     | MARTIN | 1250 | 1400|sal < 1500  | 7654 | MARTIN |     30 | 1400|    V
|30     | WARD   | 1250 |  500|comm < 1000 | 7521 | WARD   |     30 |  750| * UPDATED
|30     | ALLEN  | 1600 |  300|            | 7499 | ALLEN  |     30 |  450| * UPDATED
-------------------------------           ---------------------------------- MATCHING
(sal <= 1000 -> sal + 500) ELSE sal + 100  NOT MATCHING ROWS.

|30     | JAMES  |  950 |    0|  + 500     | 7900 | JAMES  |     30 |  500|
|30     | TURNER | 1500 |    0|  + 100     | 7844 | TURNER |     30 |  100|
|30     | BLAKE  | 2850 |    0|  + 100     | 7698 | BLAKE  |     30 |  100|
|20     | SMITH  |  800 |    0|  + 500     | 7369 | SMITH  |     20 |  500|
|20     | ADAMS  | 1100 |    0|  + 100     | 7876 | ADAMS  |     20 |  100|
|20     | JONES  | 2975 |    0|  + 100     | 7566 | JONES  |     20 |  100|
|20     | SCOTT  | 3000 |    0|  + 100     | 7788 | SCOTT  |     20 |  100|
|20     | FORD   | 3000 |    0|  + 100     | 7902 | FORD   |     20 |  100|
|10     | MILLER | 1300 |    0|  + 100     | 7934 | MILLER |     10 |  100|
|10     | CLARK  | 2450 |    0|  + 100     | 7782 | CLARK  |     10 |  100|
|10     | KING   | 5000 |    0|  + 100     | 7839 | KING   |     10 |  100|
```



- **Problem 2**:

Update the `EMP_2` table with the new commission values taken from the `EMP_COMMISSION` table.

```console
empno | ename  |    job    | mgr  |  hiredate  | sal  | comm | deptno
-------+--------+-----------+------+------------+------+------+--------
 7654 | MARTIN | SALESMAN  | 7698 | 2006-09-28 | 1250 | 1400 |     30
 7499 | ALLEN  | SALESMAN  | 7698 | 2006-01-20 | 1600 |  450 |     30
 7521 | WARD   | SALESMAN  | 7698 | 2006-02-22 | 1250 |  750 |     30
 7844 | TURNER | SALESMAN  | 7698 | 2006-09-08 | 1500 |  100 |     30
 7369 | SMITH  | CLERK     | 7902 | 2015-12-17 |  800 |  500 |     20
 7566 | JONES  | MANAGER   | 7839 | 2006-04-02 | 2975 |  100 |     20
 7698 | BLAKE  | MANAGER   | 7839 | 2006-05-01 | 2850 |  100 |     30
 7782 | CLARK  | MANAGER   | 7839 | 2006-06-09 | 2450 |  100 |     10
 7788 | SCOTT  | ANALYST   | 7566 | 2007-12-09 | 3000 |  100 |     20
 7839 | KING   | PRESIDENT |      | 2006-11-17 | 5000 |  100 |     10
 7876 | ADAMS  | CLERK     | 7788 | 2008-01-12 | 1100 |  100 |     20
 7900 | JAMES  | CLERK     | 7698 | 2006-12-03 |  950 |  500 |     30
 7902 | FORD   | ANALYST   | 7566 | 2006-12-03 | 3000 |  100 |     20
 7934 | MILLER | CLERK     | 7782 | 2007-01-23 | 1300 |  100 |     10
```

## Solution

- **Problem 1**:

A solution is to use the [ON CONFLICT](https://www.postgresql.org/docs/current/sql-insert.html) clause.

```SQL
INSERT INTO emp_commission
       (empno, ename, deptno, comm)
       SELECT e2.empno, e2.ename, e2.deptno,
              CASE WHEN e2.sal <= 1000 THEN e2.comm + 500
                                       ELSE e2.comm + 100
              END AS comm
         FROM emp_2 e2
         LEFT JOIN emp_commission ec ON (ec.empno = e2.empno AND e2.sal <= 1500)
       ON CONFLICT ON CONSTRAINT emp_commission_pkey DO
          UPDATE SET comm = emp_commission.comm*1.5
          WHERE emp_commission.comm  <= 1000;
```

The join `ON (ec.empno = e2.empno AND e2.sal <= 1500)`  of the solution determines what rows already exist and will be updated. The join is between `EMP_COMMISSION`  and the `EMP_2` table.

- When the join succeeds, the **two rows are considered** “`matched`,” and the `UPDATE` specified in the `DO` section **is executed**.
- Otherwise, no match is found, and the `INSERT` is executed only for the records in the left table of the join.

Thus, rows from table `EMP` that do not have corresponding rows based on `EMPNO` in table `EMP_COMMISSION` **will be inserted into** `EMP_COMMISSION`.

- **Problem 2**:

```SQL
UPDATE emp_2
   SET comm = ec.comm
  FROM emp_commission ec
 WHERE ec.empno = emp_2.empno;
```


## Discussion

Let's try first a simple query to update only the records in the `emp_commission` table where the salary is less than or equal to 1500.

```SQL
INSERT INTO emp_commission
       (empno, ename, deptno, comm)
       SELECT e2.empno, e2.ename, e2.deptno, e2.comm*1.5
         FROM emp_2 e2
         JOIN emp_commission ec ON (ec.empno = e2.empno)
        WHERE e2.sal <= 1500;
```

The execution of the above query will fail:

```console
ERROR:  duplicate key value violates unique constraint "emp_commission_pkey"
DETAIL:  Key (empno)=(7499) already exists.
```

This result is obvious since the insertion is based on an equality between the primary keys of both tables. How do we handle this problem?

A solution is to use the `ON CONFLICT` clause.

```SQL
INSERT INTO emp_commission
       (empno, ename, deptno, comm)
       SELECT e2.empno, e2.ename, e2.deptno,
              CASE WHEN e2.sal <= 1000 THEN e2.comm + 500
                                       ELSE e2.comm + 100
              END AS comm
         FROM emp_2 e2
         LEFT JOIN emp_commission ec ON (ec.empno = e2.empno AND e2.sal <= 1500)
       ON CONFLICT ON CONSTRAINT emp_commission_pkey DO
          UPDATE SET comm = emp_commission.comm*1.5
          WHERE emp_commission.comm  <= 1000;
```

- **Problem 2**:

```console
cookbook=# \d emp_2
                       Table "public.emp_2"
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
    "emp_2_pkey" PRIMARY KEY, btree (empno)
```

```SQL
UPDATE emp_2
   SET comm = ec.comm
  FROM emp_commission ec
 WHERE ec.empno = emp_2.empno;
```
