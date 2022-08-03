# Retrieving a Subset of Rows from a Table Problem

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

You have a table and want to **see only rows that satisfy a specific condition**.

## Solution

Use the `WHERE` clause to specify which rows to keep. For example, to view all employees assigned to **department number** `10`:

```SQL
SELECT *
  FROM emp
 WHERE deptno = 10;
```

**Output**

|empno | ename  |    job    |  mgr  |  hiredate  | sal  | comm  | deptno|
|:-----:|:-----:|:---------:|:------:|:---------:|:----:|:-----:|:-----:|
| 7782 | CLARK  | MANAGER   |  7839 | 2006-06-09 | 2450 | NULL; |     10|
| 7839 | KING   | PRESIDENT | NULL; | 2006-11-17 | 5000 | NULL; |     10|
| 7934 | MILLER | CLERK     |  7782 | 2007-01-23 | 1300 | NULL; |     10|

**(3 rows)**

## Discussion

The `WHERE` clause allows you to retrieve only rows you are interested in. If the expression in the `WHERE` clause is true for any row, then that row is returned.
Most vendors support common operators such as `=`, `<`, `>`, `<=`, `>=`, `!`, and `<>`. Additionally, you may want rows that satisfy multiple conditions; this can be done by specifying `AND`, `OR`, and `parentheses`, as shown in the next recipe.
