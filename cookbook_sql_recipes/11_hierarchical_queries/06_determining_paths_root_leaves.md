# Determining paths Tree from Root to leaves

You want to determine all the existing paths starting from the root of the tree and ending to the leaves.


## Problem

For this example,

- A `leaf` (`L`) node is an **employee who is not a manager**.

- A `root` (`R`) node is an **employee without a manager**.

```console
LEVEL                          (7839)
0                           (R) KING
                                 |
                 +---------------+-------------------+
                 |               |                   |
              (7566)           (7782)              (7698)
1          (B) JONES           CLARK (B)           BLAKE (B)
                 |               |                   |
           +-----+-----+         |         +------+------+-------+------+
           |           |         |         |      |      |       |      |
        (7788)      (7902)     (7934)     (7499) (7521) (7654)  (7844)  (7900)
2     (B) SCOTT   (B) FORD      MILLER     ALLEN  WARD  MARTIN  TURNER  JAMES
           |           |        (L)        (L)   (L)    (L)     (L)    (L)
        (7876)      (7369)
3        ADAMS       SMITH
          (L)         (L)
```


The picture above shows that the `emp` table has `8` paths:

|emp_tree_paths|
|:----------------------------:|
|KING - BLAKE - ALLEN|
|KING - BLAKE - JAMES|
|KING - BLAKE - MARTIN|
|KING - BLAKE - TURNER|
|KING - BLAKE - WARD|
|KING - CLARK - MILLER|
|KING - JONES - FORD - SMITH|
|KING - JONES - SCOTT - ADAMS|

The resulting table must be sorted in ascending order of `path` length and alphabetical order of `emp_tree_paths`. For instance, the first six records have a path length of 2, (the number of nodes from the root to the end are 2). On the other hand, the last two have a path's length equal to 3.


## Solution

```SQL
WITH RECURSIVE x (ename, empno) AS (
  SELECT ename::VARCHAR(100),
         empno,
         0 AS is_leaf,
         0 AS level
    FROM emp
   WHERE mgr IS NULL
  UNION ALL
  SELECT (x.ename || ' - ' || e.ename)::VARCHAR(100),
         e.empno,
         CASE WHEN NOT EXISTS (SELECT NULL
                                 FROM emp f
                                WHERE f.mgr = e.empno)
              THEN 1 ELSE 0
         END AS is_leaf,
         x.level + 1 AS level
    FROM emp e, x
   WHERE e.mgr = x.empno
)
SELECT ename AS emp_tree_paths
  FROM x
 WHERE is_leaf = 1
 ORDER BY level, emp_tree_paths;
```


## Discussion

```SQL
WITH RECURSIVE x (ename, empno) AS (
  SELECT ename::VARCHAR(100),
         empno,
         0 AS is_leaf
    FROM emp
   WHERE mgr IS NULL
  UNION ALL
  SELECT (x.ename || ' - ' || e.ename)::VARCHAR(100),
         e.empno,
         CASE WHEN NOT EXISTS (SELECT NULL
                                 FROM emp f
                                WHERE f.mgr = e.empno)
              THEN 1 ELSE 0
         END AS is_leaf
    FROM emp e, x
   WHERE e.mgr = x.empno
)
SELECT ename emp_tree, is_leaf
  FROM x;
```

|emp_tree           | is_leaf|
|:---------------------------:|:------:|
|KING                         |       0|
|KING - JONES                 |       0|
|KING - BLAKE                 |       0|
|KING - CLARK                 |       0|
|KING - BLAKE - ALLEN         |       1|
|KING - BLAKE - WARD          |       1|
|KING - BLAKE - MARTIN        |       1|
|KING - JONES - SCOTT         |       0|
|KING - BLAKE - TURNER        |       1|
|KING - BLAKE - JAMES         |       1|
|KING - JONES - FORD          |       0|
|KING - CLARK - MILLER        |       1|
|KING - JONES - FORD - SMITH  |       1|
|KING - JONES - SCOTT - ADAMS |       1|

```SQL
WITH RECURSIVE x (ename, empno) AS (
  SELECT ename::VARCHAR(100),
         empno,
         0 AS is_leaf
    FROM emp
   WHERE mgr IS NULL
  UNION ALL
  SELECT (x.ename || ' - ' || e.ename)::VARCHAR(100),
         e.empno,
         CASE WHEN NOT EXISTS (SELECT NULL
                                 FROM emp f
                                WHERE f.mgr = e.empno)
              THEN 1 ELSE 0
         END AS is_leaf
    FROM emp e, x
   WHERE e.mgr = x.empno
)
SELECT ename emp_tree_paths
  FROM x
 WHERE is_leaf = 1;
```
