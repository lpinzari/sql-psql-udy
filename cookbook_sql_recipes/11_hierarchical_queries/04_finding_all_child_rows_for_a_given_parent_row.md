# Finding All Child Rows for a Given Parent Row

You want to find `all the employees` who **work for** `JONES`, either **directly or indirectly** (i.e., `they work for someone who works for JONES`). The list of employees under JONES is shown here (`JONES` is included in the result set):

```console
LEVEL
0                            KING
                              |
              +---------------+-------------------+
      ROOT    |               |                   |
              V               |                   |
    +-------------------+     |                   |
1   |       JONES       |   CLARK               BLAKE
    |         |         |     |                   |
    |   +-----+-----+   |     |        +------+------+-------+------+
    |   |           |   |     |        |      |      |       |      |
2   | SCOTT       FORD  |   MILLER    ALLEN  WARD  MARTIN  TURNER  JAMES
    |   |           |   |
3   | ADAMS       SMITH |
    +-------------------+
```

|ename|
|:---:|
|JONES|
|SCOTT|
|FORD|
|SMITH|
|ADAMS|

## Solution

Being able to move to the absolute top or bottom of a tree is extremely useful. For this solution, there is no special formatting necessary. **The goal is to simply return all employees who work under employee** `JONES`, including `JONES` himself.

```SQL
WITH RECURSIVE x (ename, empno) AS (
  SELECT ename,
         empno
    FROM emp
   WHERE ename = 'JONES'
  UNION ALL
  SELECT e.ename,
         e.empno
    FROM emp e, x
   WHERE e.mgr = x.empno
)
SELECT ename
  FROM x;
```

Use the recursive WITH clause to find all employees under JONES. Begin with `JONES` by specifying `WHERE ENAME = JONES` in the first of the two union queries. This condition makes `JONES` the **root node**. . It's the root of the `Tree` data structure.

## Discussion

The recursive `WITH` clause makes this a relatively easy problem to solve. The first part of the `WITH` clause, the upper part of the `UNION ALL`, returns the row for employee `JONES`. You need to return `ENAME` to see the name and `EMPNO` so you can use it to join on. The lower part of the `UNION ALL` recursively joins `EMP.MGR` to `X.EMPNO`. The join condition will be applied until the result set is exhausted.
