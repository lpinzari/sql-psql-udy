# Using NULLs in Operations and Comparisons Problem

`NULL` is never equal to or not equal to any value, not even itself, but you want to evaluate values returned by a nullable column like you would evaluate real values.

## Problem

For example, you want to find `all employees` in **EMP** whose
 - commission (`COMM`) **is less than the commission of employee** `WARD`.

```console
 cookbook=> SELECT ename, comm
 cookbook->   FROM emp
 cookbook->  WHERE ename = 'WARD';
  ename | comm
 -------+------
  WARD  |  500
```

Employees with a `NULL` **commission should be included as well**.

## Solution

Use a function such as [COALESCE](https://github.com/lpinzari/sql-psql-udy/blob/master/07_data_cleaning/10_coalesce.md) to transform the `NULL` value into a real value that can be used in standard evaluation:

```SQL
SELECT ename,comm
  FROM emp
 WHERE COALESCE(comm,0) < ( SELECT comm
                              FROM emp
                             WHERE ename = 'WARD' );
```

|ename  | comm|
|:-----:|:-----:|
|SMITH  | NULL;|
|ALLEN  |   300|
|JONES  | NULL;|
|BLAKE  | NULL;|
|CLARK  | NULL;|
|SCOTT  | NULL;|
|KING   | NULL;|
|TURNER |     0|
|ADAMS  | NULL;|
|JAMES  | NULL;|
|FORD   | NULL;|
|MILLER | NULL;|

## Discussion

The `COALESCE` function will return the `first non-NULL` value from the list of values passed to it.
- When a NULL value is encountered, it is replaced by `zero`, which is then compared with WARD’s commission.

This can be seen by putting the `COALESCE` function in the `SELECT` list:

```SQL
SELECT ename,
       comm,
       COALESCE(comm,0)
  FROM emp
 WHERE COALESCE(comm,0) < ( SELECT comm
                              FROM emp
                             WHERE ename = 'WARD');
```

|ename  | comm  | coalesce|
|:-----:|:-----:|:--------:|
|SMITH  | NULL; |        0|
|ALLEN  |   300 |      300|
|JONES  | NULL; |        0|
|BLAKE  | NULL; |        0|
|CLARK  | NULL; |        0|
|SCOTT  | NULL; |        0|
|KING   | NULL; |        0|
|TURNER |     0 |        0|
|ADAMS  | NULL; |        0|
|JAMES  | NULL; |        0|
|FORD   | NULL; |        0|
|MILLER | NULL; |        0|
