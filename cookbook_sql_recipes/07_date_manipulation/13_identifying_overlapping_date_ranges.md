# Identifying Overlapping Date Ranges

You want to find **all instances of an employee** `starting` a new project **before** `ending` an existing project.

Consider table `EMP_PROJECT`:


```SQL
CREATE TABLE emp_project (
  empno INTEGER,
  ename VARCHAR(10),
  proj_id INTEGER,
  proj_start DATE,
  proj_end DATE,
  PRIMARY KEY(empno,proj_id)
);
```

```console
cookbook=# \d emp_project
                     Table "public.emp_project"
   Column   |         Type          | Collation | Nullable | Default
------------+-----------------------+-----------+----------+---------
 empno      | integer               |           | not null |
 ename      | character varying(10) |           |          |
 proj_id    | integer               |           | not null |
 proj_start | date                  |           |          |
 proj_end   | date                  |           |          |
Indexes:
    "emp_project_pkey" PRIMARY KEY, btree (empno, proj_id)
```

```SQL
INSERT INTO emp_project
       (empno, ename, proj_id, proj_start, proj_end)
VALUES (7782,'CLARK',1,'2005-06-16','2005-06-18'),
       (7782,'CLARK',4,'2005-06-19','2005-06-24'),
       (7782,'CLARK',7,'2005-06-22','2005-06-25'),
       (7782,'CLARK',10,'2005-06-25','2005-06-28'),
       (7782,'CLARK',13,'2005-06-28','2005-07-02'),
       (7839,'KING',2,'2005-06-17','2005-06-21'),
       (7839,'KING',8,'2005-06-23','2005-06-25'),
       (7839,'KING',14,'2005-06-29','2005-06-30'),
       (7839,'KING',11,'2005-06-26','2005-06-27'),
       (7839,'KING',5,'2005-06-20','2005-06-24'),
       (7934,'MILLER',3,'2005-06-18','2005-06-22'),
       (7934,'MILLER',12,'2005-06-22','2005-06-28'),
       (7934,'MILLER',15,'2005-06-30','2005-07-03'),
       (7934,'MILLER',9,'2005-06-24','2005-06-27'),
       (7934,'MILLER',6,'2005-06-21','2005-06-23');
```

|empno | ename  | proj_id | proj_start |  proj_end|
|:----:|:------:|:-------:|:----------:|:---------:|
| 7782 | CLARK  |       1 | 2005-06-16 | 2005-06-18|
| 7782 | CLARK  |       4 | 2005-06-19 | 2005-06-24|
| 7782 | CLARK  |       7 | 2005-06-22 | 2005-06-25|
| 7782 | CLARK  |      10 | 2005-06-25 | 2005-06-28|
| 7782 | CLARK  |      13 | 2005-06-28 | 2005-07-02|
| 7839 | KING   |       2 | 2005-06-17 | 2005-06-21|
| 7839 | KING   |       8 | 2005-06-23 | 2005-06-25|
| 7839 | KING   |      14 | 2005-06-29 | 2005-06-30|
| 7839 | KING   |      11 | 2005-06-26 | 2005-06-27|
| 7839 | KING   |       5 | 2005-06-20 | 2005-06-24|
| 7934 | MILLER |       3 | 2005-06-18 | 2005-06-22|
| 7934 | MILLER |      12 | 2005-06-22 | 2005-06-28|
| 7934 | MILLER |      15 | 2005-06-30 | 2005-07-03|
| 7934 | MILLER |       9 | 2005-06-24 | 2005-06-27|
| 7934 | MILLER |       6 | 2005-06-21 | 2005-06-23|

```console
2005-06 CLARK
   16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  1   2  3
1  |--------|
4               |-------------------|
7                          |------------|
10                                      |-----------|
13                                                  |-------------------|   
             project 7 overlaps project 4
             project 10 overlaps project 7
             project 13 overlaps project 10
KING
2      |----------------|
8                              |--------|
14                                                      |---|
11                                          |---|
5                   |---------------|
            project 5 overlaps project 2
            project 8 overlaps project 5

MILLER
3           |---------------|
12                          |-----------------------|
15                                                          |---------------|   
9                                   |------------|
6                       |--------|
             project 6 overlaps project 3
             project 12 overlaps project 3
             project 12 overlaps project 6
             project 9 overlaps project 12
```

Looking at the results for employee `KING`, you see that `KING` began `PROJ_ID 8` before finishing `PROJ_ID 5` and began `PROJ_ID 5` before finishing `PROJ_ID 2`. You want to return the following result set:

