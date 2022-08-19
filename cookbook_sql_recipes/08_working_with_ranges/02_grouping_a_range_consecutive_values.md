# Locating a Range of Consecutive Values

You want to determine **which rows represent a range of consecutive projects**.

## Problem

Consider the following result set from view V, which contains data about a project and its start and end dates:


```SQL
CREATE TABLE v (
  proj_id INTEGER PRIMARY KEY,
  proj_start DATE,
  proj_end DATE
);
```

```console
cookbook=# \d v
                   Table "public.v"
   Column   |  Type   | Collation | Nullable | Default
------------+---------+-----------+----------+---------
 proj_id    | integer |           | not null |
 proj_start | date    |           |          |
 proj_end   | date    |           |          |
Indexes:
    "v_pkey" PRIMARY KEY, btree (proj_id)
```


```SQL
INSERT INTO v
       (proj_id, proj_start, proj_end)
VALUES (1, '2020-01-01','2020-01-02'),
       (2, '2020-01-02','2020-01-03'),
       (3, '2020-01-03','2020-01-04'),
       (4, '2020-01-04','2020-01-05'),
       (5, '2020-01-06','2020-01-07'),
       (6, '2020-01-16','2020-01-17'),
       (7, '2020-01-17','2020-01-18'),
       (8, '2020-01-18','2020-01-19'),
       (9, '2020-01-19','2020-01-20'),
       (10, '2020-01-21','2020-01-22'),
       (11, '2020-01-26','2020-01-27'),
       (12, '2020-01-27','2020-01-28'),
       (13, '2020-01-28','2020-01-29'),
       (14, '2020-01-29','2020-01-30');
```


|proj_id | proj_start |  proj_end|
|:-------:|:---------:|:---------:|
|      1 | 2020-01-01 | 2020-01-02|
|      2 | 2020-01-02 | 2020-01-03|
|      3 | 2020-01-03 | 2020-01-04|
|      4 | 2020-01-04 | 2020-01-05|
|      5 | 2020-01-06 | 2020-01-07|
|      6 | 2020-01-16 | 2020-01-17|
|      7 | 2020-01-17 | 2020-01-18|
|      8 | 2020-01-18 | 2020-01-19|
|      9 | 2020-01-19 | 2020-01-20|
|     10 | 2020-01-21 | 2020-01-22|
|     11 | 2020-01-26 | 2020-01-27|
|     12 | 2020-01-27 | 2020-01-28|
|     13 | 2020-01-28 | 2020-01-29|
|     14 | 2020-01-29 | 2020-01-30|


```console
|proj_id | proj_start |  proj_end|
|;-------:|:---------:|:----------:|
|      1 | 2020-01-01 | 2020-01-02 |
|                          |       |
|               +----------+       |
|               |                  |
|      2 | 2020-01-02 | 2020-01-03 |
|                          |       |
|               +----------+       |
|               |                  |
|      3 | 2020-01-03 | 2020-01-04 |
|                          |       |
|               +----------+       |
|               |                  |
|      4 | 2020-01-04 | 2020-01-05 |
------------------------------------
|      5 | 2020-01-06 | 2020-01-07 |
------------------------------------
|      6 | 2020-01-16 | 2020-01-17 |
                            |      |
                 +----------+      |
                 |                 |
|      7 | 2020-01-17 | 2020-01-18 |
                            |      |
                 +----------+      |
                 |                 |
|      8 | 2020-01-18 | 2020-01-19 |
                            |      |
                 +----------+      |
                 |                 |
|      9 | 2020-01-19 | 2020-01-20 |
------------------------------------
|     10 | 2020-01-21 | 2020-01-22 |
------------------------------------
|     11 | 2020-01-26 | 2020-01-27 |
                            |      |
                 +----------+      |
                 |                 |
|     12 | 2020-01-27 | 2020-01-28 |
                            |      |
                 +----------+      |
                 |                 |
|     13 | 2020-01-28 | 2020-01-29 |
                            |      |
                 +----------+      |
                 |                 |
|     14 | 2020-01-29 | 2020-01-30 |
```

