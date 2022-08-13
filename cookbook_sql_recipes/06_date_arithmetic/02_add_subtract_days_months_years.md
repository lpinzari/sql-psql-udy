# Adding and Subtracting Days, Months, and Years

You need to **add or subtract some number of** `days`, `months`, or `years` **from a date**.

## Problem

```console
cookbook=> \d emp
                        Table "public.emp"
  Column  |         Type          | Collation | Nullable | Default
----------+-----------------------+-----------+----------+---------
 empno    | integer               |           | not null |
 ename    | character varying(10) |           |          |
 job      | character varying(9)  |           |          |
 mgr      | integer               |           |          |
 +--------+
  hiredate| date <----------      |           |          |
 +--------+
 sal      | integer               |           |          |
 comm     | integer               |           |          |
 deptno   | integer               |           |          |
Indexes:
    "emp_pkey" PRIMARY KEY, btree (empno)
```

```SQL
SELECT ename,job, hiredate
  FROM emp
 ORDER BY ename;
```


| ename  |    job    |  hiredate|
|:------:|:---------:|:---------:|
| ADAMS  | CLERK     | 2008-01-12|
| ALLEN  | SALESMAN  | 2006-01-20|
| BLAKE  | MANAGER   | 2006-05-01|
| CLARK  | MANAGER   | 2006-06-09|
| FORD   | ANALYST   | 2006-12-03|
| JAMES  | CLERK     | 2006-12-03|
| JONES  | MANAGER   | 2006-04-02|
| KING   | PRESIDENT | 2006-11-17|
| MARTIN | SALESMAN  | 2006-09-28|
| MILLER | CLERK     | 2007-01-23|
| SCOTT  | ANALYST   | 2007-12-09|
| SMITH  | CLERK     | 2015-12-17|
| TURNER | SALESMAN  | 2006-09-08|
| WARD   | SALESMAN  | 2006-02-22|


For example, using the `HIREDATE` for employee `CLARK`, you want to return six different dates:

- **five days** `before` and `after` CLARK was hired,
- **five months** `before` and `after` CLARK was hired, and, finally,
- **five years** `before` and `after` CLARK was hired.

WE have chosen to use three date formats for the resulting output table,

- `YYYY-DD-MM`

CLARK was hired on `2006-06-09` so you want to return the following result set:

|hiredate  | minus_5d |plus_5d |  minus_5m | plus_5m  | minus_5y |  plus_5y|
|:--------:|:--------:|:------:|:---------:|:--------:|:--------:|:--------:|
2006-06-09 | 2006-06-04 | 2006-06-14 | 2006-01-09 | 2006-11-09 | 2001-06-09 | 2011-06-09|


- `DD-MM-YYYY`.

CLARK was hired on 09-JUN-2006, `09-06-2006` so you want to return the following result set:

|hiredate   |  minus_5d  |   plus_5d   |  minus_5m  |  plus_5m   |  minus_5y  |  plus_5y|
|:---------:|:----------:|:------------:|:---------:|:----------:|:----------:|:-----------:|
|09-06-2006 | 04-06-2006 | 14-06-20066 | 09-01-2006 | 09-11-2006 | 09-06-2001 | 09-06-2011|

- `MM-DD-YYYY`

CLARK was hired on June 9th of 2006, `06-09-2006` so you want to return the following result set:

|hiredate  |  minus_5d  |   plus_5d   |  minus_5m  |  plus_5m   |  minus_5y  |  plus_5y|
|:--------:|:----------:|:-----------:|:----------:|:----------:|:----------:|:-----------:|
|06-09-2006 | 06-04-2006 | 06-14-20066 | 01-09-2006 | 11-09-2006 | 06-09-2001 | 06-09-2011|

**Problem 2**

Finally, list all employees in `emp` table in chronological order based on `hiredate` and display the `hiredate` column in the following formats:

- `YYYY-DD-MM`

|hiredate  | ename|
|:--------:|:-------:|
|2006-01-20 | ALLEN|
|2006-02-22 | WARD|
|2006-04-02 | JONES|
|2006-05-01 | BLAKE|
|2006-06-09 | CLARK|
|2006-09-08 | TURNER|
|2006-09-28 | MARTIN|
|2006-11-17 | KING|
|2006-12-03 | FORD|
|2006-12-03 | JAMES|
|2007-01-23 | MILLER|
|2007-12-09 | SCOTT|
|2008-01-12 | ADAMS|
|2015-12-17 | SMITH|

