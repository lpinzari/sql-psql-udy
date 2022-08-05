# Returning Missing Data from Multiple Tables Problem

You want to return `missing data` **from multiple tables simultaneously**.
Returning rows from table `DEPT` that do not exist in table `EMP` (any departments that have no employees) requires an outer join.

Table **emp**:

```console
cookbook=> SELECT * FROM emp ORDER BY deptno, empno;
 empno | ename  |    job    |  mgr  |  hiredate  | sal  | comm  | deptno
-------+--------+-----------+-------+------------+------+-------+--------
  7782 | CLARK  | MANAGER   |  7839 | 2006-06-09 | 2450 | NULL; |     10
  7839 | KING   | PRESIDENT | NULL; | 2006-11-17 | 5000 | NULL; |     10
  7934 | MILLER | CLERK     |  7782 | 2007-01-23 | 1300 | NULL; |     10
  7369 | SMITH  | CLERK     |  7902 | 2015-12-17 |  800 | NULL; |     20
  7566 | JONES  | MANAGER   |  7839 | 2006-04-02 | 2975 | NULL; |     20
  7788 | SCOTT  | ANALYST   |  7566 | 2007-12-09 | 3000 | NULL; |     20
  7876 | ADAMS  | CLERK     |  7788 | 2008-01-12 | 1100 | NULL; |     20
  7902 | FORD   | ANALYST   |  7566 | 2006-12-03 | 3000 | NULL; |     20
  7499 | ALLEN  | SALESMAN  |  7698 | 2006-01-20 | 1600 |   300 |     30
  7521 | WARD   | SALESMAN  |  7698 | 2006-02-22 | 1250 |   500 |     30
  7654 | MARTIN | SALESMAN  |  7698 | 2006-09-28 | 1250 |  1400 |     30
  7698 | BLAKE  | MANAGER   |  7839 | 2006-05-01 | 2850 | NULL; |     30
  7844 | TURNER | SALESMAN  |  7698 | 2006-09-08 | 1500 |     0 |     30
  7900 | JAMES  | CLERK     |  7698 | 2006-12-03 |  950 | NULL; |     30
(14 Rows)
```

Table **dept**:

```console
cookbook=> SELECT * FROM dept ORDER BY deptno;
 deptno |   dname    |   loc
--------+------------+----------
     10 | ACCOUNTING | NEW YORK
     20 | RESEARCH   | DALLAS
     30 | SALES      | CHICAGO
     40 | OPERATIONS | BOSTON
```

Consider the following query, which returns all `DEPTNOs` and `DNAMEs` from `DEPT` along with the `names` of all the employees in each department (if there is an employee in a particular department):

```SQL
SELECT d.deptno,
       d.dname,
       e.ename
  FROM dept d
  LEFT JOIN emp e USING (deptno)
 ORDER BY deptno, empno;  
```

|deptno |   dname    | ename|
|:-----:|:----------:|:-----:|
|    10 | ACCOUNTING | CLARK|
|    10 | ACCOUNTING | KING|
|    10 | ACCOUNTING | MILLER|
|    20 | RESEARCH   | SMITH|
|    20 | RESEARCH   | JONES|
|    20 | RESEARCH   | SCOTT|
|    20 | RESEARCH   | ADAMS|
|    20 | RESEARCH   | FORD|
|    30 | SALES      | ALLEN|
|    30 | SALES      | WARD|
|    30 | SALES      | MARTIN|
|    30 | SALES      | BLAKE|
|    30 | SALES      | TURNER|
|    30 | SALES      | JAMES|
|    40 | OPERATIONS | NULL;|

**(15 rows)**

The last row, the `OPERATIONS` department, is returned despite that department not having any employees, because table EMP was outer joined to table `DEPT`.

Now, suppose there was an employee without a department. After creating the new employee:

```SQL
INSERT INTO emp
       (empno,ename,job,mgr,hiredate,sal,comm,deptno)
 SELECT 1111,'YODA','JEDI',null,hiredate,sal,comm,null
   FROM emp
  WHERE ename = 'KING';
```

```SQL
SELECT * FROM emp WHERE deptno IS NULL;
```

| empno | ename | job  |  mgr  |  hiredate  | sal  | comm  | deptno|
|:------:|:----:|:----:|:-----:|:----------:|:----:|:-----:|:-----:|
|  1111 | YODA  | JEDI | NULL; | 2006-11-17 | 5000 | NULL; |  NULL;|

How would you return the previous result set along with a row for the employee having no department? In other words, **you want to outer join to both table** `EMP` and table `DEPT`, and in the same query.

```SQL
SELECT d.deptno,
       d.dname,
       e.ename
  FROM dept d
 RIGHT JOIN emp e USING (deptno)
 ORDER BY deptno, empno;
```

|deptno |   dname    | ename|
|:-----:|:----------:|:-----:|
|    10 | ACCOUNTING | CLARK|
|    10 | ACCOUNTING | KING|
|    10 | ACCOUNTING | MILLER|
|    20 | RESEARCH   | SMITH|
|    20 | RESEARCH   | JONES|
|    20 | RESEARCH   | SCOTT|
|    20 | RESEARCH   | ADAMS|
|    20 | RESEARCH   | FORD|
|    30 | SALES      | ALLEN|
|    30 | SALES      | WARD|
|    30 | SALES      | MARTIN|
|    30 | SALES      | BLAKE|
|    30 | SALES      | TURNER|
|    30 | SALES      | JAMES|
| NULL; | NULL;      | YODA|

This outer join manages to return the new employee but lost the `OPERATIONS` department from the original result set. The final result set should return a row for `YODA` as well as `OPERATIONS`, such as the following:

|deptno |   dname    | ename|
|:-----:|:----------:|:-----:|
|    10 | ACCOUNTING | CLARK|
|    10 | ACCOUNTING | KING|
|    10 | ACCOUNTING | MILLER|
|    20 | RESEARCH   | SMITH|
|    20 | RESEARCH   | JONES|
|    20 | RESEARCH   | SCOTT|
|    20 | RESEARCH   | ADAMS|
|    20 | RESEARCH   | FORD|
|    30 | SALES      | ALLEN|
|    30 | SALES      | WARD|
|    30 | SALES      | MARTIN|
|    30 | SALES      | BLAKE|
|    30 | SALES      | TURNER|
|    30 | SALES      | JAMES|
|    40 | OPERATIONS | NULL;|
| NULL; | NULL;      | YODA|

## Solution

Use a [full outer join](https://github.com/lpinzari/sql-psql-udy/blob/master/02_joins_sql/08_outer_join.md) to return missing data from both tables based on a common value.

**DB2, MySQL, PostgreSQL, and SQL Server**

```SQL
SELECT d.deptno,
       d.dname,
       e.ename
  FROM dept d
  FULL JOIN emp e USING(deptno)
 ORDER BY deptno, empno;  
```
Alternatively, since MySQL does not yet have a FULL OUTER JOIN, UNION the results of the two different outer joins:

```SQL
SELECT d.deptno,d.dname,e.ename
  FROM dept d
 RIGHT JOIN emp e USING (deptno)
UNION
SELECT d.deptno,d.dname,e.ename
  FROM dept d
  LEFT JOIN emp e USING (deptno);
```
