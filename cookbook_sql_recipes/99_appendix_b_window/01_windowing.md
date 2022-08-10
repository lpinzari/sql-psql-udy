# Windowing

Once you understand the concept of grouping and using aggregates in SQL, under‐ standing window functions is easy.

**Window functions**, like aggregate functions, **perform an aggregation on a defined set (a group) of rows**, but rather than returning one value per group, **window functions can return multiple values for each group**.

The `group of rows` to perform the aggregation on is the `window`. DB2 actually calls such functions online analytic processing (OLAP) functions, and Oracle calls them **analytic functions**, but the ISO SQL standard calls them window functions, so that’s the term used in this course.

## A simple example

Let’s say that you want to **count the total number of employees across all departments**.

The traditional method for doing that is to issue a `COUNT(*)` query against the entire `EMP` table:

```SQL
SELECT COUNT(*) AS cnt
  FROM emp;
```

|cnt|
|:---:|
| 14|

This is easy enough, but often you will find yourself wanting to **access such aggregate data from rows that do not represent an aggregation**, or that **represent a different aggregation**.

**Window functions** `make light work of such problems`.

For example, the following query shows how you can use a window function to access aggregate data (the `total count of employees`) from detail rows (**one per employee**):

```SQL
SELECT ename,
       deptno,
       COUNT(*) OVER() AS cnt
  FROM emp
 ORDER BY 2;
```

|ename  | deptno | cnt|
|:-----:|:------:|:--:|
|MILLER |     10 |  14|
|CLARK  |     10 |  14|
|KING   |     10 |  14|
|SCOTT  |     20 |  14|
|JONES  |     20 |  14|
|SMITH  |     20 |  14|
|ADAMS  |     20 |  14|
|FORD   |     20 |  14|
|WARD   |     30 |  14|
|TURNER |     30 |  14|
|ALLEN  |     30 |  14|
|BLAKE  |     30 |  14|
|MARTIN |     30 |  14|
|JAMES  |     30 |  14|

The window function invocation in this example is `COUNT(*) OVER()`. The presence of the **OVER** `keyword` **indicates that the invocation of** `COUNT` **will be treated as a window function**, `not as an aggregate function`.

In general, the SQL standard allows for all aggregate functions to also be window functions, and the keyword **OVER** is **how the language distinguishes between the two uses**.

So, what did the window function `COUNT(*) OVER ()` **do exactly**?

For **every row being returned in the query**, **it returned the count of all the rows in the table**.

As the `empty parentheses suggest`, the **OVER** keyword accepts additional clauses to affect the range of rows that a given window function considers. Absent any such clauses, the **window function** `looks at all rows in the result set`, which is why you see the value `14` repeated in each row of output.

Hopefully you are beginning to see the great utility of window functions, which is that they allow you to work with multiple levels of aggregation in one row. As you continue through this appendix, you’ll begin to see even more just how incredibly useful that ability can be.
