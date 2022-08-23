# Expressing a Child-Parent-Grandparent Relationship

Employee `CLARK` works for `KING`, and to express that relationship you can use the first recipe in this chapter. What if employee `CLARK` was in turn `a manager for another employee`?

Consider the following query:

```SQL
SELECT ename, empno, mgr
  FROM emp
 WHERE ename IN ('KING','CLARK','MILLER');
```

|ename  | empno | mgr|
|:-----:|:-----:|:----:|
|CLARK  |  7782 | 7839|
|KING   |  7839 ||
|MILLER |  7934 | 7782|

As you can see, employee `MILLER` works for `CLARK` who in turn works for `KING`. You want to express the full hierarchy from `MILLER` to `KING`. You want to return the following result set:

|leaf___branch___root|
|:-----------------------:|
|MILLER --> CLARK --> KING|

However, the single self-join approach from the previous recipe will not suffice to show the entire relationship from top to bottom. You could write a query that does two self-joins, but what you really need is a general approach for traversing such hierarchies.

## Solution

This recipe differs from the first recipe because there is now a three-tier relationship, as the title suggests. If your RDBMS does not supply functionality for traversing tree- structured data, as is the case for Oracle, then you can solve this problem using the CTEs.

Use the recursive `WITH` clause to find `MILLER’s` manager, `CLARK`, and then `CLARK’s` manager, `KING`.

```SQL
WITH RECURSIVE x AS (
  SELECT ename::VARCHAR(100) AS tree,
         mgr AS mgr,
         0 AS depth
    FROM emp
   WHERE ename = 'MILLER'
  UNION ALL
  SELECT (x.tree || ' --> ' || e.ename)::VARCHAR(100),
         e.mgr,
         x.depth + 1
    FROM emp e, x
   WHERE x.mgr = e.empno
)
SELECT tree AS LEAF___BRANCH___ROOT
  FROM x
 WHERE depth = 2;
```

## Discussion

The approach here is to start at the leaf node and walk your way up to the root (as useful practice, try walking in the other direction). The upper part of the` UNION ALL` simply finds the row for employee `MILLER` (the leaf node). The lower part of the `UNION ALL` finds the employee who is `MILLER’s` manager and then finds that person’s manager, and this process of finding the “manager’s manager” repeats until processing stops at the highest-level manager (the root node). The value for DEPTH starts at 0 and increments automatically by 1 each time a manager is found. DEPTH is a value that DB2 maintains for you when you execute a recursive query.

Next, the second query of the UNION ALL joins the recursive view X to table EMP, to define the parent-child relationship.


```SQL
WITH RECURSIVE x AS (
  SELECT ename::VARCHAR(100) AS tree,
         mgr AS mgr,
         0 AS depth
    FROM emp
   WHERE ename = 'MILLER'
  UNION ALL
  SELECT (x.tree || ' --> ' || e.ename)::VARCHAR(100),
         e.mgr,
         x.depth + 1
    FROM emp e, x
   WHERE x.mgr = e.empno
)
SELECT depth, tree AS LEAF___BRANCH___ROOT
  FROM x;
```

|depth |   leaf___branch___root|
|:----:|:--------------------------:|
|    0 | MILLER|
|    1 | MILLER --> CLARK|
|    2 | MILLER --> CLARK --> KING|

The final step is to keep only the last row in the hierarchy. There are several ways to do this, but the solution uses DEPTH to determine when the root is reached (obvi‐ ously, if CLARK has a manager other than KING, the filter on DEPTH would have to change; for a more generic solution that requires no such filter, see the next recipe).