Excluding the first row, each row’s `PROJ_START` `should equal` the `PROJ_END` of the **row before** it (“before” is defined as `PROJ_ID – 1` for the **current row**).


```console
|proj_id | proj_start |  proj_end|
|;-------:|:---------:|:----------:|
|      1 | 2020-01-01 | 2020-01-02 |
|                          |       |
|               +----------+       |
|               |                  |
|      2 | 2020-01-02 | 2020-01-03 |
|                          |       |
|               +----------+       |
|               |                  |
|      3 | 2020-01-03 | 2020-01-04 |
|                          |       |
|               +----------+       |
|               |                  |
|      4 | 2020-01-04 | 2020-01-05 |
------------------------------------
|      5 | 2020-01-06 | 2020-01-07 |
------------------------------------
```


Examining the first five rows from view V, `PROJ_IDs` **1** through **3** are part of the same “group” as each `PROJ_END` equals the `PROJ_START` of the row after it.

Despite the fact that `PROJ_ID` **4** does not have a consecutive value following it, it is the **last of a range of consecutive values, and thus it is included in the first group**.

Because you want to find the range of dates for consecutive projects, you would like to return all rows where the current `PROJ_END` equals the next row’s `PROJ_START`. If the first five rows comprised the entire result set, you would like to return only the first three rows. The final result set (using all 14 rows from view V) should be:

```console
ORDER BY proj_id
2020-01
-----------------------------------------------------------------------
  1   2   3   4   5   6   7   ..16   17   18   19   20   21  22   
-----------------------------------------------------------------------
1 *---*             |
2     *---*         |
3         *---*     |
4             *---* |
--------------------+--------+             
5                   | *----* |
--------------------+--------+-+-----------------------+
6                              | *----*                |
7                              |      *----*           |
8                              |           *----*      |
9                              |                *----* |
                               +-----------------------+-------+
10                                                     | *----* |
                                                       +--------+
                                                                 26  27  28  29  30
-----------------------------------------------------------------------------------
11                                                              |*---*            |
12                                                              |    *--*         |
13                                                              |       *---*     |
14                                                              |           *---* |
----------------------------------------------------------------------------------+
```
:warning:

**The projects are not overlapping!**. The proj_id is a progressive number indicating the succession of not overlapping projercts (i.e, the starting date of the project is not between the startinmg date and ending date of any other project). A project is consecutive to another project if the starting date is equal to the ending date of the previous project.

|proj_group | proj_started | proj_ended |   proj_ids|
|:---------:|:------------:|:----------:|:---------:|
|         1 | 2020-01-01   | 2020-01-05 | {1,2,3,4}|
|         2 | 2020-01-06   | 2020-01-07 | {5}|
|         3 | 2020-01-16   | 2020-01-20 | {6,7,8,9}|
|         4 | 2020-01-21   | 2020-01-22 | {10}|
|         5 | 2020-01-26   | 2020-01-30 | {11,12,13,14}|


## Solution

```SQL
WITH temp AS (
  SELECT proj_id,
         proj_start,
         proj_end,
         LEAD(proj_start) OVER (ORDER BY proj_id) AS next_proj_start,
         LAG(proj_end) OVER (ORDER BY proj_id) AS prev_proj_end
    FROM v
),
temp2 AS (
  SELECT proj_id, proj_start, proj_end
    FROM temp
   WHERE proj_start = prev_proj_end OR proj_end = next_proj_start
   ORDER BY proj_id
),
seq_groups AS (
  SELECT proj_id, proj_start, proj_end,
         proj_id - DENSE_RANK() OVER(ORDER BY proj_id) AS sequence_identifier
    FROM temp2
),
val_groups AS (
  SELECT proj_id, proj_start, proj_end,
         DENSE_RANK() OVER(ORDER BY sequence_identifier)*2 AS sequence_id
    FROM seq_groups
),
val_groups2 AS (
  SELECT v.proj_id, v.proj_start, v.proj_end, vg.sequence_id
    FROM v
    LEFT JOIN val_groups AS vg
    ON v.proj_id = vg.proj_id
),
val_groups3 AS (
  SELECT proj_id, proj_start, proj_end, sequence_id,
         LAG(sequence_id) OVER(ORDER BY proj_id) AS prev_seq_id
    FROM val_groups2
),
val_groups4 AS (
  SELECT proj_id, proj_start, proj_end,
         CASE WHEN sequence_id IS NULL THEN prev_seq_id ELSE sequence_id - 1
         END AS sequence_id
    FROM val_groups3
)
SELECT sequence_id AS proj_group,
       MIN(proj_start) AS proj_started,
       MAX(proj_end) AS proj_ended,
       ARRAY_AGG(proj_id) AS proj_ids
  FROM val_groups4
 GROUP BY sequence_id
 ORDER BY sequence_id;
```