- `DD-MM-YYYY`:

|hiredate_txt | ename|
|:------------:|:-------:|
|20-01-2006   | ALLEN|
|22-02-2006   | WARD|
|02-04-2006   | JONES|
|01-05-2006   | BLAKE|
|09-06-2006   | CLARK|
|08-09-2006   | TURNER|
|28-09-2006   | MARTIN|
|17-11-2006   | KING|
|03-12-2006   | FORD|
|03-12-2006   | JAMES|
|23-01-2007   | MILLER|
|09-12-2007   | SCOTT|
|12-01-2008   | ADAMS|
|17-12-2015   | SMITH|

- `MM-DD-YYYY`

|hiredate_txt | ename|
|:-----------:|:-------:|
|01-20-2006   | ALLEN|
|02-22-2006   | WARD|
|04-02-2006   | JONES|
|05-01-2006   | BLAKE|
|06-09-2006   | CLARK|
|09-08-2006   | TURNER|
|09-28-2006   | MARTIN|
|11-17-2006   | KING|
|12-03-2006   | FORD|
|12-03-2006   | JAMES|
|01-23-2007   | MILLER|
|12-09-2007   | SCOTT|
|01-12-2008   | ADAMS|
|12-17-2015   | SMITH|


## Solution


- **Problem 1**:

Use standard addition and subtraction with the [INTERVAL](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-interval/) keyword specifying the unit of time to add or subtract. Single quotes are required when specifying an **INTERVAL** value:


```SQL
SELECT hiredate,
       (hiredate - INTERVAL '5 day') :: DATE AS minus_5D,
       (hiredate + INTERVAL '5 day') :: DATE AS plus_5D,
       (hiredate - INTERVAL '5 month') :: DATE AS minus_5M,
       (hiredate + INTERVAL '5 month') :: DATE AS plus_5M,
       (hiredate - INTERVAL '5 year') :: DATE AS minus_5Y,
       (hiredate + INTERVAL '5 year') :: DATE AS plus_5Y
  FROM emp
 WHERE ename = 'CLARK';
```

```SQL
SELECT hiredate,
       hiredate - 5 AS minus_5D,
       hiredate + 5 AS plus_5D,
       (hiredate - INTERVAL '5 month') :: DATE AS minus_5M,
       (hiredate + INTERVAL '5 month') :: DATE AS plus_5M,
       (hiredate - INTERVAL '5 year') :: DATE AS minus_5Y,
       (hiredate + INTERVAL '5 year') :: DATE AS plus_5Y
  FROM emp
 WHERE ename = 'CLARK';
```

|hiredate  | minus_5d |plus_5d |  minus_5m | plus_5m  | minus_5y |  plus_5y|
|:--------:|:--------:|:------:|:---------:|:--------:|:--------:|:--------:|
2006-06-09 | 2006-06-04 | 2006-06-14 | 2006-01-09 | 2006-11-09 | 2001-06-09 | 2011-06-09|


```SQL
SELECT TO_CHAR(hiredate,'dd-mm-yyyy') AS hiredate,
       TO_CHAR((hiredate - INTERVAL '5 day') :: DATE,'dd-mm-yyyy') AS minus_5D,
       TO_CHAR((hiredate + INTERVAL '5 day') :: DATE,'dd-mm-yyyyy') AS plus_5D,
       TO_CHAR((hiredate - INTERVAL '5 month') :: DATE,'dd-mm-yyyy') AS minus_5M,
       TO_CHAR((hiredate + INTERVAL '5 month') :: DATE,'dd-mm-yyyy') AS plus_5M,
       TO_CHAR((hiredate - INTERVAL '5 year') :: DATE,'dd-mm-yyyy') AS minus_5Y,
       TO_CHAR((hiredate + INTERVAL '5 year') :: DATE,'dd-mm-yyyy') AS plus_5Y
  FROM emp
 WHERE ename = 'CLARK';
```

