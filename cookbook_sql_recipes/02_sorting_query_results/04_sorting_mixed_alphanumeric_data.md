# Sorting Mixed Alphanumeric Data Problem

```console
cookbook=> \d emp
                        Table "public.emp"
  Column  |         Type          | Collation | Nullable | Default
----------+-----------------------+-----------+----------+---------
 empno    | integer               |           | not null |
 ename    | character varying(10) |           |          |
 job      | character varying(9)  |           |          |
 mgr      | integer               |           |          |
 hiredate | date                  |           |          |
 sal      | integer               |           |          |
 comm     | integer               |           |          |
 deptno   | integer               |           |          |
Indexes:
    "emp_pkey" PRIMARY KEY, btree (empno)
```


You have mixed alphanumeric data and want to sort by either the `numeric` or `character` **portion of the data**. Consider this [view](https://github.com/lpinzari/sql-psql-udy/tree/master/09_view), created from the `EMP` table:

```SQL
CREATE VIEW v AS
    SELECT ename ||' '|| deptno AS data
      FROM emp;
```

Let's output the view table:

```SQL
SELECT * FROM v;
```

|data|
|:---------:|
|SMITH 20|
|ALLEN 30|
|WARD 30|
|JONES 20|
|MARTIN 30|
|BLAKE 30|
|CLARK 10|
|SCOTT 20|
|KING 10|
|TURNER 30|
|ADAMS 20|
|JAMES 30|
|FORD 20|
|MILLER 10|

You want to sort the results by `DEPTNO` or `ENAME`.

Sorting by `DEPTNO` produces the following result set:

|data|
|:---------:|
|MILLER 10|
|CLARK 10|
|KING 10|
|SCOTT 20|
|JONES 20|
|SMITH 20|
|ADAMS 20|
|FORD 20|
|WARD 30|
|TURNER 30|
|ALLEN 30|
|BLAKE 30|
|MARTIN 30|
|JAMES 30|

Sorting by `ENAME` produces the following result set:

|data|
|:---------:|
|ADAMS 20|
|ALLEN 30|
|BLAKE 30|
|CLARK 10|
|FORD 20|
|JAMES 30|
|JONES 20|
|KING 10|
|MARTIN 30|
|MILLER 10|
|SCOTT 20|
|SMITH 20|
|TURNER 30|
|WARD 30|

## Solution


### Oracle, SQL Server, and PostgreSQL

Use the functions `REPLACE` and `TRANSLATE` to modify the string for sorting:


```SQL
/* ORDER BY DEPTNO */
SELECT data
  FROM v
 ORDER BY REPLACE(data,
          REPLACE(TRANSLATE(data,'0123456789','##########'),'#',''),'');
```

```SQL
SELECT TRANSLATE('SMITH 20','0123456789','##########');
```

|translate|
|:---------:|
|SMITH ##|

The [TRANSLATE](https://www.postgresqltutorial.com/postgresql-string-functions/postgresql-translate/) function substitutes all the characters '0123456789' with the symbol `#`.

```SQL
SELECT REPLACE(TRANSLATE('SMITH 20','0123456789','##########'),'#','');
```

|replace|
|:-------:|
|SMITH|

The function [REPLACE](https://github.com/lpinzari/sql-psql-udy/blob/master/06_string_functions/15_replace.md).

```SQL
SELECT REPLACE('SMITH 20',
         REPLACE(TRANSLATE('SMITH 20','0123456789','##########'),'#',''),'');
```

|replace|
|:-------:|
|20|


```SQL
/* ORDER BY ENAME */
SELECT data
  FROM v
 ORDER BY replace(
          TRANSLATE(data,'0123456789','##########'),'#','');
```

## Discussion

The `TRANSLATE` and `REPLACE` functions remove either the **numbers** or **characters** from each row, allowing you to easily sort by one or the other. The values passed to `ORDER BY` are shown in the following query results:

```SQL
SELECT data,
       REPLACE(data,
           REPLACE(
         TRANSLATE(data,'0123456789','##########'),'#',''),'') nums,
           REPLACE(
         TRANSLATE(data,'0123456789','##########'),'#','') chars
  FROM v;
```

|data    | nums |  chars      |
|:--------:|:----:|:--------:|
|SMITH 20  | 20   | SMITH|
|ALLEN 30  | 30   | ALLEN|
|WARD 30   | 30   | WARD|
|JONES 20  | 20   | JONES|
|MARTIN 30 | 30   | MARTIN|
|BLAKE 30  | 30   | BLAKE|
|CLARK 10  | 10   | CLARK|
|SCOTT 20  | 20   | SCOTT|
|KING 10   | 10   | KING|
|TURNER 30 | 30   | TURNER|
|ADAMS 20  | 20   | ADAMS|
|JAMES 30  | 30   | JAMES|
|FORD 20   | 20   | FORD|
|MILLER 10 | 10   | MILLER|