- **Solution 2**:

```SQL
WITH temp1 AS (
  SELECT proj_id, proj_start, proj_end,
         CASE WHEN  LAG(proj_end) OVER (ORDER BY proj_id) = proj_start
              THEN 0 ELSE 1
         END AS flag
    FROM v
),
temp2 AS (
  SELECT proj_id, proj_start, proj_end,
         SUM(flag) OVER (ORDER BY proj_id) AS proj_group
    FROM temp1
)
SELECT proj_group,
       MIN(proj_start) AS proj_started,
       MAX(proj_end) AS proj_ended,
       ARRAY_AGG(proj_id) AS proj_ids
  FROM temp2
 GROUP BY proj_group
 ORDER BY proj_group;
```

## Discussion

- **Solution 1**:

This problem is a bit more involved than its predecessor. First, you must identify what **the ranges are**.

A range of rows is defined by the values for `PROJ_START` and `PROJ_END`. For a row to be considered “**consecutive**” or part of a group, its `PROJ_START` value must equal the `PROJ_END` value of the **row before it**.

In the case where a row’s `PROJ_START` value **does not equal** the `prior row’s` `PROJ_END` value and its `PROJ_END` value **does not equal** the `next row’s` `PROJ_START` value, **this is an instance of a single row group**.

Once you have **identify the ranges**, you need to be able to **group the rows in these ranges together** (`into groups`) and return only their `start` and `end` points.


```SQL
SELECT proj_id,
       proj_start,
       proj_end,
       LEAD(proj_start) OVER (ORDER BY proj_id) AS next_proj_start
  FROM v;
```

|proj_id | proj_start |  proj_end  | next_proj_start|
|:------:|:----------:|:----------:|:--------------:|
|      1 | 2020-01-01 | 2020-01-02 | 2020-01-02|
|      2 | 2020-01-02 | 2020-01-03 | 2020-01-03|
|      3 | 2020-01-03 | 2020-01-04 | 2020-01-04|
|      4 | 2020-01-04 | 2020-01-05 | 2020-01-06|
|      5 | 2020-01-06 | 2020-01-07 | 2020-01-16|
|      6 | 2020-01-16 | 2020-01-17 | 2020-01-17|
|      7 | 2020-01-17 | 2020-01-18 | 2020-01-18|
|      8 | 2020-01-18 | 2020-01-19 | 2020-01-19|
|      9 | 2020-01-19 | 2020-01-20 | 2020-01-21|
|     10 | 2020-01-21 | 2020-01-22 | 2020-01-26|
|     11 | 2020-01-26 | 2020-01-27 | 2020-01-27|
|     12 | 2020-01-27 | 2020-01-28 | 2020-01-28|
|     13 | 2020-01-28 | 2020-01-29 | 2020-01-29|
|     14 | 2020-01-29 | 2020-01-30 ||

```SQL
WITH temp AS (
  SELECT proj_id,
         proj_start,
         proj_end,
         LEAD(proj_start) OVER (ORDER BY proj_id) AS next_proj_start,
         LAG(proj_end) OVER (ORDER BY proj_id) AS prev_proj_end
    FROM v
)
SELECT *
  FROM temp
 ORDER BY proj_id;
```


