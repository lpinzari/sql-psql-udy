# Creating Buckets of Data, of a Fixed Size

You want to `organize data` into **evenly sized buckets**, with a `predetermined number of elements in each bucket`.

The `total number of buckets may be unknown`, but **you want to ensure that each bucket has five elements**.

## Problem

For example, you want to organize the employees in table `EMP` into **groups of five** `based on the value` of `EMPNO`, as shown in the following results:

|group | empno | ename|
|:----:|:-----:|:-----:|
|    1 |  7369 | SMITH|
|    1 |  7499 | ALLEN|
|    1 |  7521 | WARD|
|    1 |  7566 | JONES|
|    1 |  7654 | MARTIN|
|    2 |  7698 | BLAKE|
|    2 |  7782 | CLARK|
|    2 |  7788 | SCOTT|
|    2 |  7839 | KING|
|    2 |  7844 | TURNER|
|    3 |  7876 | ADAMS|
|    3 |  7900 | JAMES|
|    3 |  7902 | FORD|
|    3 |  7934 | MILLER|

## Solution

The solution to this problem is greatly simplified by functions for ranking rows. Once the rows are ranked, creating buckets of five is simply a matter of dividing and then taking the mathematical ceiling of the quotient.
Use the window function `ROW_NUMBER OVER` to rank each employee by `EMPNO`. Then divide by five to create the groups.


```SQL
SELECT CEIL(ROW_NUMBER()OVER(ORDER BY empno)/5.0) AS group,
       empno,
       ename
  FROM emp;
```

## Discussion

The window function `ROW_NUMBER OVER` assigns a rank or “**row number**” to each row sorted by `EMPNO`:

```SQL
SELECT ROW_NUMBER()OVER(ORDER BY empno) AS rn,
       empno,
       ename
  FROM emp;
```

|rn | empno | ename|
|:--:|:----:|:-----:|
| 1 |  7369 | SMITH|
| 2 |  7499 | ALLEN|
| 3 |  7521 | WARD|
| 4 |  7566 | JONES|
| 5 |  7654 | MARTIN|
| 6 |  7698 | BLAKE|
| 7 |  7782 | CLARK|
| 8 |  7788 | SCOTT|
| 9 |  7839 | KING|
|10 |  7844 | TURNER|
|11 |  7876 | ADAMS|
|12 |  7900 | JAMES|
|13 |  7902 | FORD|
|14 |  7934 | MILLER|

The next step is to apply the function `CEIL` (or CEILING) after dividing `ROW_ NUMBER OVER` by **five**. Dividing by five logically organizes the rows into **groups of five** (i.e., `five values less than or equal to 1`, `five values greater than 1 but less than or equal to 2`); the remaining group (composed of the last 4 rows since 14, the number of rows in table `EMP`, is not a multiple of 5) has a value greater than 2 but less than or equal to 3.

The `CEIL` function will return the **smallest whole number greater than the value passed to it**; `this will create whole number groups`.

```SQL
SELECT ROW_NUMBER()OVER(ORDER BY empno) AS rn,
       ROUND(ROW_NUMBER()OVER(ORDER BY empno)/5.0,2) AS division,
       CEIL(ROW_NUMBER()OVER(ORDER BY empno)/5.0) AS round_division,
       empno,
       ename
  FROM emp;
```

```console
rn | division | round_division | empno | ename
----+----------+----------------+-------+--------
 1 |     0.20 |              1 |  7369 | SMITH
 2 |     0.40 |              1 |  7499 | ALLEN
 3 |     0.60 |              1 |  7521 | WARD
 4 |     0.80 |              1 |  7566 | JONES
 5 |     1.00 |              1 |  7654 | MARTIN
 6 |     1.20 |              2 |  7698 | BLAKE
 7 |     1.40 |              2 |  7782 | CLARK
 8 |     1.60 |              2 |  7788 | SCOTT
 9 |     1.80 |              2 |  7839 | KING
10 |     2.00 |              2 |  7844 | TURNER
11 |     2.20 |              3 |  7876 | ADAMS
12 |     2.40 |              3 |  7900 | JAMES
13 |     2.60 |              3 |  7902 | FORD
14 |     2.80 |              3 |  7934 | MILLER
```

The results of the division and application of the CEIL are shown here.

```SQL
SELECT CEIL(ROW_NUMBER()OVER(ORDER BY empno)/5.0) AS group,
       empno,
       ename
  FROM emp;
```

|group | empno | ename|
|:----:|:-----:|:-----:|
|    1 |  7369 | SMITH|
|    1 |  7499 | ALLEN|
|    1 |  7521 | WARD|
|    1 |  7566 | JONES|
|    1 |  7654 | MARTIN|
|    2 |  7698 | BLAKE|
|    2 |  7782 | CLARK|
|    2 |  7788 | SCOTT|
|    2 |  7839 | KING|
|    2 |  7844 | TURNER|
|    3 |  7876 | ADAMS|
|    3 |  7900 | JAMES|
|    3 |  7902 | FORD|
|    3 |  7934 | MILLER|
