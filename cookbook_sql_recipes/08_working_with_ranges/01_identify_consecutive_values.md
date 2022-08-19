# Identify consecutive values

we want to identify **consecutive** values in a column. Also known as the `Islands` problem.

This section, will look at methods for **identifying consecutive values** (Islands).

## Problem

```SQL
CREATE TABLE sequences
(
    value_of_interest INTEGER
);

INSERT INTO sequences
VALUES (1),(2),(3),(6),(7),(9),(11),(12),(20),(25);
```

|value_of_interest|
|:---------------:|
|                1|
|                2|
|                3|
|                6|
|                7|
|                9|
|               11|
|               12|
|               20|
|               25|


**Islands** - rows where a row value follows another in an unbroken succession.

```console
|value_of_interest|
|:---------------:|
|                1|
|                2|
|                3|
--------------------
|                6|
|                7|
--------------------
|                9|
--------------------
|               11|
|               12|
--------------------
|               20|
--------------------
|               25|
```

### Problem 1

Identify consecutive groups of values and `assign a consecutive sequence identifier`.

**Output**

|value_of_interest | sequence_id|
|:----------------:|:----------:|
|                1 |           1|
|                2 |           1|
|                3 |           1|
|                6 |           2|
|                7 |           2|
|                9 |           3|
|               11 |           4|
|               12 |           4|
|               20 |           5|
|               25 |           6|

### Problem 2

Identify where a `sequence starts` and `ends`.

|sequence_id | sequence_started | sequence_ended|
|:----------:|:----------------:|:-------------:|
|          1 |                1 |              3|
|          2 |                6 |              7|
|          3 |                9 |              9|
|          4 |               11 |             12|
|          5 |               20 |             20|
|          6 |               25 |             25|

### Problem 3

Returns sequences with more than a single value.

|sequence_id | sequence_started | sequence_ended|
|:----------:|:-----------------:|:-------------:|
|          1 |                1 |              3|
|          2 |                6 |              7|
|          4 |               11 |             12|

## Solution

**Problem 1**

```SQL
WITH seq_groups AS (
  SELECT value_of_interest,
         value_of_interest - DENSE_RANK() OVER(ORDER BY value_of_interest) AS sequence_identifier
    FROM sequences
)
SELECT value_of_interest,
       DENSE_RANK() OVER(ORDER BY sequence_identifier) AS sequence_id
  FROM seq_groups;
```

**Problem 2**

```SQL
WITH seq_groups AS (
  SELECT value_of_interest,
         value_of_interest - DENSE_RANK() OVER(ORDER BY value_of_interest) AS sequence_identifier
    FROM sequences
),
val_groups AS (
  SELECT value_of_interest,
         DENSE_RANK() OVER(ORDER BY sequence_identifier) AS sequence_id
    FROM seq_groups
)
SELECT sequence_id,
       MIN(value_of_interest) AS sequence_started,
       MAX(value_of_interest) AS sequence_ended
  FROM val_groups
 GROUP BY sequence_id
 ORDER BY sequence_id;
```

**Problem 3**

```SQL
WITH seq_groups AS (
  SELECT value_of_interest,
         value_of_interest - DENSE_RANK() OVER(ORDER BY value_of_interest) AS sequence_identifier
    FROM sequences
),
val_groups AS (
  SELECT value_of_interest,
         DENSE_RANK() OVER(ORDER BY sequence_identifier) AS sequence_id
    FROM seq_groups
)
SELECT sequence_id,
       MIN(value_of_interest) AS sequence_started,
       MAX(value_of_interest) AS sequence_ended
  FROM val_groups
 GROUP BY sequence_id
HAVING COUNT(*) > 1
 ORDER BY sequence_id;
```

## Discussion

To identify islands, there are two approaches.
1. Use a `sequence identifier` **to group values that are in sequence**.
2. Or identify where a `sequence starts` and `ends`.

Let's look at how to do both.