|hiredate   |  minus_5d  |   plus_5d   |  minus_5m  |  plus_5m   |  minus_5y  |  plus_5y|
|:---------:|:----------:|:------------:|:---------:|:----------:|:----------:|:-----------:|
|09-06-2006 | 04-06-2006 | 14-06-20066 | 09-01-2006 | 09-11-2006 | 09-06-2001 | 09-06-2011|

```SQL
SELECT TO_CHAR(hiredate,'mm-dd-yyyy') AS hiredate,
       TO_CHAR((hiredate - INTERVAL '5 day') :: DATE,'mm-dd-yyyy') AS minus_5D,
       TO_CHAR((hiredate + INTERVAL '5 day') :: DATE,'mm-dd-yyyyy') AS plus_5D,
       TO_CHAR((hiredate - INTERVAL '5 month') :: DATE,'mm-dd-yyyy') AS minus_5M,
       TO_CHAR((hiredate + INTERVAL '5 month') :: DATE,'mm-dd-yyyy') AS plus_5M,
       TO_CHAR((hiredate - INTERVAL '5 year') :: DATE,'mm-dd-yyyy') AS minus_5Y,
       TO_CHAR((hiredate + INTERVAL '5 year') :: DATE,'mm-dd-yyyy') AS plus_5Y
  FROM emp
 WHERE ename = 'CLARK';
```

|hiredate  |  minus_5d  |   plus_5d   |  minus_5m  |  plus_5m   |  minus_5y  |  plus_5y|
|:--------:|:----------:|:-----------:|:----------:|:----------:|:----------:|:-----------:|
|06-09-2006 | 06-04-2006 | 06-14-20066 | 01-09-2006 | 11-09-2006 | 06-09-2001 | 06-09-2011|

- **Problem 2**:

```SQL
SELECT hiredate, ename
  FROM emp
 ORDER BY hiredate;
```

```SQL
SELECT TO_CHAR(hiredate,'yyyy-mm-dd') hiredate_txt, ename
  FROM emp
 ORDER BY hiredate_txt;
```

|hiredate  | ename|
|:--------:|:-------:|
|2006-01-20 | ALLEN|
|2006-02-22 | WARD|
|2006-04-02 | JONES|
|2006-05-01 | BLAKE|
|2006-06-09 | CLARK|
|2006-09-08 | TURNER|
|2006-09-28 | MARTIN|
|2006-11-17 | KING|
|2006-12-03 | FORD|
|2006-12-03 | JAMES|
|2007-01-23 | MILLER|
|2007-12-09 | SCOTT|
|2008-01-12 | ADAMS|
|2015-12-17 | SMITH|

```SQL
SELECT TO_CHAR(hiredate,'dd-mm-yyyy') hiredate_txt, ename
  FROM emp
 ORDER BY hiredate;
```

|hiredate_txt | ename|
|:------------:|:-------:|
|20-01-2006   | ALLEN|
|22-02-2006   | WARD|
|02-04-2006   | JONES|
|01-05-2006   | BLAKE|
|09-06-2006   | CLARK|
|08-09-2006   | TURNER|
|28-09-2006   | MARTIN|
|17-11-2006   | KING|
|03-12-2006   | FORD|
|03-12-2006   | JAMES|
|23-01-2007   | MILLER|
|09-12-2007   | SCOTT|
|12-01-2008   | ADAMS|
|17-12-2015   | SMITH|

```SQL
SELECT TO_CHAR(hiredate,'mm-dd-yyyy') hiredate_txt, ename
  FROM emp
 ORDER BY hiredate;
```

|hiredate_txt | ename|
|:-----------:|:-------:|
|01-20-2006   | ALLEN|
|02-22-2006   | WARD|
|04-02-2006   | JONES|
|05-01-2006   | BLAKE|
|06-09-2006   | CLARK|
|09-08-2006   | TURNER|
|09-28-2006   | MARTIN|
|11-17-2006   | KING|
|12-03-2006   | FORD|
|12-03-2006   | JAMES|
|01-23-2007   | MILLER|
|12-09-2007   | SCOTT|
|01-12-2008   | ADAMS|
|12-17-2015   | SMITH|

## Discussion


```SQL
SELECT hiredate,
       pg_typeof(hiredate)
  FROM emp
 WHERE ename = 'CLARK';
```

|hiredate  | pg_typeof|
|:---------:|---------:|
|2006-06-09 | date|


As you can see the `Date` type format in PostgreSQL is `YYYY-MM-DD`.

