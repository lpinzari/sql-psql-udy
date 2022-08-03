# Returning n Random Records from a Table Problem

You want to return a **specific number of random records from a table**. You want to modify the following statement such that successive executions will produce a different set of five rows:

```SQL
SELECT ename, job
  FROM emp;
```

**Output**

|ename  |    job|
|:-----:|:----------:|
|SMITH  | CLERK|
|ALLEN  | SALESMAN|
|WARD   | SALESMAN|
|JONES  | MANAGER|
|MARTIN | SALESMAN|
|BLAKE  | MANAGER|
|CLARK  | MANAGER|
|SCOTT  | ANALYST|
|KING   | PRESIDENT|
|TURNER | SALESMAN|
|ADAMS  | CLERK|
|JAMES  | CLERK|
|FORD   | ANALYST|
|MILLER | CLERK|

**(14 rows)**

## Solution

Take any **built-in function supported by your DBMS for returning random values**. Use that function in an `ORDER BY` clause to sort rows randomly. Then, use the previous recipe’s technique to limit the number of randomly sorted rows to return.

### PostgreSQL

PostgreSQL provides the random() function that returns a random number between `0` and `1`.

Use the built-in **RANDOM** function in conjunction with `LIMIT` and `ORDER BY`:

```SQL
SELECT ename,job
  FROM emp
 ORDER BY random() limit 5;
```

|ename  |   job|
|:-----:|:---------:|
|FORD   | ANALYST|
|TURNER | SALESMAN|
|MARTIN | SALESMAN|
|MILLER | CLERK|
|ALLEN  | SALESMAN|

**(5 rows)**

### DB2

Use the built-in function `RAND` in conjunction with `ORDER BY` and `FETCH`:

```SQL
select ename,job
  from emp
 order by rand() fetch first 5 rows only;
```

### MySQL

Use the built-in `RAND` function in conjunction with `LIMIT` and `ORDER BY`:

```SQL
select ename,job
  from emp
 order by rand() limit 5;
```

### Oracle
Use the built-in function `VALUE`, found in the built-in package `DBMS_RANDOM`, in conjunction with `ORDER BY` and the built-in function `ROWNUM`:

```SQL
select *
from (
select ename, job
from emp
order by dbms_random.value() 7)
where rownum <= 5;
```

## SQL Server

Use the built-in function `NEWID` in conjunction with `TOP` and `ORDER BY` to return a random result set:

```SQL
select top 5 ename,job
  from emp
 order by newid();
```

## Discussion

The ORDER BY clause can accept a function’s return value and use it to change the order of the result set. These solutions all restrict the number of rows to return after the function in the ORDER BY clause is executed. Non-Oracle users may find it helpful to look at the Oracle solution as it shows (conceptually) what is happening under the covers of the other solutions.
It is important that you don’t confuse using a function in the ORDER BY clause with using a numeric constant. When specifying a numeric constant in the ORDER BY clause, you are requesting that the sort be done according the column in that ordinal position in the SELECT list. When you specify a function in the ORDER BY clause, the sort is performed on the result from the function as it is evaluated for each row.
