# Using Conditional Logic in a SELECT Statement Problem

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


You want to perform `IF-ELSE` operations on values in your `SELECT` statement.

For example, you would like to produce a result set such that

- **if** an employee is `paid $2,000 or less`, a message of “**UNDERPAID**” is returned;
- **if** an employee is `paid $4,000 or more`, a message of “**OVERPAID**” is returned; and
- **if** they make `somewhere in between`, then “**OK**” is returned.

The result set should look like this:

|ename  | sal  |  status|
|:------:|:----:|:--------:|
|SMITH  |  800 | UNDERPAID|
|ALLEN  | 1600 | UNDERPAID|
|WARD   | 1250 | UNDERPAID|
|JONES  | 2975 | OK|
|MARTIN | 1250 | UNDERPAID|
|BLAKE  | 2850 | OK|
|CLARK  | 2450 | OK|
|SCOTT  | 3000 | OK|
|KING   | 5000 | OVERPAID|
|TURNER | 1500 | UNDERPAID|
|ADAMS  | 1100 | UNDERPAID|
|JAMES  |  950 | UNDERPAID|
|FORD   | 3000 | OK|
|MILLER | 1300 | UNDERPAID|

**(14 rows)**

## Solution

Use the [CASE](https://github.com/lpinzari/sql-psql-udy/blob/master/04_sql_aggregations/16_case_grouping.md) expression to perform conditional logic directly in your `SELECT` statement:

```SQL
SELECT ename,sal,
     CASE WHEN sal <= 2000 THEN 'UNDERPAID'
          WHEN sal >= 4000 THEN 'OVERPAID'
          ELSE 'OK'
     END AS status
  FROM emp;
```

## Discussion

The **CASE** expression allows you to perform condition logic on values returned by a query. You can provide an `alias` for a **CASE expression to return a more readable result set**.

In the solution, you’ll see the alias `STATUS` given to the result of the `CASE` expression. The `ELSE` clause is optional. Omit the `ELSE`, and the `CASE` expression will return `NULL` for any row that does not satisfy the test condition.