We're going to use the [DENSE_RANK](https://github.com/lpinzari/sql-psql-udy/blob/master/08_window_functions/08_dense_rank.md) function to help create an identifier to group values that are part of a sequence.

Begin by applying the `DENSE_RANK` function to the rows.

```SQL
SELECT value_of_interest,
       DENSE_RANK() OVER(ORDER BY value_of_interest) AS value_rank
  FROM sequences;
```

|value_of_interest | value_rank|
|:----------------:|:---------:|
|                1 |          1|
|                2 |          2|
|                3 |          3|
|                6 |          4|
|                7 |          5|
|                9 |          6|
|               11 |          7|
|               12 |          8|
|               20 |          9|
|               25 |         10|

Consecutive values in the `value_of_interst` column increments by one.

For example, the second row's value `2` is basically the result of a summation, the previous row's value `1` + **1**. Similarly, the value `3` is the result of `2`+ **1** and so on.

The values in the `value_rank` column are the result of the `DENSE_RANK` function applied to the `value_of_interest` column. These avalues are consecutive.

```SQL
SELECT value_of_interest,
       value_of_interest - DENSE_RANK() OVER(ORDER BY value_of_interest) AS sequence_identifier
  FROM sequences;
```

To produce the `group identifier`, we **subtract** the `result of DENSE_RANK` from the `row value`.

```console
value_of_interest | sequence_identifier
-------------------+---------------------
                1 |                   0
                2 |                   0
                3 |                   0
                ------------------------
                6 |                   2
                7 |                   2
                ------------------------
                9 |                   3
                ------------------------
               11 |                   4
               12 |                   4
               -------------------------
               20 |                  11
               -------------------------
               25 |                  15
```

As the sequence increases, the result of this calculation remains constant but then changes when a new sequence starts. We **use this constant to identify the islands**.

```SQL
WITH seq_groups AS (
  SELECT value_of_interest,
         value_of_interest - DENSE_RANK() OVER(ORDER BY value_of_interest) AS sequence_identifier
    FROM sequences
)
SELECT value_of_interest,
       DENSE_RANK() OVER(ORDER BY sequence_identifier) AS sequence_id
  FROM seq_groups;
```

|value_of_interest | sequence_id|
|:----------------:|:----------:|
|                1 |           1|
|                2 |           1|
|                3 |           1|
|                6 |           2|
|                7 |           2|
|                9 |           3|
|               11 |           4|
|               12 |           4|
|               20 |           5|
|               25 |           6|

### Problem 2

To find the sequence start and end, we subquery the result set and aggregate it by the sequence identifier.

```SQL
WITH seq_groups AS (
  SELECT value_of_interest,
         value_of_interest - DENSE_RANK() OVER(ORDER BY value_of_interest) AS sequence_identifier
    FROM sequences
),
val_groups AS (
  SELECT value_of_interest,
         DENSE_RANK() OVER(ORDER BY sequence_identifier) AS sequence_id
    FROM seq_groups
)
SELECT sequence_id,
       MIN(value_of_interest) AS sequence_started,
       MAX(value_of_interest) AS sequence_ended
  FROM val_groups
 GROUP BY sequence_id
 ORDER BY sequence_id;
```


If we were doing analysis, at this point, we have enough to summarize a sequence, e.g., `COUNT`, `AVG`, etc.

### Problem 3

```SQL
WITH seq_groups AS (
  SELECT value_of_interest,
         value_of_interest - DENSE_RANK() OVER(ORDER BY value_of_interest) AS sequence_identifier
    FROM sequences
),
val_groups AS (
  SELECT value_of_interest,
         DENSE_RANK() OVER(ORDER BY sequence_identifier) AS sequence_id
    FROM seq_groups
)
SELECT sequence_id,
       MIN(value_of_interest) AS sequence_started,
       MAX(value_of_interest) AS sequence_ended
  FROM val_groups
 GROUP BY sequence_id
HAVING COUNT(*) > 1
 ORDER BY sequence_id;
```

If you need to exclude sequences with only 1 row, include the HAVING clause filtering for row counts greater than 1.
