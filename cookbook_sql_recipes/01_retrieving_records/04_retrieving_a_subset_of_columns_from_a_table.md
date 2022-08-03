# Retrieving a Subset of Columns from a Table Problem

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


You have a table and want to see values for specific columns rather than for all the columns.

## Solution

Specify the columns you are interested in. For example, to see only `name`, `department number`, and `salary` for employees:

```SQL
SELECT ename,deptno,sal
  FROM emp;
```

**Output**

|ename  | deptno | sal|
|:-----:|:-------:|:-----:|
|SMITH  |     20 |  800|
|ALLEN  |     30 | 1600|
|WARD   |     30 | 1250|
|JONES  |     20 | 2975|
|MARTIN |     30 | 1250|
|BLAKE  |     30 | 2850|
|CLARK  |     10 | 2450|
|SCOTT  |     20 | 3000|
|KING   |     10 | 5000|
|TURNER |     30 | 1500|
|ADAMS  |     20 | 1100|
|JAMES  |     30 |  950|
|FORD   |     20 | 3000|
|MILLER |     10 | 1300|

**(14 rows)**

## Discussion

By specifying the columns in the SELECT clause, you ensure that no extraneous data is returned. This can be especially important when retrieving data across a network, as it avoids the waste of time inherent in retrieving data that you do not need.
