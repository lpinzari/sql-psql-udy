# Creating a Hierarchical View of a Table

You want to return a result set that describes the hierarchy of an entire table. In the case of the `EMP` table, employee `KING` has no manager, so `KING` is the root node. You want to display, starting from `KING`, all employees under KING and all employees (if any) under `KING’s` subordinates. Ultimately, you want to return the following result set:

|emp_tree|
|:----------------------------:|
|KING|
|KING - JONES|
|KING - BLAKE|
|KING - CLARK|
|KING - BLAKE - ALLEN|
|KING - BLAKE - WARD|
|KING - BLAKE - MARTIN|
|KING - JONES - SCOTT|
|KING - BLAKE - TURNER|
|KING - BLAKE - JAMES|
|KING - JONES - FORD|
|KING - CLARK - MILLER|
|KING - JONES - FORD - SMITH|
|KING - JONES - SCOTT - ADAMS|


```console
LEVEL
0                            KING
                              |
              +---------------+-------------------+
              |               |                   |
1           JONES           CLARK               BLAKE
              |               |                   |
        +-----+-----+         |         +------+------+-------+------+
        |           |         |         |      |      |       |      |
2     SCOTT       FORD      MILLER     ALLEN  WARD  MARTIN  TURNER  JAMES
        |           |
3     ADAMS       SMITH
```



## Solution

```SQL
WITH RECURSIVE x (ename, empno) AS (
  SELECT ename::VARCHAR(100),
         empno
    FROM emp
   WHERE mgr IS NULL
  UNION ALL
  SELECT (x.ename || ' - ' || e.ename)::VARCHAR(100),
         e.empno
    FROM emp e, x
   WHERE e.mgr = x.empno
)
SELECT ename emp_tree
  FROM x;
```


## Discussion

The first step is to identify the root row (employee `KING`) in the upper part of the `UNION ALL` in the recursive view `X`. The next step is to find `KING’s` subordinates, and their subordinates if there are any, by joining recursive view `X` to table `EMP`. Recursion will continue until you’ve returned all employees. Without the formatting you see in the final result set, the result set returned by the recursive view X is shown here:

```SQL
WITH RECURSIVE x (ename, empno) AS (
  SELECT ename::VARCHAR(100),
         empno
    FROM emp
   WHERE mgr IS NULL
  UNION ALL
  SELECT e.ename::VARCHAR(100),
         e.empno
    FROM emp e, x
   WHERE e.mgr = x.empno
)
SELECT ename emp_tree
  FROM x;
```

|emp_tree|
|:------:|
|KING|
|JONES|
|BLAKE|
|CLARK|
|ALLEN|
|WARD|
|MARTIN|
|SCOTT|
|TURNER|
|JAMES|
|FORD|
|MILLER|
|SMITH|
|ADAMS|

All the rows in the hierarchy are returned (which can be useful), but without the formatting you cannot tell who the managers are. By concatenating each employee to her manager, you return more meaningful output. Produce the desired output simply by using the following:

```SQL
WITH RECURSIVE x (ename, empno) AS (
  SELECT ename::VARCHAR(100),
         empno
    FROM emp
   WHERE mgr IS NULL
  UNION ALL
  SELECT (x.ename || ' - ' || e.ename)::VARCHAR(100),
         e.empno
    FROM emp e, x
   WHERE e.mgr = x.empno
)
SELECT ename emp_tree
  FROM x;
```

In the `SQL` code, the alias table `e` refers to the child record that contains the attribute filed `mgr`, (manager). On the other hand, the alias `x` refers to the parent record or manager. In the `WHERE` clause the `empno` indicates the id of the parent table that must match the `mgr` field's value in the child's record.

|emp_tree|
|:----------------------------:|
|KING|
|KING - JONES|
|KING - BLAKE|
|KING - CLARK|
|KING - BLAKE - ALLEN|
|KING - BLAKE - WARD|
|KING - BLAKE - MARTIN|
|KING - JONES - SCOTT|
|KING - BLAKE - TURNER|
|KING - BLAKE - JAMES|
|KING - JONES - FORD|
|KING - CLARK - MILLER|
|KING - JONES - FORD - SMITH|
|KING - JONES - SCOTT - ADAMS|
