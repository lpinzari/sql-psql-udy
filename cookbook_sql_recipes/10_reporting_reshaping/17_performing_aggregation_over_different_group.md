# Performing Aggregations over Different Groups/ Partitions Simultaneously


You want to `aggregate` over **different dimensions at the same time**.

## Problem

For example, you want to return a result set that lists each
- employee’s `name`,
- their `department`,
  - the `number of employees` in **their department** (themselves included),
  - the `number of employees` that **have the same job** (themselves included in this count as well), and
  - the `total number of employees` in the **EMP table**.

The result set should look like the following:

|ename  | deptno | deptno_cnt | job_cnt | total|
|:-----:|:------:|:----------:|:-------:|:----:|
|CLARK  |     10 |          3 |       3 |    14|
|KING   |     10 |          3 |       1 |    14|
|MILLER |     10 |          3 |       4 |    14|
|ADAMS  |     20 |          5 |       4 |    14|
|FORD   |     20 |          5 |       2 |    14|
|JONES  |     20 |          5 |       3 |    14|
|SCOTT  |     20 |          5 |       2 |    14|
|SMITH  |     20 |          5 |       4 |    14|
|ALLEN  |     30 |          6 |       4 |    14|
|BLAKE  |     30 |          6 |       3 |    14|
|JAMES  |     30 |          6 |       4 |    14|
|MARTIN |     30 |          6 |       4 |    14|
|TURNER |     30 |          6 |       4 |    14|
|WARD   |     30 |          6 |       4 |    14|

## Solution

Use the `COUNT OVER` **window function** while specifying `different partitions`, or groups of data, on which to perform aggregation:

```SQL
SELECT ename,
       deptno,
       COUNT(*) OVER(PARTITION BY deptno) AS deptno_cnt,
       COUNT(*) OVER(PARTITION BY job) AS job_cnt,
       COUNT(*) OVER() AS total
  FROM emp
 ORDER BY deptno, ename;
```

## Discussion

This example really shows off the power and convenience of window functions. By simply specifying different partitions or groups of data to aggregate, you can create immensely detailed reports without having to self-join over and over, and without having to write cumbersome and perhaps poorly performing subqueries in your SELECT list. All the work is done by the window function `COUNT OVER`. To understand the output, focus on the OVER clause for a moment for each `COUNT` operation:

- `count(*)over(partition by deptno)`
- `count(*)over(partition by job)`
- `count(*)over()`

Remember the main parts of the `OVER` clause: the `PARTITION BY` subclause, dividing the query into partitions; and the `ORDER BY` subclause, defining the logical order.

Look at the first `COUNT`, which partitions by `DEPTNO`. The rows in table `EMP` will be grouped by `DEPTNO`, and the `COUNT` operation will be performed on all the rows in each group.

Since there is no frame or window clause specified (no `ORDER BY`), all the rows in the group are counted. The `PARTITION BY` clause finds all the unique `DEPTNO` values, and then the `COUNT` function counts the number of rows having each value. In the specific example of `COUNT(*)OVER(PARTITION BY DEPTNO)`, the PARTITION BY clause identifies the partitions or groups to be values 10, 20, and 30.

The same processing is applied to the second `COUNT`, which partitions by `JOB`. The last count does not partition by anything and simply has an empty parentheses.

An empty parentheses implies “the whole table.” So, whereas the two prior COUNTs aggregate values based on the defined groups or partitions, the final COUNT counts all rows in table EMP.

Keep in mind that window functions are applied after the `WHERE` clause. 
