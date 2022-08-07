# Creating a Delimited List from Table Rows

You want to return **table rows as values in a delimited list**, perhaps delimited by `commas`, rather than in vertical columns as they normally appear.

```SQL
SELECT deptno, ename
  FROM emp
 ORDER BY deptno;
```

|deptno | ename|
|:-----:|:------:|
|    10 | MILLER|
|    10 | CLARK|
|    10 | KING|
|    20 | SCOTT|
|    20 | JONES|
|    20 | SMITH|
|    20 | ADAMS|
|    20 | FORD|
|    30 | WARD|
|    30 | TURNER|
|    30 | ALLEN|
|    30 | BLAKE|
|    30 | MARTIN|
|    30 | JAMES|

to this:

|deptno |                 emps|
|:-----:|:-------------------------------------:|
|    10 | CLARK,KING,MILLER|
|    20 | SMITH,JONES,SCOTT,ADAMS,FORD|
|    30 | ALLEN,WARD,MARTIN,BLAKE,TURNER,JAMES|


## Solution

Each DBMS requires a different approach to this problem. The key is to take advantage of the built-in functions provided by your DBMS. Understanding what is available to you will allow you to exploit your DBMS’s functionality and come up with creative solutions for a problem that is typically not solved in SQL.

**PostgreSQL and SQL Server**

```SQL
SELECT deptno,
       STRING_AGG(ename, ',' ORDER BY empno) AS emps
  FROM emp
 GROUP BY deptno;
```

## Discussion

The [STRING_AGG](https://github.com/lpinzari/sql-psql-udy/blob/master/04_sql_aggregations/10_string_agg.md) function is used to group by `deptno`.
