# Determining Which Rows Are Leaf, Branch, or Root Nodes


You want to determine what type of node a given row is: a `leaf`, `branch`, or `root`.


|empno | ename|
|:-----:|:----:|
| 7876 | ADAMS|
| 7499 | ALLEN|
| 7698 | BLAKE|
| 7782 | CLARK|
| 7902 | FORD|
| 7900 | JAMES|
| 7566 | JONES|
| 7839 | KING|
| 7654 | MARTIN|
| 7934 | MILLER|
| 7788 | SCOTT|
| 7369 | SMITH|
| 7844 | TURNER|
| 7521 | WARD|


## Problem

For this example,

- A `leaf` (`L`) node is an **employee who is not a manager**.

- A `branch` (`B`) node is an **employee who is both a manager and also has a manager**.

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

You want to return **1** (`TRUE`) or **0** (`FALSE`) to reflect the `status of each row` in the hierarchy.


You want to return the following result set:

|ename  | is_leaf | is_branch | is_root|
|:-----:|:-------:|:---------:|:------:|
|SMITH  |       1 |         0 |       0|
|ALLEN  |       1 |         0 |       0|
|WARD   |       1 |         0 |       0|
|MARTIN |       1 |         0 |       0|
|TURNER |       1 |         0 |       0|
|ADAMS  |       1 |         0 |       0|
|JAMES  |       1 |         0 |       0|
|MILLER |       1 |         0 |       0|
|KING   |       0 |         0 |       1|
|JONES  |       0 |         1 |       0|
|FORD   |       0 |         1 |       0|
|BLAKE  |       0 |         1 |       0|
|CLARK  |       0 |         1 |       0|
|SCOTT  |       0 |         1 |       0|

## Solution

It is important to realize that the `EMP` table is modeled in a tree hierarchy, not a recursive hierarchy, and the value for `MGR` for root nodes is `NULL`. If EMP were modeled to use a recursive hierarchy, root nodes would be `self-referencing` (i.e., the value for `MGR` for employee `KING` would be `KING’s EMPNO`). We find self- referencing to be counterintuitive and thus are using `NULL` values for root nodes’ `MGR`.

```SQL
SELECT e.ename,
       (SELECT SIGN(COUNT(*))
          FROM emp
         WHERE 0 = (SELECT COUNT(*)
                      FROM emp f
                     WHERE f.mgr = e.empno)
       ) AS is_leaf,
       (SELECT SIGN(COUNT(*))
          FROM emp d
         WHERE d.mgr = e.empno
           AND e.mgr IS NOT NULL
       ) AS is_branch,
       (SELECT SIGN(COUNT(*))
          FROM emp d
         WHERE d.mgr = e.empno
           AND e.mgr IS NULL) AS is_root
  FROM emp e
 ORDER BY 2 DESC;
```

- **Solution 2**:

```SQL
SELECT e.ename,
       COALESCE((SELECT 1 AS d
                  WHERE NOT EXISTS (SELECT NULL
                                      FROM emp f
                                     WHERE f.mgr = e.empno)),0)
       AS is_leaf,
       COALESCE((SELECT 1 AS d
                  WHERE EXISTS (SELECT NULL
                                  FROM emp f
                                 WHERE f.mgr = e.empno)
                                   AND e.mgr IS NOT NULL),0)
       AS is_branch,
       COALESCE((SELECT 1 AS d
                  WHERE EXISTS (SELECT NULL
                                  FROM emp f
                                 WHERE f.mgr = e.empno)
                                   AND e.mgr IS NULL),0)
       AS is_root
  FROM emp e
 ORDER BY 2 DESC;
```

- **Solution 3**:

```SQL
SELECT ename,
       CASE WHEN NOT EXISTS (SELECT NULL
                               FROM emp f
                              WHERE f.mgr = e.empno)
            THEN 1 ELSE 0
       END AS is_leaf,
       CASE WHEN EXISTS (SELECT NULL
                           FROM emp f
                          WHERE f.mgr = e.empno) AND e.mgr IS NOT NULL  
            THEN 1 ELSE 0
       END AS is_branch,
       CASE WHEN mgr IS NULL
            THEN 1 ELSE 0
       END AS is_root
  FROM emp e
 ORDER BY 2 DESC;
```