```console
proj_id | proj_start |  proj_end  | next_proj_start | prev_proj_end
---------+------------+------------+-----------------+---------------
      1 | 2020-01-01 | 2020-01-02 | 2020-01-02      |
      2 | 2020-01-02 | 2020-01-03 | 2020-01-03      | 2020-01-02
      3 | 2020-01-03 | 2020-01-04 | 2020-01-04      | 2020-01-03
      4 | 2020-01-04 | 2020-01-05 | 2020-01-06      | 2020-01-04
      5 | 2020-01-06 | 2020-01-07 | 2020-01-16      | 2020-01-05
      6 | 2020-01-16 | 2020-01-17 | 2020-01-17      | 2020-01-07
      7 | 2020-01-17 | 2020-01-18 | 2020-01-18      | 2020-01-17
      8 | 2020-01-18 | 2020-01-19 | 2020-01-19      | 2020-01-18
      9 | 2020-01-19 | 2020-01-20 | 2020-01-21      | 2020-01-19
     10 | 2020-01-21 | 2020-01-22 | 2020-01-26      | 2020-01-20
     11 | 2020-01-26 | 2020-01-27 | 2020-01-27      | 2020-01-22
     12 | 2020-01-27 | 2020-01-28 | 2020-01-28      | 2020-01-27
     13 | 2020-01-28 | 2020-01-29 | 2020-01-29      | 2020-01-28
     14 | 2020-01-29 | 2020-01-30 |                 | 2020-01-29
```

```SQL
WITH temp AS (
  SELECT proj_id,
         proj_start,
         proj_end,
         LEAD(proj_start) OVER (ORDER BY proj_id) AS next_proj_start,
         LAG(proj_end) OVER (ORDER BY proj_id) AS prev_proj_end
    FROM v
)
SELECT proj_id, proj_start, proj_end
  FROM temp
 WHERE proj_start = prev_proj_end OR proj_end = next_proj_start
 ORDER BY proj_id;
```

|proj_id | proj_start |  proj_end|
|:------:|:----------:|:---------:|
|      1 | 2020-01-01 | 2020-01-02|
|      2 | 2020-01-02 | 2020-01-03|
|      3 | 2020-01-03 | 2020-01-04|
|      4 | 2020-01-04 | 2020-01-05|
|      6 | 2020-01-16 | 2020-01-17|
|      7 | 2020-01-17 | 2020-01-18|
|      8 | 2020-01-18 | 2020-01-19|
|      9 | 2020-01-19 | 2020-01-20|
|     11 | 2020-01-26 | 2020-01-27|
|     12 | 2020-01-27 | 2020-01-28|
|     13 | 2020-01-28 | 2020-01-29|
|     14 | 2020-01-29 | 2020-01-30|

Now that you’ve located the ranges of consecutive values, you want to find just their start and end points. Unlike the prior recipe, if a row is not part of a set of consecutive values, you still want to return it.

```SQL
WITH temp AS (
  SELECT proj_id,
         proj_start,
         proj_end,
         LEAD(proj_start) OVER (ORDER BY proj_id) AS next_proj_start,
         LAG(proj_end) OVER (ORDER BY proj_id) AS prev_proj_end
    FROM v
),
temp2 AS (
  SELECT proj_id, proj_start, proj_end
    FROM temp
   WHERE proj_start = prev_proj_end OR proj_end = next_proj_start
   ORDER BY proj_id
),
seq_groups AS (
  SELECT proj_id, proj_start, proj_end,
         proj_id - DENSE_RANK() OVER(ORDER BY proj_id) AS sequence_identifier
    FROM temp2
),
val_groups AS (
  SELECT proj_id, proj_start, proj_end,
         DENSE_RANK() OVER(ORDER BY sequence_identifier)*2 AS sequence_id
    FROM seq_groups
)
SELECT *
  FROM val_groups
 ORDER BY sequence_id;
```

