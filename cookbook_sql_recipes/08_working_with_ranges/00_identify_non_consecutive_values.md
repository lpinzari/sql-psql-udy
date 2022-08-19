# Identify non-consecutive values

we want to identify **non-consecutive** values in a column. Also known as the `Gaps` problem.

This section, will look at methods for **identifying non-consecutive values** (Gaps).


## Problem 1:

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


**Gaps** - rows where a row `value does not sequentially follow another...`:

```console
|value_of_interest|
|:---------------:|
|                1|
|                2|
|                3|
---------------------   gap_starts  gap_ends
                 4           4        5
                 5   
---------------------
|                6|
|                7|
---------------------   gap_starts  gap_ends
                 8           8        8
---------------------
|                9|
---------------------   gap_starts  gap_ends
                10          10       10
---------------------
|               11|
|               12|
---------------------   gap_starts  gap_ends
                13          13        19
                14
                ..
                19
---------------------
|               20|
---------------------   gap_starts  gap_ends
                21          21        24
                22
                ..
                24
---------------------                
|               25|
```

**Output**

|gap_starts | gap_ends|
|:---------:|:-------:|
|         4 |        5|
|         8 |        8|
|        10 |       10|
|        13 |       19|
|        21 |       24|


## Problem 2

What if the sequences are `DATE` or `DATETIME`?

```SQL
CREATE TABLE date_sequences (
  date_of_interest DATE
);

INSERT INTO date_sequences
VALUES ('2021-01-01'),
       ('2021-01-02'),
       ('2021-01-03'),
       ('2021-01-06'),
       ('2021-01-07'),
       ('2021-01-09'),
       ('2021-01-11'),
       ('2021-01-12'),
       ('2021-01-20'),
       ('2021-01-25');
```

|date_of_interest|
|:--------------:|
|2021-01-01|
|2021-01-02|
|2021-01-03|
|2021-01-06|
|2021-01-07|
|2021-01-09|
|2021-01-11|
|2021-01-12|
|2021-01-20|
|2021-01-25|

**Gaps** - rows where a row `value does not sequentially follow another...`:

```console
|date_of_interest|
|:--------------:|
|2021-01-01|
|2021-01-02|
|2021-01-03|
---------------------   gap_starts  gap_ends
        2021-01-04      2021-01-04  2021-01-05
        2021-01-05   
---------------------
|2021-01-06|
|2021-01-07|
---------------------   gap_starts  gap_ends
        2021-01-08      2021-01-08  2021-01-08   
---------------------
|2021-01-09|
---------------------   gap_starts  gap_ends
        2021-01-10      2021-01-10  2021-01-10
---------------------
|2021-01-11|
|2021-01-12|
---------------------   gap_starts  gap_ends
        2021-01-13      2021-01-13  2021-01-19
        2021-01-14
        ..........
        2021-01-19   
---------------------
|2021-01-20|
---------------------   gap_starts  gap_ends
        2021-01-21      2021-01-21  2021-01-24
        2021-01-22
        ..........
        2021-01-24   
---------------------
|2021-01-25|
```

**Output**

|gap_starts |  gap_ends|
|:---------:|:----------:|
|2021-01-04 | 2021-01-05|
|2021-01-08 | 2021-01-08|
|2021-01-10 | 2021-01-10|
|2021-01-13 | 2021-01-19|
|2021-01-21 | 2021-01-24|


## Solution

To identify Gaps, we need to determine **where** `a sequence ends`, and **another** `begins`. In between these points are where a gap starts and ends.

In general, each approach compares the current row with the next row to determine if it's the next value in the sequence. If it isn't, then we've found a gap.

### Problem 1

- **Solution 1**

```SQL
WITH curr_next AS (
  SELECT value_of_interest,
         LEAD(value_of_interest,1,value_of_interest) OVER(ORDER BY value_of_interest) AS next_row_value
    FROM sequences
)
SELECT value_of_interest + 1 AS gap_starts,
       next_row_value - 1 AS gap_ends
  FROM curr_next
 WHERE next_row_value - value_of_interest > 1;
```

- **Solution 2**

```SQL
WITH current_row AS (
 SELECT num_sequence.value_of_interest,
        ROW_NUMBER() OVER(ORDER BY num_sequence.value_of_interest) as row_num
   FROM sequences as num_sequence
),
curr_next_value AS (
SELECT cr.value_of_interest AS value_of_interest,
       nr.value_of_interest AS next_row_value_of_interest
  FROM current_row AS cr
  JOIN current_row AS nr
    ON nr.row_num = cr.row_num + 1
)
SELECT value_of_interest + 1 AS gap_starts,
       next_row_value_of_interest - 1 AS gap_ends
  FROM curr_next_value
 WHERE next_row_value_of_interest - value_of_interest > 1;
```

### Problem 2

- **Solution**