## Discussion

This solution simply applies the rules defined in the “Problem” section to determine `leaves`, `branches`, and `roots`.

- `KING` (7839):

```SQL
SELECT COUNT(*) AS king_child_cnt
  FROM emp e, emp f
 WHERE (e.empno = f.mgr AND e.empno = 7839); -- KING is manager of 3 employee
```
```console
king_child_cnt
----------------
             3
```

- `ADAMS` (7876):

```SQL
SELECT COUNT(*) AS adams_child_cnt
  FROM emp e, emp f
 WHERE (e.empno = f.mgr AND e.empno = 7876); -- ADAMS is not a manager
```

```console
adams_child_cnt
-----------------
              0
```

The first step is to determine whether `an employee` **is a leaf node**. If the employee is not a manager (`no one works under them`), then she is a `leaf node`.

```SQL
SELECT e.ename,
       (SELECT COUNT(*)
          FROM emp f
         WHERE f.mgr = e.empno
       ) AS child_cnt
  FROM emp e
 ORDER BY 2 DESC;
```

|ename  | child_cnt|
|:-----:|:--------:|
|BLAKE  |         5|
|KING   |         3|
|JONES  |         2|
|CLARK  |         1|
|FORD   |         1|
|SCOTT  |         1|
|JAMES  |         0|
|SMITH  |         0|
|MILLER |         0|
|ALLEN  |         0|
|WARD   |         0|
|MARTIN |         0|
|TURNER |         0|
|ADAMS  |         0|

```SQL
SELECT e.ename,
       (SELECT COUNT(*)
          FROM emp
         WHERE 0 = (SELECT COUNT(*)
                      FROM emp f
                     WHERE f.mgr = e.empno)
       ) AS is_leaf
  FROM emp e
 ORDER BY 2 DESC;
```

|ename  | is_leaf|
|:-----:|:-------:|
|SMITH  |      14|
|ALLEN  |      14|
|WARD   |      14|
|MARTIN |      14|
|TURNER |      14|
|ADAMS  |      14|
|JAMES  |      14|
|MILLER |      14|
|KING   |       0|
|JONES  |       0|
|FORD   |       0|
|BLAKE  |       0|
|CLARK  |       0|
|SCOTT  |       0|

We are getting `14` for the leafs because the cartesian product generates 14 rows.

The first `scalar subquery`, `IS_LEAF`, is shown here:

```SQL
SELECT e.ename,
       (SELECT SIGN(COUNT(*))
          FROM emp
         WHERE 0 = (SELECT COUNT(*)
                      FROM emp f
                     WHERE f.mgr = e.empno)
       ) AS is_leaf
  FROM emp e
 ORDER BY 2 DESC;
```

Because the output for `IS_LEAF` should be a 0 or 1, it is necessary to take the `SIGN` of the `COUNT(*)` operation. Otherwise, you would get 14 instead of 1 for leaf rows.

The PostgreSQL `SIGN()` function is used to return the sign of a given number. It returns `1` if the number is positive and `-1` if negative.

|ename  | is_leaf|
|:-----:|:-------:|
|SMITH  |       1|
|ALLEN  |       1|
|WARD   |       1|
|MARTIN |       1|
|TURNER |       1|
|ADAMS  |       1|
|JAMES  |       1|
|MILLER |       1|
|KING   |       0|
|JONES  |       0|
|FORD   |       0|
|BLAKE  |       0|
|CLARK  |       0|
|SCOTT  |       0|

As an alternative, you can use a table with only one row to count against, because you only want to return `0` or `1`. For example:

```SQL
SELECT e.ename,
       COALESCE((SELECT 1 AS d
                  WHERE NOT EXISTS (SELECT NULL
                                      FROM emp f
                                     WHERE f.mgr = e.empno)),0) AS is_leaf
  FROM emp e
 ORDER BY 2 DESC;  
```
The scalar subquery returns `1` in case there is no records in table `emp` where the `empno` exists in the `mgr` column. Otherwise returns `0`. It's worth noting that the clause `NOT EXISTS` will return `NULL` in case there is no match. The `NULL` value does not depend by the inner query, you could use `-1`, or anything, the result would be the same. The important step is to use the `COALESCE` function to turn the `NULL` value to the desired output, in this case `0`.


