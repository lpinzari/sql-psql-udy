# Creating a Predefined Number of Buckets

You want to organize your data into a `fixed number of buckets`.

## Problem

For example, you want to organize the employees in table `EMP` into **four buckets**. The result set should look similar to the following:


|group | empno | ename|
|:----:|:-----:|:-----:|
|    1 |  7369 | SMITH|
|    1 |  7499 | ALLEN|
|    1 |  7521 | WARD|
|    1 |  7566 | JONES|
|    2 |  7654 | MARTIN|
|    2 |  7698 | BLAKE|
|    2 |  7782 | CLARK|
|    2 |  7788 | SCOTT|
|    3 |  7839 | KING|
|    3 |  7844 | TURNER|
|    3 |  7876 | ADAMS|
|    4 |  7900 | JAMES|
|    4 |  7902 | FORD|
|    4 |  7934 | MILLER|

This is a common way to organize categorical data as dividing a set into a number of smaller equal sized sets is an important first step for many kinds of analysis. For example, taking the averages of these groups on salary or any other value may reveal a trend that is concealed by variability when looking at the cases individually.


This problem is the opposite of the previous recipe, where you had an unknown number of buckets but a predetermined number of elements in each bucket. In this recipe, the goal is such that you may not necessarily know how many elements are in each bucket, but **you are defining a fixed (known) number of buckets to be created**.


## Solution

The solution to this problem is simple now that the `NTILE` function is widely available.

**NTILE** organizes an **ordered set into the number of buckets you specify**, with any stragglers distributed into the available buckets starting from the first bucket. The desired result set for this recipe reflects this: buckets 1 and 2 have four rows, while buckets 3 and 4 have three rows.

```SQL
SELECT NTILE(4) OVER(ORDER BY empno) AS group,
       empno,
       ename
  FROM emp;
```

## Discussion

All the work is done by the `NTILE` function. The `ORDER BY` clause puts the rows into the desired order, and the function itself then assigns a group number to each row, for example, so that the first quarter (in this case) are put into group one, the second into group two, etc.