|proj_id | proj_start |  proj_end  | sequence_id|
|:------:|:----------:|:----------:|:-----------:|
|      1 | 2020-01-01 | 2020-01-02 |           2|
|      2 | 2020-01-02 | 2020-01-03 |           2|
|      3 | 2020-01-03 | 2020-01-04 |           2|
|      4 | 2020-01-04 | 2020-01-05 |           2|
|      6 | 2020-01-16 | 2020-01-17 |           4|
|      7 | 2020-01-17 | 2020-01-18 |           4|
|      8 | 2020-01-18 | 2020-01-19 |           4|
|      9 | 2020-01-19 | 2020-01-20 |           4|
|     11 | 2020-01-26 | 2020-01-27 |           6|
|     12 | 2020-01-27 | 2020-01-28 |           6|
|     13 | 2020-01-28 | 2020-01-29 |           6|
|     14 | 2020-01-29 | 2020-01-30 |           6|

```SQL
WITH temp AS (
  SELECT proj_id,
         proj_start,
         proj_end,
         LEAD(proj_start) OVER (ORDER BY proj_id) AS next_proj_start,
         LAG(proj_end) OVER (ORDER BY proj_id) AS prev_proj_end
    FROM v
),
temp2 AS (
  SELECT proj_id, proj_start, proj_end
    FROM temp
   WHERE proj_start = prev_proj_end OR proj_end = next_proj_start
   ORDER BY proj_id
),
seq_groups AS (
  SELECT proj_id, proj_start, proj_end,
         proj_id - DENSE_RANK() OVER(ORDER BY proj_id) AS sequence_identifier
    FROM temp2
),
val_groups AS (
  SELECT proj_id, proj_start, proj_end,
         DENSE_RANK() OVER(ORDER BY sequence_identifier)*2 AS sequence_id
    FROM seq_groups
),
val_groups2 AS (
  SELECT v.proj_id, v.proj_start, v.proj_end, vg.sequence_id
    FROM v
    LEFT JOIN val_groups AS vg
    ON v.proj_id = vg.proj_id
)
SELECT proj_id, proj_start, proj_end, sequence_id,
       LAG(sequence_id) OVER(ORDER BY proj_id) AS prev_seq_id
  FROM val_groups2
 ORDER BY proj_id;
```

```console
proj_id | proj_start |  proj_end  | sequence_id | prev_seq_id
---------+------------+------------+-------------+-------------
      1 | 2020-01-01 | 2020-01-02 |           2 |
      2 | 2020-01-02 | 2020-01-03 |           2 |           2
      3 | 2020-01-03 | 2020-01-04 |           2 |           2
      4 | 2020-01-04 | 2020-01-05 |           2 |           2
      5 | 2020-01-06 | 2020-01-07 |             |           2
      6 | 2020-01-16 | 2020-01-17 |           4 |
      7 | 2020-01-17 | 2020-01-18 |           4 |           4
      8 | 2020-01-18 | 2020-01-19 |           4 |           4
      9 | 2020-01-19 | 2020-01-20 |           4 |           4
     10 | 2020-01-21 | 2020-01-22 |             |           4
     11 | 2020-01-26 | 2020-01-27 |           6 |
     12 | 2020-01-27 | 2020-01-28 |           6 |           6
     13 | 2020-01-28 | 2020-01-29 |           6 |           6
     14 | 2020-01-29 | 2020-01-30 |           6 |           6
```

```SQL
WITH temp AS (
  SELECT proj_id,
         proj_start,
         proj_end,
         LEAD(proj_start) OVER (ORDER BY proj_id) AS next_proj_start,
         LAG(proj_end) OVER (ORDER BY proj_id) AS prev_proj_end
    FROM v
),
temp2 AS (
  SELECT proj_id, proj_start, proj_end
    FROM temp
   WHERE proj_start = prev_proj_end OR proj_end = next_proj_start
   ORDER BY proj_id
),
seq_groups AS (
  SELECT proj_id, proj_start, proj_end,
         proj_id - DENSE_RANK() OVER(ORDER BY proj_id) AS sequence_identifier
    FROM temp2
),
val_groups AS (
  SELECT proj_id, proj_start, proj_end,
         DENSE_RANK() OVER(ORDER BY sequence_identifier)*2 AS sequence_id
    FROM seq_groups
),
val_groups2 AS (
  SELECT v.proj_id, v.proj_start, v.proj_end, vg.sequence_id
    FROM v
    LEFT JOIN val_groups AS vg
    ON v.proj_id = vg.proj_id
),
val_groups3 AS (
  SELECT proj_id, proj_start, proj_end, sequence_id,
         LAG(sequence_id) OVER(ORDER BY proj_id) AS prev_seq_id
    FROM val_groups2
)
SELECT proj_id, proj_start, proj_end,
       CASE WHEN sequence_id IS NULL THEN prev_seq_id ELSE sequence_id - 1
       END AS sequence_id
  FROM val_groups3;
```