|ename  | is_leaf|
|:-----:|:-------:|
|SMITH  |       1|
|ALLEN  |       1|
|WARD   |       1|
|MARTIN |       1|
|TURNER |       1|
|ADAMS  |       1|
|JAMES  |       1|
|MILLER |       1|
|KING   |       0|
|JONES  |       0|
|FORD   |       0|
|BLAKE  |       0|
|CLARK  |       0|
|SCOTT  |       0|

The next step is to find branch nodes. If an employee is a manager (someone works for them) and they also happen to work for someone else, then the employee is a branch node. The results of the scalar subquery `IS_BRANCH` are shown here:

```SQL
SELECT e.ename,
      (SELECT SIGN(COUNT(*))
         FROM emp d
        WHERE d.mgr = e.empno
          AND e.mgr IS NOT NULL) AS is_branch
  FROM emp e
 ORDER BY 2 DESC;
```

|ename  | is_branch|
|:-----:|:--------:|
|BLAKE  |         1|
|CLARK  |         1|
|SCOTT  |         1|
|FORD   |         1|
|JONES  |         1|
|TURNER |         0|
|ADAMS  |         0|
|JAMES  |         0|
|SMITH  |         0|
|MILLER |         0|
|ALLEN  |         0|
|WARD   |         0|
|MARTIN |         0|
|KING   |         0|

Again, it is necessary to take the `SIGN` of the `COUNT(*)` operation. Otherwise, you will get (potentially) values greater than 1 when a node is a branch. Like scalar subquery `IS_LEAF`, you can use a table with one row to avoid using SIGN.

The following solution use `WHERE EXISTS`:

```SQL
SELECT e.ename,
       COALESCE((SELECT 1 AS d
                  WHERE EXISTS (SELECT NULL
                                  FROM emp f
                                 WHERE f.mgr = e.empno)
                                   AND e.mgr IS NOT NULL),0) AS is_branch
  FROM emp e
 ORDER BY 2 DESC;  
```

The last step is to find the root nodes. A root node is defined as an employee who is a manager but who does not work for anyone else. In table `EMP`, only `KING` is a root node. Scalar subquery `IS_ROOT` is shown here:

```SQL
SELECT e.ename,
      (SELECT SIGN(COUNT(*))
         FROM emp d
        WHERE d.mgr = e.empno
          AND e.mgr IS NULL) AS is_root
  FROM emp e
 ORDER BY 2 DESC;
```
|ename  | is_root|
|:-----:|:------:|
|KING   |       1|
|ALLEN  |       0|
|WARD   |       0|
|JONES  |       0|
|MARTIN |       0|
|BLAKE  |       0|
|CLARK  |       0|
|SCOTT  |       0|
|TURNER |       0|
|ADAMS  |       0|
|JAMES  |       0|
|FORD   |       0|
|SMITH  |       0|
|MILLER |       0|

The following solution use `WHERE EXISTS`:

```SQL
SELECT e.ename,
       COALESCE((SELECT 1 AS d
                  WHERE EXISTS (SELECT NULL
                                  FROM emp f
                                 WHERE f.mgr = e.empno)
                                   AND e.mgr IS NULL),0) AS is_root
  FROM emp e
 ORDER BY 2 DESC;  
```

An alternative is the following solution:

```SQL
SELECT ename,
       CASE WHEN NOT EXISTS (SELECT NULL
                               FROM emp f
                              WHERE f.mgr = e.empno)
            THEN 1 ELSE 0
       END AS is_leaf,
       CASE WHEN EXISTS (SELECT NULL
                           FROM emp f
                          WHERE f.mgr = e.empno) AND e.mgr IS NOT NULL  
            THEN 1 ELSE 0
       END AS is_branch,
       CASE WHEN mgr IS NULL
            THEN 1 ELSE 0
       END AS is_root
  FROM emp e
 ORDER BY 2 DESC;
```
