# Limiting the Number of Rows Returned Problem

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

You want to **limit the number of rows returned in your query**. You are not concerned with order; any n rows will do.

## Solution

Use the **built-in function provided by your database to control the number of rows returned**.

## MySQL and PostgreSQL

MySQL and PostgreSQL using [LIMIT](https://github.com/lpinzari/sql-psql-udy/blob/master/01_basic_sql/09_limit.md):

```SQL
SELECT *
  FROM emp
 LIMIT 5;
```

**Output**

|empno | ename  |   job    | mgr  |  hiredate  | sal  | comm  | deptno|
|:----:|:-------:|:-------:|:----:|:----------:|:----:|:-----:|:------:|
| 7369 | SMITH  | CLERK    | 7902 | 2015-12-17 |  800 | NULL; |     20|
| 7499 | ALLEN  | SALESMAN | 7698 | 2006-01-20 | 1600 |   300 |     30|
| 7521 | WARD   | SALESMAN | 7698 | 2006-02-22 | 1250 |   500 |     30|
| 7566 | JONES  | MANAGER  | 7839 | 2006-04-02 | 2975 | NULL; |     20|
| 7654 | MARTIN | SALESMAN | 7698 | 2006-09-28 | 1250 |  1400 |     30|

**(5 rows)**

## DB2 and PostgreSQL

Using [FETCH](https://github.com/lpinzari/sql-psql-udy/blob/master/01_basic_sql/09_m_fetch.md):

```SQL
SELECT *
  FROM emp FETCH FIRST 5 ROWS ONLY;
```

## Oracle

In Oracle, place a restriction on the number of rows returned by restricting `ROWNUM` in the `WHERE` clause:

```SQL
SELECT *
  FROM emp
 WHERE rownum <= 5;
```

## SQL Server

Use the `TOP` keyword to restrict the number of rows returned:

```SQL
SELECT top 5 *
  FROM emp;
```

## Discussion

Many vendors provide clauses such as `FETCH FIRST` and `LIMIT` that let you specify the number of rows to be returned from a query. Oracle is different, in that you must make use of a function called `ROWNUM` that returns a number for each row returned (an increasing value starting from one).

Here is what happens when you use `ROWNUM <= 5` to return the first five rows:

1. Oracle executes your query.
2. Oracle fetches the first row and calls it row number one.
3. Have we gotten past row number five yet? If no, then Oracle returns the row, because it meets the criteria of being numbered less than or equal to five. If yes, then Oracle does not return the row.
4. Oracle fetches the next row and advances the row number (to two, then to three, then to four, and so forth).
5. Go to step 3.

As this process shows, values from Oracle’s `ROWNUM` are assigned after each row is fetched. This is an important and key point. Many Oracle developers attempt to return only, say, the fifth row returned by a query by specifying `ROWNUM = 5`.
Using an equality condition in conjunction with `ROWNUM` is a bad idea. Here is what happens when you try to return, say, the fifth row using `ROWNUM = 5`:

1. Oracle executes your query.
2. Oracle fetches the first row and calls it row number one.
3. Have we gotten to row number five yet? If no, then Oracle discards the row, because it doesn’t meet the criteria. If yes, then Oracle returns the row. But the answer will never be yes!
4. Oracle fetches the next row and calls it row number one. This is because the first row to be returned from the query must be numbered as one.
5. Go to step 3.
Study this process closely, and you can see why the use of `ROWNUM = 5` to return the fifth row fails. You can’t have a fifth row if you don’t first return rows one through four!

You may notice that `ROWNUM = 1` does, in fact, work to return the first row, which may seem to contradict the explanation thus far. The reason `ROWNUM = 1` works to return the first row is that, to determine whether there are any rows in the table, Oracle has to attempt to fetch at least once. Read the preceding process carefully, substituting one for five, and you’ll understand why it’s OK to specify `ROWNUM = 1` as a condition (for returning one row).