|proj_id | proj_start |  proj_end  | sequence_id|
|:------:|:----------:|:----------:|:-----------:|
|      1 | 2020-01-01 | 2020-01-02 |           1|
|      2 | 2020-01-02 | 2020-01-03 |           1|
|      3 | 2020-01-03 | 2020-01-04 |           1|
|      4 | 2020-01-04 | 2020-01-05 |           1|
|      5 | 2020-01-06 | 2020-01-07 |           2|
|      6 | 2020-01-16 | 2020-01-17 |           3|
|      7 | 2020-01-17 | 2020-01-18 |           3|
|      8 | 2020-01-18 | 2020-01-19 |           3|
|      9 | 2020-01-19 | 2020-01-20 |           3|
|     10 | 2020-01-21 | 2020-01-22 |           4|
|     11 | 2020-01-26 | 2020-01-27 |           5|
|     12 | 2020-01-27 | 2020-01-28 |           5|
|     13 | 2020-01-28 | 2020-01-29 |           5|
|     14 | 2020-01-29 | 2020-01-30 |           5|


```SQL
WITH temp AS (
  SELECT proj_id,
         proj_start,
         proj_end,
         LEAD(proj_start) OVER (ORDER BY proj_id) AS next_proj_start,
         LAG(proj_end) OVER (ORDER BY proj_id) AS prev_proj_end
    FROM v
),
temp2 AS (
  SELECT proj_id, proj_start, proj_end
    FROM temp
   WHERE proj_start = prev_proj_end OR proj_end = next_proj_start
   ORDER BY proj_id
),
seq_groups AS (
  SELECT proj_id, proj_start, proj_end,
         proj_id - DENSE_RANK() OVER(ORDER BY proj_id) AS sequence_identifier
    FROM temp2
),
val_groups AS (
  SELECT proj_id, proj_start, proj_end,
         DENSE_RANK() OVER(ORDER BY sequence_identifier)*2 AS sequence_id
    FROM seq_groups
),
val_groups2 AS (
  SELECT v.proj_id, v.proj_start, v.proj_end, vg.sequence_id
    FROM v
    LEFT JOIN val_groups AS vg
    ON v.proj_id = vg.proj_id
),
val_groups3 AS (
  SELECT proj_id, proj_start, proj_end, sequence_id,
         LAG(sequence_id) OVER(ORDER BY proj_id) AS prev_seq_id
    FROM val_groups2
),
val_groups4 AS (
  SELECT proj_id, proj_start, proj_end,
         CASE WHEN sequence_id IS NULL THEN prev_seq_id ELSE sequence_id - 1
         END AS sequence_id
    FROM val_groups3
)
SELECT sequence_id AS proj_group,
       MIN(proj_start) AS proj_started,
       MAX(proj_end) AS proj_ended,
       ARRAY_AGG(proj_id) AS proj_ids
  FROM val_groups4
 GROUP BY sequence_id
 ORDER BY sequence_id;
```

- **Solution 2**:


The most straightforward approach for this problem is to use the `LAG OVER` window function. Use `LAG OVER` to determine whether each prior row’s `PROJ_END` equals the current row’s `PROJ_START` to help place the rows into groups. Once they are grouped, use the aggregate functions `MIN` and `MAX` to find their `start` and `end` points:

