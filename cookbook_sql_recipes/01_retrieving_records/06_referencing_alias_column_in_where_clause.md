# Referencing an Aliased Column in the WHERE Clause Problem

You have used `aliases` to provide more meaningful column names for your result set and would like to exclude some of the rows using the `WHERE` clause. However, your attempt **to reference alias names in the** `WHERE` **clause fails**:

```SQL
SELECT sal as salary,
       comm as commission
  FROM emp
 WHERE salary < 5000;
```

```console
cookbook=> SELECT sal as salary,
cookbook->        comm as commission
cookbook->   FROM emp
cookbook->  WHERE salary < 5000;
ERROR:  column "salary" does not exist
LINE 4:  WHERE salary < 5000;
               ^
HINT:  Perhaps you meant to reference the column "emp.sal".
```

## Solution

By wrapping your query as an **inline view**, **you can reference the aliased columns**:

```SQL
SELECT *
  FROM (
        SELECT sal AS salary,
               comm AS commission  
          FROM emp
       )x
 WHERE salary < 5000;
```

**Output**

|salary | commission|
|:------:|:--------:|
|   800 |      NULL;|
|  1600 |        300|
|  1250 |        500|
|  2975 |      NULL;|
|  1250 |       1400|
|  2850 |      NULL;|
|  2450 |      NULL;|
|  3000 |      NULL;|
|  1500 |          0|
|  1100 |      NULL;|
|   950 |      NULL;|
|  3000 |      NULL;|
|  1300 |      NULL;|

**(13 rows)**

## Discussion

In this simple example, you can avoid the inline view and reference COMM or SAL directly in the `WHERE` clause to achieve the same result. This solution introduces you to **what you would need to do when attempting to reference any of the following in a** `WHERE` clause:

- **Aggregate functions**
- **Scalar subqueries**
- **Windowing functions**  
- **Aliases**

Placing your query, the one giving `aliases`, in an **inline view** gives you the ability to reference the aliased columns in your `outer query`.

```console
FROM -> WHERE -> SELECT
```

Why do you need to do this? The `WHERE` clause is **evaluated before** the `SELECT`; thus, `SALARY` and `COMMISSION` do not yet exist when the “Problem” query’s `WHERE` clause is evaluated. Those aliases are not applied until after the `WHERE` clause processing is complete.

However, the `FROM` clause **is evaluated before** the `WHERE`. By placing the original query in a `FROM` clause, the results from that query are generated before the outermost `WHERE` clause, and your outermost WHERE clause “sees” the alias names.

This technique is particularly useful when the columns in a table are not named particularly well.