```SQL
WITH curr_next_date AS (
  SELECT date_of_interest,
         LEAD(date_of_interest,1,date_of_interest) OVER(ORDER BY date_of_interest) AS next_row_date_value
    FROM date_sequences
)
SELECT date_of_interest + 1 AS gap_starts,
       next_row_date_value - 1 AS gap_ends
  FROM curr_next_date
 WHERE next_row_date_value - date_of_interest > 1;
```

## Discussion

This approach uses the `LEAD` window function. The `LEAD` function lets you access values from rows that follow the current row.


```SQL
SELECT value_of_interest,
       LEAD(value_of_interest,1,value_of_interest) OVER(ORDER BY value_of_interest) AS next_row_value
  FROM sequences;
```


First, we apply the LEAD function to generate a result set of the current row value and next row value.

- `LEAD(value_of_interest, 1, value_of_interest)`.

The first parameter indicates the column, the second value indicates how many rows we should consider to the next value in the table. In this case 1 indicates the next row. Finally, the third argument is the default value in case there is no next row.

|value_of_interest | next_row_value|
|:----------------:|:--------------:|
|                1 |              2|
|                2 |              3|
|                3 |              6|
|                6 |              7|
|                7 |              9|
|                9 |             11|
|               11 |             12|
|               12 |             20|
|               20 |             25|
|               25 |             25|

To identify gaps, we `subtract the current row value from the next row value`. For rows where a sequence ends, **the difference will be greater than 1**.

```SQL
WITH curr_next AS (
  SELECT value_of_interest,
         LEAD(value_of_interest,1,value_of_interest) OVER(ORDER BY value_of_interest) AS next_row_value
    FROM sequences
)
SELECT value_of_interest,
       next_row_value,
       next_row_value - value_of_interest AS sequence_ind
  FROM curr_next;
```

|value_of_interest | next_row_value | sequence_ind|
|:----------------:|:--------------:|:-----------:|
|                1 |              2 |            1|
|                2 |              3 |            1|
|            **3** |          **6** | **3**|
|                6 |              7 |            1|
|            **7** |          **9** | **2**|
|            **9** |         **11** | **2**|
|               11 |             12 |            1|
|           **12** |         **20** | **8**|
|           **20** |         **25** | **5**|
|               25 |             25 |            0|

```console
value_of_interest | next_row_value | sequence_ind
-------------------+----------------+--------------
                1 |              2 |            1
                2 |              3 |            1
            ->  3 |              6 |            3
                ----------------------------------
                6 |              7 |            1
            ->  7 |              9 |            2
                ----------------------------------
            ->  9 |             11 |            2
                ---------------------------------
               11 |             12 |            1
            -> 12 |             20 |            8
               -----------------------------------
            -> 20 |             25 |            5
               -----------------------------------
               25 |             25 |            0
```

To isolate the sequence end and starts, we `filter` for the rows where the **difference is greater than 1**.

```SQL
WITH curr_next AS (
  SELECT value_of_interest,
         LEAD(value_of_interest,1,value_of_interest) OVER(ORDER BY value_of_interest) AS next_row_value
    FROM sequences
)
SELECT value_of_interest,
       next_row_value
  FROM curr_next
 WHERE next_row_value - value_of_interest > 1;
```

|value_of_interest | next_row_value|
|:----------------:|:-------------:|
|                3 |              6|
|                7 |              9|
|                9 |             11|
|               12 |             20|
|               20 |             25|

To arrive at the gaps, **we add 1** to the `sequence end` and **subtract 1** from the `sequence start`.

```SQL
WITH curr_next AS (
  SELECT value_of_interest,
         LEAD(value_of_interest,1,value_of_interest) OVER(ORDER BY value_of_interest) AS next_row_value
    FROM sequences
)
SELECT value_of_interest + 1 AS gap_starts,
       next_row_value - 1 AS gap_ends
  FROM curr_next
 WHERE next_row_value - value_of_interest > 1;
```

|gap_starts | gap_ends|
|:---------:|:-------:|
|         4 |        5|
|         8 |        8|
|        10 |       10|
|        13 |       19|
|        21 |       24|

- **Solution 2**

This approach leverages a **Common Table Expression (CTE)** `joined to itself` to create a result set of the current row and next row. Like the above approach, `we compare the current row and the next row to identify a gap`.

```SQL
WITH current_row AS (
 SELECT num_sequence.value_of_interest,
        ROW_NUMBER() OVER(ORDER BY num_sequence.value_of_interest) as row_num
   FROM sequences as num_sequence
)
SELECT *
  FROM current_row;
```

|value_of_interest | row_num|
|:----------------:|:------:|
|                1 |       1|
|                2 |       2|
|                3 |       3|
|                6 |       4|
|                7 |       5|
|                9 |       6|
|               11 |       7|
|               12 |       8|
|               20 |       9|
|               25 |      10|

To get the current row and the next row, we `join the CTE to itself` based `on` **the row number plus 1**.

```SQL
WITH current_row AS (
 SELECT num_sequence.value_of_interest,
        ROW_NUMBER() OVER(ORDER BY num_sequence.value_of_interest) as row_num
   FROM sequences as num_sequence
)
SELECT cr.value_of_interest AS value_of_interest,
       nr.value_of_interest AS next_row_value_of_interest
  FROM current_row AS cr
  JOIN current_row AS nr
    ON nr.row_num = cr.row_num + 1;
```

