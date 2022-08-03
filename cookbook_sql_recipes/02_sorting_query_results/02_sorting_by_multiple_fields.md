# Sorting by Multiple Fields Problem

You want to sort the rows from `EMP` first by `DEPTNO` **ascending**, then by `salary` **descending**. You want to return the following result set:

|empno | deptno | sal  | ename  |    job|
|:----:|:------:|:----:|:-------:|:----------:|
| 7839 |     **10** | 5000 | KING   | PRESIDENT|
| 7782 |     **10** | 2450 | CLARK  | MANAGER|
| 7934 |     **10** | 1300 | MILLER | CLERK|
| 7788 |     20 | 3000 | SCOTT  | ANALYST|
| 7902 |     20 | 3000 | FORD   | ANALYST|
| 7566 |     20 | 2975 | JONES  | MANAGER|
| 7876 |     20 | 1100 | ADAMS  | CLERK|
| 7369 |     20 |  800 | SMITH  | CLERK|
| 7698 |     **30** | 2850 | BLAKE  | MANAGER|
| 7499 |     **30** | 1600 | ALLEN  | SALESMAN|
| 7844 |     **30** | 1500 | TURNER | SALESMAN|
| 7521 |     **30** | 1250 | WARD   | SALESMAN|
| 7654 |     **30** | 1250 | MARTIN | SALESMAN|
| 7900 |     **30** |  950 | JAMES  | CLERK|

**(14 rows)**

## Solution

List the different sort columns in the ORDER BY clause, separated by commas:

```SQL
SELECT empno,deptno,sal,ename,job
  FROM emp
 ORDER BY deptno, sal DESC;
```

## Discussion

The order of precedence in `ORDER BY` is from **left to right**. If you are ordering using the numeric position of a column in the `SELECT` list, then **that number must not be greater than the number of items in the** `SELECT` list. You are generally permitted to order by a column not in the SELECT list, but to do so you must explicitly name the column.

However, if you are using `GROUP BY` or `DISTINCT` in your query, **you cannot order by columns that are not in the** `SELECT` list.