```SQL
SELECT hiredate - 5  AS minus_5D,
       pg_typeof(hiredate - 5)
  FROM emp
 WHERE ename = 'CLARK';
```

|minus_5d  | pg_typeof|
|:---------:|:-------:|
|2006-06-04 | date|

The solution takes advantage of the fact that integer values represent days when performing date arithmetic. However, that’s true only of arithmetic with `DATE` types. PostgreSQL also has `TIMESTAMP` types. **For those, you should use the** `INTERVAL` **solution below**:

```SQL
SELECT hiredate - INTERVAL '5 days' AS minus_5D,
       pg_typeof(hiredate - INTERVAL '5 day')
  FROM emp
 WHERE ename = 'CLARK';
```

|minus_5d     |          pg_typeof|
|:------------------:|:--------------------------:|
|2006-06-04 00:00:00 | timestamp without time zone|

Beware too, of passing `Date` data type to functions such as `INTERVAL` returns `TIMESTAMP` data type. In PostgreSQL, if you subtract one datetime value (TIMESTAMP, DATE or TIME data type) from another, you will get an `INTERVAL` value in the form ”`ddd days hh:mi:ss`”.

To return in a `DATE` format use the following:


```SQL
SELECT (hiredate - INTERVAL '5 day') :: DATE AS minus_5D,
       pg_typeof((hiredate - INTERVAL '5 day') :: DATE)
  FROM emp
 WHERE ename = 'CLARK';
```

|minus_5D    | pg_typeof|
|:---------:|:----------:|
|2006-06-04 | date|

```SQL
SELECT TO_CHAR((hiredate - INTERVAL '5 day') :: DATE,'dd-mm-yyyy') AS minus_5D,
       pg_typeof(TO_CHAR((hiredate - INTERVAL '5 day') :: DATE,'dd-mm-yyyy'))
  FROM emp
 WHERE ename = 'CLARK';
```

Finally, we convert to a string format for visualization purpose. Keep in mind, however, that any date operation oriented to further calculations or storage must be executed mainly on `Date` or `timestamp` formats.

|minus_5d  | pg_typeof|
|:--------:|:---------:|
|04-06-2006 | text|

The procedure is extended to `month` and `year`.


### Problem 2

```SQL
SELECT hiredate, ename
  FROM emp
 ORDER BY hiredate;
```

```SQL
SELECT TO_CHAR(hiredate,'yyyy-mm-dd') hiredate_txt, ename
  FROM emp
 ORDER BY hiredate_txt;
```

|hiredate  | ename|
|:--------:|:-------:|
|2006-01-20 | ALLEN|
|2006-02-22 | WARD|
|2006-04-02 | JONES|
|2006-05-01 | BLAKE|
|2006-06-09 | CLARK|
|2006-09-08 | TURNER|
|2006-09-28 | MARTIN|
|2006-11-17 | KING|
|2006-12-03 | FORD|
|2006-12-03 | JAMES|
|2007-01-23 | MILLER|
|2007-12-09 | SCOTT|
|2008-01-12 | ADAMS|
|2015-12-17 | SMITH|

In the `YYYY-MM-DD` data ordering is the same whether you think of them as dates or as bits of text (string).

```SQL
SELECT TO_CHAR(hiredate,'dd-mm-yyyy') hiredate_txt, ename
  FROM emp
 ORDER BY hiredate_txt;
```

|hiredate_txt | ename|
|:-----------:|:----:|
|01-05-2006   | BLAKE|
|02-04-2006   | JONES|
|03-12-2006   | JAMES|
|03-12-2006   | FORD|
|08-09-2006   | TURNER|
|09-06-2006   | CLARK|
|09-12-2007   | SCOTT|
|12-01-2008   | ADAMS|
|17-11-2006   | KING|
|17-12-2015   | SMITH|
|20-01-2006   | ALLEN|
|22-02-2006   | WARD|
|23-01-2007   | MILLER|
|28-09-2006   | MARTIN|

In the `DD-MM-YYYY` format data ordering is **not the same as dates**, that's why we need to sort according to the hiredate column.

```SQL
SELECT TO_CHAR(hiredate,'dd-mm-yyyy') hiredate_txt, ename
  FROM emp
 ORDER BY hiredate;
```
