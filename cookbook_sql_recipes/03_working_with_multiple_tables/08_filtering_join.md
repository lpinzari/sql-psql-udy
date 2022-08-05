# Identifying and Avoiding Cartesian Products Problem

You want to return the name of each employee in department 10 along with the location of the department. The following query is returning incorrect data:

```SQL
SELECT e.ename, d.loc
  FROM emp e, dept d
 WHERE e.deptno = 10;
```

|ename  |   loc|
|:-----:|:--------:|
|CLARK  | NEW YORK|
|KING   | NEW YORK|
|MILLER | NEW YORK|
|CLARK  | DALLAS|
|KING   | DALLAS|
|MILLER | DALLAS|
|CLARK  | CHICAGO|
|KING   | CHICAGO|
|MILLER | CHICAGO|
|CLARK  | BOSTON|
|KING   | BOSTON|
|MILLER | BOSTON|

The correct result set is the following:

|ename  |   loc|
|:-----:|:-------:|
|CLARK  | NEW YORK|
|KING   | NEW YORK|
|MILLER | NEW YORK|


## Solution

Use a join between the tables in the FROM clause to return the correct result set:

```SQL
SELECT e.ename, d.loc
  FROM emp e, dept d
 WHERE e.deptno = 10
       AND d.deptno = e.deptno;
```

## Discussion

Let’s look at the data in the DEPT table:

|deptno |   dname    |   loc|
|:-----:|:----------:|:---------:|
|    10 | ACCOUNTING | NEW YORK|
|    20 | RESEARCH   | DALLAS|
|    30 | SALES      | CHICAGO|
|    40 | OPERATIONS | BOSTON|

You can see that department 10 is in New York, and thus you can know that returning employees with any location other than New York is incorrect. The number of rows returned by the incorrect query is the product of the cardinalities of the two tables in the FROM clause. In the original query, the filter on EMP for department 10 will result in three rows. Because there is no filter for DEPT, all four rows from DEPT are returned. Three multiplied by four is twelve, so the incorrect query returns twelve rows. Generally, to avoid a Cartesian product, you would apply the n–1 rule where n represents the number of tables in the FROM clause and n–1 represents the mini‐ mum number of joins necessary to avoid a Cartesian product. Depending on what the keys and join columns in your tables are, you may very well need more than n–1 joins, but n–1 is a good place to start when writing queries.
