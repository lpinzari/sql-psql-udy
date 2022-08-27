# Deleting Records Referenced from Another Table

You want to `delete records` **from one table**

- when `those records` **are referenced from some other table**.


Consider the following table, named `DEPT_ACCIDENTS`, which contains one row for each accident that occurs in a manufacturing business. Each row records the department in which an accident occurred and also the `type` of accident.

```SQL
CREATE TABLE dept_accidents (
  deptno INTEGER,
  accident_name VARCHAR(20)
);

INSERT INTO dept_accidents
       (deptno, accident_name)
VALUES (10,'FLESH WOUND'),
       (20, 'FIRE'),
       (20, 'FIRE'),
       (20, 'FLOOD'),
       (30, 'BRUISED GLUTE');

SELECT * FROM dept_accidents;
```

|deptno | accident_name|
|:-----:|:------------:|
|    10 | FLESH WOUND|
|    20 | FIRE|
|    20 | FIRE|
|    20 | FLOOD|
|    30 | BRUISED GLUTE|

```console
cookbook=# SELECT * FROM emp_2;
 empno | ename  |   job    | mgr  |  hiredate  | sal  | comm | deptno
-------+--------+----------+------+------------+------+------+--------
  7369 | SMITH  | CLERK    | 7902 | 2015-12-17 |  800 |      |     20
  7499 | ALLEN  | SALESMAN | 7698 | 2006-01-20 | 1600 |  300 |     30
  7521 | WARD   | SALESMAN | 7698 | 2006-02-22 | 1250 |  500 |     30
  7566 | JONES  | MANAGER  | 7839 | 2006-04-02 | 2975 |      |     20
  7654 | MARTIN | SALESMAN | 7698 | 2006-09-28 | 1250 | 1400 |     30
  7698 | BLAKE  | MANAGER  | 7839 | 2006-05-01 | 2850 |      |     30
  7788 | SCOTT  | ANALYST  | 7566 | 2007-12-09 | 3000 |      |     20
  7844 | TURNER | SALESMAN | 7698 | 2006-09-08 | 1500 |    0 |     30
  7876 | ADAMS  | CLERK    | 7788 | 2008-01-12 | 1100 |      |     20
  7900 | JAMES  | CLERK    | 7698 | 2006-12-03 |  950 |      |     30
  7902 | FORD   | ANALYST  | 7566 | 2006-12-03 | 3000 |      |     20
```

You want to delete from `EMP_2` the records for those employees working at a department that **has three or more accidents**, (`20`).

```console
cookbook=# SELECT * FROM emp_2;
 empno | ename  |   job    | mgr  |  hiredate  | sal  | comm | deptno
-------+--------+----------+------+------------+------+------+--------
  7499 | ALLEN  | SALESMAN | 7698 | 2006-01-20 | 1600 |  300 |     30
  7521 | WARD   | SALESMAN | 7698 | 2006-02-22 | 1250 |  500 |     30
  7654 | MARTIN | SALESMAN | 7698 | 2006-09-28 | 1250 | 1400 |     30
  7698 | BLAKE  | MANAGER  | 7839 | 2006-05-01 | 2850 |      |     30
  7844 | TURNER | SALESMAN | 7698 | 2006-09-08 | 1500 |    0 |     30
  7900 | JAMES  | CLERK    | 7698 | 2006-12-03 |  950 |      |     30
```

## Solution

Use a subquery and the aggregate function `COUNT` to find the departments with three or more accidents. Then delete all employees working in those departments:

```SQL
DELETE FROM emp_2
 WHERE deptno IN (SELECT deptno
                    FROM dept_accidents
                   GROUP BY deptno
                  HAVING COUNT(*) >= 3);
```

## Discussion

The subquery will identify which departments have three or more accidents:

```SQL
SELECT deptno   
  FROM dept_accidents
 GROUP BY deptno
HAVING COUNT(*) >= 3;
```

|deptno|
|--------|
|    20|

The DELETE will then delete any employees in the departments returned by the sub‐ query (in this case, only in department 20).