```SQL
SELECT proj_id, proj_start, proj_end,
       CASE WHEN  LAG(proj_end) OVER (ORDER BY proj_id) = proj_start
            THEN 0 ELSE 1
       END AS flag
  FROM v;
```

 You can exam‐ ine each prior row’s PROJ_END value without a self-join, without a scalar subquery, and without a view. The results of the LAG OVER function :

|proj_id | proj_start |  proj_end  | flag|
|:------:|:----------:|:----------:|:---:|
|      1 | 2020-01-01 | 2020-01-02 |    1|
|      2 | 2020-01-02 | 2020-01-03 |    0|
|      3 | 2020-01-03 | 2020-01-04 |    0|
|      4 | 2020-01-04 | 2020-01-05 |    0|
|      5 | 2020-01-06 | 2020-01-07 |    1|
|      6 | 2020-01-16 | 2020-01-17 |    1|
|      7 | 2020-01-17 | 2020-01-18 |    0|
|      8 | 2020-01-18 | 2020-01-19 |    0|
|      9 | 2020-01-19 | 2020-01-20 |    0|
|     10 | 2020-01-21 | 2020-01-22 |    1|
|     11 | 2020-01-26 | 2020-01-27 |    1|
|     12 | 2020-01-27 | 2020-01-28 |    0|
|     13 | 2020-01-28 | 2020-01-29 |    0|
|     14 | 2020-01-29 | 2020-01-30 |    0|

The `CASE` expression simply compares the value returned by `LAG OVER` to the current row’s `PROJ_START` value; if they are the same, return `0`, else return `1`.

```SQL
WITH temp1 AS (
  SELECT proj_id, proj_start, proj_end,
         CASE WHEN  LAG(proj_end) OVER (ORDER BY proj_id) = proj_start
              THEN 0 ELSE 1
         END AS flag
    FROM v
)
SELECT proj_id, proj_start, proj_end,
       SUM(flag) OVER (ORDER BY proj_id) AS prog_group
  FROM temp1;
```

The next step is to create a **running total on** the `zeros` and `ones` returned by the `CASE` expression **to put each row into a group**. The results of the running total are shown here:

|proj_id | proj_start |  proj_end  | prog_group|
|:-------:|:---------:|:----------:|:----------:|
|      1 | 2020-01-01 | 2020-01-02 |          1|
|      2 | 2020-01-02 | 2020-01-03 |          1|
|      3 | 2020-01-03 | 2020-01-04 |          1|
|      4 | 2020-01-04 | 2020-01-05 |          1|
|      5 | 2020-01-06 | 2020-01-07 |          2|
|      6 | 2020-01-16 | 2020-01-17 |          3|
|      7 | 2020-01-17 | 2020-01-18 |          3|
|      8 | 2020-01-18 | 2020-01-19 |          3|
|      9 | 2020-01-19 | 2020-01-20 |          3|
|     10 | 2020-01-21 | 2020-01-22 |          4|
|     11 | 2020-01-26 | 2020-01-27 |          5|
|     12 | 2020-01-27 | 2020-01-28 |          5|
|     13 | 2020-01-28 | 2020-01-29 |          5|
|     14 | 2020-01-29 | 2020-01-30 |          5|


Now that each row has been placed into a group, simply use the aggregate functions `MIN` and `MAX` on `PROJ_START` and `PROJ_END`, respectively, and group by the values created in the `PROJ_GRPOUP` running total column.

```SQL
WITH temp1 AS (
  SELECT proj_id, proj_start, proj_end,
         CASE WHEN  LAG(proj_end) OVER (ORDER BY proj_id) = proj_start
              THEN 0 ELSE 1
         END AS flag
    FROM v
),
temp2 AS (
  SELECT proj_id, proj_start, proj_end,
         SUM(flag) OVER (ORDER BY proj_id) AS proj_group
    FROM temp1
)
SELECT proj_group,
       MIN(proj_start) AS proj_started,
       MAX(proj_end) AS proj_ended,
       ARRAY_AGG(proj_id) AS proj_ids
  FROM temp2
 GROUP BY proj_group
 ORDER BY proj_group;
```
