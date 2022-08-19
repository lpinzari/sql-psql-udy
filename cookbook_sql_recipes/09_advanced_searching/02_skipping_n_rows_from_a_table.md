# Skipping n Rows from a Table

You want a query to return `every other employee` in table `EMP`; you want
- the first employee,
- third employee,
- and so forth.

For example, from the following result set:

```SQL
SELECT ename
  FROM emp
 ORDER BY ename;
```

| ename|
|:------:|
| **ADAMS**|
| ALLEN|
| **BLAKE**|
| CLARK|
| **FORD**|
| JAMES|
| **JONES**|
| KING|
| **MARTIN**|
| MILLER|
| **SCOTT**|
| SMITH|
| **TURNER**|
| WARD|

you want to return the following:

|rn | ename|
|:-:|:-----:|
| 1 | ADAMS|
| 3 | BLAKE|
| 5 | FORD|
| 7 | JONES|
| 9 | MARTIN|
|11 | SCOTT|
|13 | TURNER|


## Solution

To skip the `second` or `fourth` or `nth` row from a result set, you must impose **order on the result set**; otherwise, there is no concept of first or next, second, or fourth.

Use the window function `ROW_NUMBER OVER` to assign a number to each row, which you can then use in conjunction with the `modulo function` **to skip unwanted rows**.

```SQL
SELECT ROW_NUMBER() OVER (ORDER BY ename) AS rn,
       ename
  FROM emp
 ORDER BY ename;
```

The window function `ROW_NUMBER OVER` will assign a unique number to each ename (in increasing order starting from 1).

|rn | ename|
|:-:|:-----:|
| 1 | ADAMS|
| 2 | ALLEN|
| 3 | BLAKE|
| 4 | CLARK|
| 5 | FORD|
| 6 | JAMES|
| 7 | JONES|
| 8 | KING|
| 9 | MARTIN|
|10 | MILLER|
|11 | SCOTT|
|12 | SMITH|
|13 | TURNER|
|14 | WARD|

The following example uses MOD to skip `even-numbered` rows:

```SQL
WITH ename_sort AS (
  SELECT ROW_NUMBER() OVER (ORDER BY ename) AS rn,
         ename
    FROM emp
)
SELECT *
  FROM ename_sort
 WHERE MOD(rn,2) = 1
 ORDER BY ename_sort;
```
