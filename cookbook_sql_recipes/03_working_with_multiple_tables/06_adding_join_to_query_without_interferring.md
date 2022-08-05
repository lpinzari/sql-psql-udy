# Adding Joins to a Query Without Interfering with Other Joins

You have a query that returns the results you want. You **need additional information, but when trying to get it, you lose data from the original result set**.

## Problem

For example, you want to return all employees, the location of the department in which they work, and the date they received a bonus. For this problem, the `EMP_BONUS` table contains the following data:

```SQL
CREATE TABLE emp_bonus (
        empno integer NOT NULL,
        received DATE,
        type integer
);
```

```SQL
INSERT INTO emp_bonus
       (empno,received,type)
VALUES
       (7369,'2005-03-14',1),
       (7900,'2005-03-14',2),
       (7788,'2005-03-14',3);
```

```SQL
SELECT * FROM emp_bonus;
```

|empno |  received  | type|
|:----:|:----------:|:----:|
| 7369 | 2005-03-14 |    1|
| 7900 | 2005-03-14 |    2|
| 7788 | 2005-03-14 |    3|

The query you start with looks like this:

```SQL
SELECT e.ename, d.loc
  FROM emp e, dept d
 WHERE e.deptno = d.deptno;
```

|ename  |   loc|
|:-----:|:-------:|
|SMITH  | DALLAS|
|ALLEN  | CHICAGO|
|WARD   | CHICAGO|
|JONES  | DALLAS|
|MARTIN | CHICAGO|
|BLAKE  | CHICAGO|
|CLARK  | NEW YORK|
|SCOTT  | DALLAS|
|KING   | NEW YORK|
|TURNER | CHICAGO|
|ADAMS  | DALLAS|
|JAMES  | CHICAGO|
|FORD   | DALLAS|
|MILLER | NEW YORK|

**(14 rows)**

You want to add to these results the date a bonus was given to an employee, but joining to the `EMP_BONUS` table **returns fewer rows than you want because not every employee has a bonus**:

```SQL
SELECT e.ename,
       d.loc,
       eb.received
  FROM emp e, dept d, emp_bonus eb
 WHERE e.deptno = d.deptno
       AND e.empno = eb.empno;
```

|ename |   loc   |  received|
|:----:|:-------:|:----------:|
|SMITH | DALLAS  | 2005-03-14|
|JAMES | CHICAGO | 2005-03-14|
|SCOTT | DALLAS  | 2005-03-14|

**(3 rows)**

Your desired result set is the following:

|ename  |   loc    |  received|
|:-----:|:--------:|:---------:|
|MARTIN | CHICAGO  | NULL;|
|TURNER | CHICAGO  | NULL;|
|JAMES  | CHICAGO  | 2005-03-14|
|WARD   | CHICAGO  | NULL;|
|ALLEN  | CHICAGO  | NULL;|
|BLAKE  | CHICAGO  | NULL;|
|FORD   | DALLAS   | NULL;|
|SCOTT  | DALLAS   | 2005-03-14|
|ADAMS  | DALLAS   | NULL;|
|JONES  | DALLAS   | NULL;|
|SMITH  | DALLAS   | 2005-03-14|
|CLARK  | NEW YORK | NULL;|
|MILLER | NEW YORK | NULL;|
|KING   | NEW YORK | NULL;|

**(14 rows)**

## Solution

You can **use an outer join to obtain the additional information without losing the data from the original query**.

- First join table `EMP` to table `DEPT` to get all employees and the location of the department they work,
- then outer join to table `EMP_ BONUS` to return the date of the bonus if there is one.

The following is the DB2, MySQL, Post‐ greSQL, and SQL server syntax:

```SQL
SELECT e.ename,
       d.loc,
       eb.received
  FROM emp e
  JOIN dept d ON (e.deptno = d.deptno)
  LEFT JOIN emp_bonus eb ON (e.empno = eb.empno)
 ORDER BY 2;
```

You can also use a scalar subquery (a subquery placed in the SELECT list) to mimic an outer join:

```SQL
SELECT e.ename,
       d.loc,
       (SELECT eb.received
          FROM emp_bonus eb
         WHERE eb.empno = e.empno) as received
  FROM emp e, dept d
 WHERE e.deptno = d.deptno
 ORDER BY 2;
```

The scalar [subquery](https://github.com/lpinzari/sql-psql-udy/blob/master/05_subquery_cte/01_intro_subquery.md) solution will work across all platforms.

## Discussion

An outer join will return all rows from one table and matching rows from another. See the previous recipe for another example of such a join. The reason an outer join works to solve this problem is that it does not result in any rows being eliminated that would otherwise be returned. The query will return all the rows it would return without the outer join. And it also returns the received date, if one exists.

Use of a scalar subquery is also a convenient technique for this sort of problem, as it does not require you to modify already correct joins in your main query. Using a scalar subquery is an easy way to tack on extra data to a query without compromising the current result set. When working with scalar subqueries, you must ensure they return a scalar (single) value. **If a subquery in the SELECT list returns more than one row, you will receive an error**.