|value_of_interest | next_row_value_of_interest|
|:-----------------:|:-------------------------:|
|                1 |                          2|
|                2 |                          3|
|                3 |                          6|
|                6 |                          7|
|                7 |                          9|
|                9 |                         11|
|               11 |                         12|
|               12 |                         20|
|               20 |                         25|

To identify where a sequence ended, we subtract the current row from the next row. When the sequence ends, the result of the subtraction is **greater than 1**.

As we did in the previous solution, we isolate the sequence ends and starts by placing the subtraction in the `WHERE` clause.

```SQL
WITH current_row AS (
 SELECT num_sequence.value_of_interest,
        ROW_NUMBER() OVER(ORDER BY num_sequence.value_of_interest) as row_num
   FROM sequences as num_sequence
),
curr_next_value AS (
SELECT cr.value_of_interest AS value_of_interest,
       nr.value_of_interest AS next_row_value_of_interest
  FROM current_row AS cr
  JOIN current_row AS nr
    ON nr.row_num = cr.row_num + 1
)
SELECT value_of_interest AS sequences_ended,
       next_row_value_of_interest AS sequences_began
  FROM curr_next_value
 WHERE next_row_value_of_interest - value_of_interest > 1;
```

|sequences_ended | sequences_began|
|:--------------:|:--------------:|
|              3 |               6|
|              7 |               9|
|              9 |              11|
|             12 |              20|
|             20 |              25|

To derive the gap start and end points, **we add 1** to `the sequence end` and **subtract 1** from `the sequence start`.

```SQL
WITH current_row AS (
 SELECT num_sequence.value_of_interest,
        ROW_NUMBER() OVER(ORDER BY num_sequence.value_of_interest) as row_num
   FROM sequences as num_sequence
),
curr_next_value AS (
SELECT cr.value_of_interest AS value_of_interest,
       nr.value_of_interest AS next_row_value_of_interest
  FROM current_row AS cr
  JOIN current_row AS nr
    ON nr.row_num = cr.row_num + 1
)
SELECT value_of_interest + 1 AS gap_starts,
       next_row_value_of_interest - 1 AS gap_ends
  FROM curr_next_value
 WHERE next_row_value_of_interest - value_of_interest > 1;
```

|gap_starts | gap_ends|
|:---------:|:--------:|
|         4 |        5|
|         8 |        8|
|        10 |       10|
|        13 |       19|
|        21 |       24|

### Problem 2


```SQL
SELECT date_of_interest,
       LEAD(date_of_interest,1,date_of_interest) OVER(ORDER BY date_of_interest) AS next_row_date_value
  FROM date_sequences;
```

|date_of_interest | next_row_date_value|
|:---------------:|:------------------:|
|2021-01-01       | 2021-01-02|
|2021-01-02       | 2021-01-03|
|2021-01-03       | 2021-01-06|
|2021-01-06       | 2021-01-07|
|2021-01-07       | 2021-01-09|
|2021-01-09       | 2021-01-11|
|2021-01-11       | 2021-01-12|
|2021-01-12       | 2021-01-20|
|2021-01-20       | 2021-01-25|
|2021-01-25       | 2021-01-25|

To identify gaps, we `subtract the current row value from the next row value`. For rows where a sequence ends, **the difference will be greater than 1**.

```SQL
WITH curr_next_date AS (
  SELECT date_of_interest,
         LEAD(date_of_interest,1,date_of_interest) OVER(ORDER BY date_of_interest) AS next_row_date_value
    FROM date_sequences
)
SELECT date_of_interest,
       next_row_date_value
  FROM curr_next_date
 WHERE next_row_date_value - date_of_interest > 1;
```

|date_of_interest | next_row_date_value|
|:---------------:|:------------------:|
|2021-01-03       | 2021-01-06|
|2021-01-07       | 2021-01-09|
|2021-01-09       | 2021-01-11|
|2021-01-12       | 2021-01-20|
|2021-01-20       | 2021-01-25|

To arrive at the gaps, **we add 1** to the `sequence end` and **subtract 1** from the `sequence start`.


```SQL
WITH curr_next_date AS (
  SELECT date_of_interest,
         LEAD(date_of_interest,1,date_of_interest) OVER(ORDER BY date_of_interest) AS next_row_date_value
    FROM date_sequences
)
SELECT date_of_interest + 1 AS gap_starts,
       next_row_date_value - 1 AS gap_ends
  FROM curr_next_date
 WHERE next_row_date_value - date_of_interest > 1;
```

|gap_starts |  gap_ends|
|:---------:|:----------:|
|2021-01-04 | 2021-01-05|
|2021-01-08 | 2021-01-08|
|2021-01-10 | 2021-01-10|
|2021-01-13 | 2021-01-19|
|2021-01-21 | 2021-01-24|