|empno | ename  |              msg|
|:----:|:------:|:---------------------------:|
| 7782 | CLARK  | project 7 overlaps project 4|
| 7782 | CLARK  | project 10 overlaps project 7|
| 7782 | CLARK  | project 13 overlaps project 10|
| 7839 | KING   | project 5 overlaps project 2|
| 7839 | KING   | project 8 overlaps project 5|
| 7934 | MILLER | project 6 overlaps project 3|
| 7934 | MILLER | project 12 overlaps project 3|
| 7934 | MILLER | project 12 overlaps project 6|
| 7934 | MILLER | project 9 overlaps project 12|


## Solution

The key here is to find rows where `PROJ_START` (the date the new project starts) occurs on or after another project’s `PROJ_START` date and on or before that other project’s `PROJ_END` date.

To begin, you need to be able to compare each project with each other project (for the same employee). By **self-joining** `EMP_PROJECT` on employee, you generate every possible combination of two projects for each employee. To find the overlaps, simply find the rows where `PROJ_START` for any `PROJ_ID` **falls between** `PROJ_START` and `PROJ_END` for another `PROJ_ID` by the same employee.

```SQL
SELECT ep1.empno, ep1.ename,
       'project ' || ep2.proj_id || ' overlaps project ' || ep1.proj_id AS msg
  FROM emp_project ep1
  JOIN emp_project ep2
    ON ep1.empno = ep2.empno
   AND ep1.proj_id != ep2.proj_id
   AND ep2.proj_start >= ep1.proj_start
   AND ep2.proj_start <= ep1.proj_end
 ORDER BY 1;
```

- **Solution 2**

```SQL
WITH x AS (
  SELECT empno,
         ename,
         proj_id,
         proj_start,
         proj_end,
         CASE WHEN LEAD(proj_start,1) OVER(PARTITION BY empno
                                               ORDER BY proj_start)
                   BETWEEN proj_start AND proj_end
                   THEN LEAD(proj_id,1) OVER(PARTITION BY empno
                                               ORDER BY proj_start)
              WHEN LEAD(proj_start,2) OVER(PARTITION BY empno
                                               ORDER BY proj_start)
                   BETWEEN proj_start AND proj_end
                   THEN LEAD(proj_id,2) OVER(PARTITION BY empno
                                                ORDER BY proj_start)
              WHEN LEAD(proj_start,3) OVER(PARTITION BY empno
                                               ORDER BY proj_start)
                   BETWEEN proj_start AND proj_end
                   THEN LEAD(proj_id,3) OVER(PARTITION BY empno
                                                 ORDER BY proj_start)
              WHEN LEAD(proj_start,4) OVER(PARTITION BY empno
                                               ORDER BY proj_start)
                   BETWEEN proj_start AND proj_end
                   THEN LEAD(proj_id,4) OVER(PARTITION BY empno
                                                 ORDER BY proj_start)
         END AS is_overlap
    FROM emp_project
)
SELECT empno, ename,
       'project ' || is_overlap || ' overlaps project ' || proj_id AS msg
  FROM x
 WHERE is_overlap IS NOT NULL;
```


## Discussion

The first step is a **self-join** of `EMP_PROJECT` so that the `PROJ_START` dates can be compared among the `different projects`. The output of the self-join for employee `KING` is shown here.

You can observe how each project can “see” the other projects:

```SQL
SELECT ep1.ename,
       ep1.proj_id AS ep1_proj_id,
       ep1.proj_start AS p1_start,
       ep1.proj_end AS p1_end,
       ep2.proj_start AS p2_start,
       ep2.proj_end AS p2_end
  FROM emp_project ep1
  JOIN emp_project ep2
    ON ep1.ename = 'KING'
   AND ep1.empno = ep2.empno
   AND ep1.proj_id != ep2.proj_id
 ORDER BY 2;
```

