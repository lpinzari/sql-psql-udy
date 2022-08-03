# Dealing with Nulls When Sorting Problem

You want to sort results from `EMP` by `COMM`, but the field is **nullable**. You need a way to `specify whether nulls sort last`:

|ename  | sal  | comm   |
|:-----:|:-----:|:------:|
|TURNER | 1500 |     0|
|ALLEN  | 1600 |   300|
|WARD   | 1250 |   500|
|MARTIN | 1250 |  1400|
|SCOTT  | 3000 | NULL;|
|KING   | 5000 | NULL;|
|ADAMS  | 1100 | NULL;|
|JAMES  |  950 | NULL;|
|FORD   | 3000 | NULL;|
|SMITH  |  800 | NULL;|
|MILLER | 1300 | NULL;|
|JONES  | 2975 | NULL;|
|BLAKE  | 2850 | NULL;|
|CLARK  | 2450 | NULL;|


or whether `they sort first`:

|ename  | sal  | comm   |
|:-----:|:----:|:------:|
|MILLER | 1300 | NULL;|
|ADAMS  | 1100 | NULL;|
|JAMES  |  950 | NULL;|
|FORD   | 3000 | NULL;|
|SMITH  |  800 | NULL;|
|JONES  | 2975 | NULL;|
|BLAKE  | 2850 | NULL;|
|CLARK  | 2450 | NULL;|
|SCOTT  | 3000 | NULL;|
|KING   | 5000 | NULL;|
|MARTIN | 1250 |  1400|
|WARD   | 1250 |   500|
|ALLEN  | 1600 |   300|
|TURNER | 1500 |     0|


## Solution

Depending on how you want the data to look and how your particular RDBMS sorts NULL values, you can sort the nullable column in `ascending` or `descending` order:

```SQL
/* NULL LAST */
SELECT ename,sal,comm
  FROM emp
 ORDER BY 3 ;
```

```SQL
/* NULL FIRST */
SELECT ename,sal,comm
  FROM emp
 ORDER BY 3 DESC;
```

This solution puts you in a position such that if the nullable column contains non- NULL values, **they will be sorted** in `ascending` or `descending` order as well, according to what you ask for; this may or may not be what you have in mind.

If instead you would like to sort `NULL` values differently than `non-NULL` values, for example, you want to sort `non-NULL` values in `ascending` or `descending` order and all `NULL values last`, you can use a CASE expression to conditionally sort the column.

## DB2, MySQL, PostgreSQL, and SQL Server

Use a **CASE** expression to “flag” when a value is `NULL`.

The idea is to have a flag with two values:
- one to represent NULLs,
- the other to represent non-NULLs.

Once you have that, simply add this flag column to the `ORDER BY` clause. You’ll easily be able to control whether `NULL` values are sorted first or last without interfering with `non- NULL` values:

```SQL
/* NON-NULL COMM SORTED ASCENDING, ALL NULLS LAST */
SELECT ename,sal,comm
  FROM (SELECT ename,sal,comm,
               CASE WHEN comm IS NULL THEN 0 ELSE 1 END AS is_null
          FROM emp) x
 ORDER BY is_null DESC,comm;
```

```SQL
/* NON-NULL COMM SORTED DESCENDING, ALL NULLS FIRST */
SELECT ename,sal,comm
  FROM (SELECT ename,sal,comm,
               CASE WHEN comm IS NULL THEN 0 ELSE 1 END AS is_null
          FROM emp) x
 ORDER BY is_null DESC,comm DESC;
```

## Discussion

Unless your RDBMS provides you with a way to easily sort NULL values first or last without modifying non-NULL values in the same column, you’ll need an auxiliary column.

The purpose of this extra column (in the query only, not in the table) is to allow you to identify NULL values and sort them altogether, first or last. The following query returns the result set for inline view X:

```SQL
SELECT ename,sal,comm,
       CASE WHEN comm IS NULL THEN 0 ELSE 1 END AS is_null
  FROM emp;
```

|ename  | sal  | comm  | is_null  |
|:------:|:---:|:-----:|:--------:|
|SMITH  |  800 | NULL; |       0|
|ALLEN  | 1600 |   300 |       1|
|WARD   | 1250 |   500 |       1|
|JONES  | 2975 | NULL; |       0|
|MARTIN | 1250 |  1400 |       1|
|BLAKE  | 2850 | NULL; |       0|
|CLARK  | 2450 | NULL; |       0|
|SCOTT  | 3000 | NULL; |       0|
|KING   | 5000 | NULL; |       0|
|TURNER | 1500 |     0 |       1|
|ADAMS  | 1100 | NULL; |       0|
|JAMES  |  950 | NULL; |       0|
|FORD   | 3000 | NULL; |       0|
|MILLER | 1300 | NULL; |       0|
