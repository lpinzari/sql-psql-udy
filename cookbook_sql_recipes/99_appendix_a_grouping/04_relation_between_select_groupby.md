# Relationship Between SELECT and GROUP BY

With the concept of a group defined and proved, it is now time to move on to more practical matters concerning queries using `GROUP BY`.

It is important to understand the relationship between the `SELECT` clause and the `GROUP BY` clause when grouping in SQL.
:warning:
It is important to keep in mind when using aggregate functions such as `COUNT` that **any item in your** `SELECT` **list that is not used as an argument to an aggregate function must be part of your group**.

For example, if you write a `SELECT` clause such as this:

```SQL
SELECT deptno,
       COUNT(*) AS cnt
  FROM emp;
```

```console
ERROR:  column "emp.deptno" must appear in the GROUP BY clause or be used in an aggregate function
LINE 1: SELECT deptno,
               ^
```

then you must list `DEPTNO` in your `GROUP BY` clause:

```SQL
SELECT deptno,
       COUNT(*) AS cnt
  FROM emp
 GROUP BY deptno;
```

|deptno | cnt|
|:-----:|:---:|
|    30 |   6|
|    10 |   3|
|    20 |   5|


- Constants,
- scalar values returned by user-defined functions,
- window functions, and
- noncorrelated scalar subqueries are exceptions to this rule.

Since the `SELECT` clause **is evaluated after the** `GROUP BY` clause, **these constructs are allowed in the** `SELECT` **list** and **do not have to** (`and in some cases cannot`) **be specified in the** `GROUP BY` clause.

For example:

```SQL
SELECT 'hello' AS msg,
        1 AS num,
        deptno,
        (SELECT COUNT(*) FROM emp) AS total,
        COUNT(*) AS cnt
  FROM emp
 GROUP BY deptno;
```

|msg  | num | deptno | total | cnt|
|:----:|:---:|:------:|:-----:|:--:|
|hello |   1 |     30 |    14 |   6|
|hello |   1 |     10 |    14 |   3|
|hello |   1 |     20 |    14 |   5|

Don’t let this query confuse you. The items in the `SELECT list` **not listed in the** `GROUP BY` **clause do not change the value of** `CNT` **for each** `DEPTNO`, **nor do the values for** `DEPTNO` **change**.

Based on the results of the preceding query, we can define the **rule about matching items in the** `SELECT` **list and the** `GROUP BY` **clause when using aggregates a bit more precisely**:

- Items in a `SELECT list` **that can potentially change the group or change the value returned by an aggregate function** `must be` **included in the** `GROUP BY clause`.

The additional items in the preceding `SELECT list`
- did not change the value of `CNT` for any group (each `DEPTNO`),
- nor did they change the groups themselves.

Now it’s fair to ask: exactly what items in a `SELECT list` **can change a grouping or the value returned by an aggregate function?**

The answer is simple: **other columns from the table(s) you are selecting from**.

Consider the prospect of adding the `JOB` column to the query we’ve been looking at:

```SQL
SELECT deptno,
          job,
       COUNT(*) AS cnt
  FROM emp
 GROUP BY deptno, job
 ORDER BY deptno, job;
```

|deptno |    job    | cnt|
|:-----:|:---------:|:---:|
|    10 | CLERK     |   1|
|    10 | MANAGER   |   1|
|    10 | PRESIDENT |   1|
|    20 | ANALYST   |   2|
|    20 | CLERK     |   2|
|    20 | MANAGER   |   1|
|    30 | CLERK     |   1|
|    30 | MANAGER   |   1|
|    30 | SALESMAN  |   4|

By listing another column, `JOB`, from table `EMP`, we are **changing the group and changing the result set**.

Thus, we must now include `JOB` in the `GROUP BY` clause along with `DEPTNO`; otherwise, **the query will fail**.

The inclusion of `JOB` in the `SELECT/GROUP BY` clauses changes the query from

- “`How many employees are in each department?`” **to** “`How many different types of employees are in each department?`”

Notice again that **the groups are distinct**; the values for `DEPTNO` and `JOB` individually are not distinct, but **the combination of the two** (which is what is in the `GROUP BY` and `SELECT` list, and thus in the group) **is distinct** (e.g., `10` and `CLERK` appear only once).

If you choose not to put items other than aggregate functions in the `SELECT list`, then you may list any valid column you want in the `GROUP BY` clause.

Consider the following two queries, which highlight this fact:

```SQL
SELECT COUNT(*)
  FROM emp
 GROUP BY deptno;
```

|count|
|:---:|
|    6|
|    3|
|    5|

**(3 rows)**

```SQL
SELECT COUNT(*)
  FROM emp
 GROUP BY deptno,job;
```

|count|
|:----:|
|    2|
|    1|
|    1|
|    1|
|    2|
|    4|
|    1|
|    1|
|    1|

**(9 rows)**

Including items other than aggregate functions in the SELECT list is not mandatory, but often improves readability and usability of the results.

As a rule, when using `GROUP BY` and aggregate functions, any items in the `SELECT list` (from the table(s) in the `FROM` clause) not used as an argument to an aggregate function must be included in the `GROUP BY` clause.