```console
|ename | ep1_proj_id |  p1_start  |   p1_end   |  p2_start  |   p2_end|
|:----:|:-----------:|:----------:|:----------:|:----------:|:---------:|
|KING  |           2 | 2005-06-17 | 2005-06-21 | 2005-06-20 | 2005-06-24|
|KING  |           2 | 2005-06-17 | 2005-06-21 | 2005-06-23 | 2005-06-25|
|KING  |           2 | 2005-06-17 | 2005-06-21 | 2005-06-26 | 2005-06-27|
|KING  |           2 | 2005-06-17 | 2005-06-21 | 2005-06-29 | 2005-06-30|
|KING  |           5 | 2005-06-20 | 2005-06-24 | 2005-06-17 | 2005-06-21|
|KING  |           5 | 2005-06-20 | 2005-06-24 | 2005-06-23 | 2005-06-25| <--- (23 > 20) AND (23 < 24)
|KING  |           5 | 2005-06-20 | 2005-06-24 | 2005-06-29 | 2005-06-30|
|KING  |           5 | 2005-06-20 | 2005-06-24 | 2005-06-26 | 2005-06-27|
|KING  |           8 | 2005-06-23 | 2005-06-25 | 2005-06-20 | 2005-06-24|
|KING  |           8 | 2005-06-23 | 2005-06-25 | 2005-06-29 | 2005-06-30|
|KING  |           8 | 2005-06-23 | 2005-06-25 | 2005-06-17 | 2005-06-21|
|KING  |           8 | 2005-06-23 | 2005-06-25 | 2005-06-26 | 2005-06-27|
|KING  |          11 | 2005-06-26 | 2005-06-27 | 2005-06-17 | 2005-06-21|
|KING  |          11 | 2005-06-26 | 2005-06-27 | 2005-06-23 | 2005-06-25|
|KING  |          11 | 2005-06-26 | 2005-06-27 | 2005-06-20 | 2005-06-24|
|KING  |          11 | 2005-06-26 | 2005-06-27 | 2005-06-29 | 2005-06-30|
|KING  |          14 | 2005-06-29 | 2005-06-30 | 2005-06-20 | 2005-06-24|
|KING  |          14 | 2005-06-29 | 2005-06-30 | 2005-06-26 | 2005-06-27|
|KING  |          14 | 2005-06-29 | 2005-06-30 | 2005-06-23 | 2005-06-25|
|KING  |          14 | 2005-06-29 | 2005-06-30 | 2005-06-17 | 2005-06-21|

   16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  1   2  3
KING                 p2_start
2      |----------------|
                            p2_start
8                              |--------|
14                                                      |---|
11                                          |---|
                  p1_start        p1_end
5                   |---------------|
```

As you can see from the result set, the self-join makes finding overlapping dates easy: simply return each row where `p2_START` occurs between `p1_START` and `p1_END`.

```console
    ep2.proj_start >= ep1.proj_start
AND ep2.proj_start <= ep1.proj_end
```

```SQL
SELECT ep1.empno, ep1.ename,
       'project ' || ep2.proj_id || ' overlaps project ' || ep1.proj_id AS msg
  FROM emp_project ep1
  JOIN emp_project ep2
    ON ep1.empno = ep2.empno
   AND ep1.proj_id != ep2.proj_id
   AND ep2.proj_start >= ep1.proj_start
   AND ep2.proj_start <= ep1.proj_end
 ORDER BY 1;
```

Once you have the required rows, constructing the messages is just a matter of concatenating the return values.

- **Solution 2**:

we can use the window function `LEAD OVER` to avoid the `self-join`, **if the maximum number of projects per employee is fixed**.

This can come in handy if the `self-join` is `expensive` for your particular results (if the self-join requires more resources than the sorts needed for `LEAD OVER`).


```SQL
SELECT empno,
       ename,
       proj_id,
       proj_start,
       proj_end
  FROM emp_project
 WHERE ename = 'KING'
 ORDER BY proj_start;
```

```console
empno | ename | proj_id | proj_start    |  proj_end
-------+-------+---------+------------+------------        LEAD(project_start,1)
 7839 | KING  |       2 | 2005-06-17    | 2005-06-21    2005-06-17----|----2005-06-21
 7839 | KING  |       5 | **2005-06-20**| 2005-06-24 <----       2005-06-20 (id = 5)

                                                        2005-06-20----|----2005-06-24
 7839 | KING  |       8 | **2005-06-23**| 2005-06-25 <----       2005-06-23 (id = 8)

                                            2005-06-23---2005-06-25---|
 7839 | KING  |      11 | 2005-06-26 | 2005-06-27              2005-06-26             
 7839 | KING  |      14 | 2005-06-29 | 2005-06-30
```

For example, consider the alternative for employee `KING` using `LEAD OVER`:

