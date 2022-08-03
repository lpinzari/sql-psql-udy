# Sorting by Substrings Problem

You want to **sort** the results of a query **by specific parts of a string**. For example, you want to return employee `names` and `jobs` from table `EMP` and **sort by** the **last two characters in the** `JOB` field. The result set should look like the following:

|ename  |    job|
|:------:|:---------:|
|TURNER | SALESM**AN**|
|ALLEN  | SALESMAN|
|WARD   | SALESMAN|
|MARTIN | SALESMAN|
|BLAKE  | MANAG**ER**|
|CLARK  | MANAGER|
|JONES  | MANAGER|
|KING   | PRESIDE**NT**|
|SMITH  | CLE**RK**|
|JAMES  | CLERK|
|MILLER | CLERK|
|ADAMS  | CLERK|
|SCOTT  | ANALY**ST**|
|FORD   | ANALYST|

**(14 rows)**

## Solution

### DB2, MySQL, Oracle, and PostgreSQL

Use the `SUBSTR` function in the `ORDER BY` clause:

```SQL
SELECT ename,job
  FROM emp
 ORDER BY SUBSTR(job,length(job)-1);
```

## Discussion

Using your DBMS’s substring function, you can easily sort by any part of a string. To sort by the last two characters of a string, find the end of the string (which is the length of the string) and subtract two. The start position will be the second to last character in the string. You then take all characters after that start position. 
