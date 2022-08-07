# Ordering by Parts of a String

You want to **order your result set based on a substring**.

## Problem

Consider the following records:

```SQL
SELECT ename
  FROM emp;
```

|ename|
|:------:|
|SMITH|
|ALLEN|
|WARD|
|JONES|
|MARTIN|
|BLAKE|
|CLARK|
|SCOTT|
|KING|
|TURNER|
|ADAMS|
|JAMES|
|FORD|
|MILLER|

You want the records to be ordered based on the last two characters of each name:

|ename|
|--------|
|ALLEN|
|MILLER|
|TURNER|
|JAMES|
|JONES|
|MARTIN|
|BLAKE|
|ADAMS|
|KING|
|FORD|
|WARD|
|CLARK|
|SMITH|
|SCOTT|


**DB2, Oracle, MySQL, and PostgreSQL**

Use a combination of the built-in functions `LENGTH` and [SUBSTR](https://github.com/lpinzari/sql-psql-udy/blob/master/06_string_functions/17_substring.md) to order by a specific part of a string:

```SQL
SELECT ename
  FROM emp
 ORDER BY SUBSTR(ename,LENGTH(ename)-1,LENGTH(ename));
```

## Discussion

By using a SUBSTR expression in your ORDER BY clause, you can pick any part of a string to use in ordering a result set. You’re not limited to SUBSTR either. You can order rows by the result of almost any expression.

```SQL
SELECT ename,
       SUBSTR(ename,LENGTH(ename)-1,LENGTH(ename)) AS last2
  FROM emp
 ORDER BY SUBSTR(ename,LENGTH(ename)-1,LENGTH(ename));
```

|ename  | last2|
|:-----:|:----:|
|ALLEN  | EN|
|MILLER | ER|
|TURNER | ER|
|JAMES  | ES|
|JONES  | ES|
|MARTIN | IN|
|BLAKE  | KE|
|ADAMS  | MS|
|KING   | NG|
|FORD   | RD|
|WARD   | RD|
|CLARK  | RK|
|SMITH  | TH|
|SCOTT  | TT|