```SQL
SELECT empno,
       ename,
       proj_id,
       proj_start,
       proj_end,
       CASE WHEN LEAD(proj_start,1) OVER(ORDER BY proj_start)
                 BETWEEN proj_start AND proj_end
                 THEN LEAD(proj_id,1) OVER(ORDER BY proj_start)
            WHEN LEAD(proj_start,2) OVER(ORDER BY proj_start)
                 BETWEEN proj_start AND proj_end
                 THEN LEAD(proj_id,2) OVER(ORDER BY proj_start)
            WHEN LEAD(proj_start,3) OVER(ORDER BY proj_start)
                 BETWEEN proj_start AND proj_end
                 THEN LEAD(proj_id,3) OVER(ORDER BY proj_start)
            WHEN LEAD(proj_start,4) OVER(ORDER BY proj_start)
                 BETWEEN proj_start AND proj_end
                 THEN LEAD(proj_id,4) OVER(ORDER BY proj_start)
       END AS is_overlap
  FROM emp_project
 WHERE ename = 'KING';
```

|empno | ename | proj_id | proj_start |  proj_end  | is_overlap|
|:----:|:-----:|:--------:|:---------:|:----------:|:---------:|
|7839 | KING  |       2 | 2005-06-17 | 2005-06-21 |          5|
|7839 | KING  |       5 | 2005-06-20 | 2005-06-24 |          8|
|7839 | KING  |       8 | 2005-06-23 | 2005-06-25 ||
|7839 | KING  |      11 | 2005-06-26 | 2005-06-27 ||
|7839 | KING  |      14 | 2005-06-29 | 2005-06-30 ||

Because the number of projects is fixed at five for employee `KING`, you can use `LEAD OVER` to examine the dates of all the projects without a self-join. From here, producing the final result set is easy. Simply keep the rows where `IS_OVERLAP` is `not NULL`:

```SQL
WITH x AS (
  SELECT empno,
         ename,
         proj_id,
         proj_start,
         proj_end,
         CASE WHEN LEAD(proj_start,1) OVER(ORDER BY proj_start)
                   BETWEEN proj_start AND proj_end
                   THEN LEAD(proj_id,1) OVER(ORDER BY proj_start)
              WHEN LEAD(proj_start,2) OVER(ORDER BY proj_start)
                   BETWEEN proj_start AND proj_end
                   THEN LEAD(proj_id,2) OVER(ORDER BY proj_start)
              WHEN LEAD(proj_start,3) OVER(ORDER BY proj_start)
                   BETWEEN proj_start AND proj_end
                   THEN LEAD(proj_id,3) OVER(ORDER BY proj_start)
              WHEN LEAD(proj_start,4) OVER(ORDER BY proj_start)
                   BETWEEN proj_start AND proj_end
                   THEN LEAD(proj_id,4) OVER(ORDER BY proj_start)
         END AS is_overlap
    FROM emp_project
   WHERE ename = 'KING'
)
SELECT empno, ename,
       'project ' || is_overlap || ' overlaps project ' || proj_id AS msg
  FROM x
 WHERE is_overlap IS NOT NULL;
```

|empno | ename |             msg|
|:----:|:-----:|:---------------------------:|
| 7839 | KING  | project 5 overlaps project 2|
| 7839 | KING  | project 8 overlaps project 5|

To allow the solution to work for all employees (not just KING), partition by `EMPNO` in the `LEAD OVER` function:

```SQL
WITH x AS (
  SELECT empno,
         ename,
         proj_id,
         proj_start,
         proj_end,
         CASE WHEN LEAD(proj_start,1) OVER(PARTITION BY empno
                                               ORDER BY proj_start)
                   BETWEEN proj_start AND proj_end
                   THEN LEAD(proj_id,1) OVER(PARTITION BY empno
                                               ORDER BY proj_start)
              WHEN LEAD(proj_start,2) OVER(PARTITION BY empno
                                               ORDER BY proj_start)
                   BETWEEN proj_start AND proj_end
                   THEN LEAD(proj_id,2) OVER(PARTITION BY empno
                                                ORDER BY proj_start)
              WHEN LEAD(proj_start,3) OVER(PARTITION BY empno
                                               ORDER BY proj_start)
                   BETWEEN proj_start AND proj_end
                   THEN LEAD(proj_id,3) OVER(PARTITION BY empno
                                                 ORDER BY proj_start)
              WHEN LEAD(proj_start,4) OVER(PARTITION BY empno
                                               ORDER BY proj_start)
                   BETWEEN proj_start AND proj_end
                   THEN LEAD(proj_id,4) OVER(PARTITION BY empno
                                                 ORDER BY proj_start)
         END AS is_overlap
    FROM emp_project
)
SELECT empno, ename,
       'project ' || is_overlap || ' overlaps project ' || proj_id AS msg
  FROM x
 WHERE is_overlap IS NOT NULL;
```
