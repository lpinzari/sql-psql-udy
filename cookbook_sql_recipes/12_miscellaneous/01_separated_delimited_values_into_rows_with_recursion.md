# Separate delimited values into rows with a Recursive CTE

If we have a **column of data** and the `data is separated by a delimiter`, e.g., a comma,(`,`), like a `CSV` file, we want to **turn this into rows**.

## Problem

Let's create a table with a column of comma separated values:

```SQL
CREATE TABLE csv_table (
  row_id INTEGER PRIMARY KEY,
  csv_values VARCHAR
);

INSERT INTO csv_table
       (row_id, csv_values)
VALUES (1,'Purple,Green,Yellow'),
       (2,'Python'),
       (3,'X,Y,Z'),
       (4,'');
```

|row_id |     csv_values|
|:-----:|:-------------------:|
|     1 | Purple,Green,Yellow|
|     2 | Python|
|     3 | X,Y,Z|
|     4 ||

We want to return the following table:

|row_id |     orig_column     | split_column | remaining_after_split|
|:-----:|:-------------------:|:------------:|:--------------------:|
|     1 | Purple,Green,Yellow | Purple       | Green,Yellow|
|     1 | Purple,Green,Yellow | Green        | Yellow|
|     1 | Purple,Green,Yellow | Yellow       ||
|     2 | Python              | Python       ||
|     3 | X,Y,Z               | X            | Y,Z|
|     3 | X,Y,Z               | Y            | Z|
|     3 | X,Y,Z               | Z            ||
|     4 |                     |              ||

## Solution

```SQL
WITH RECURSIVE cte
     (row_id, orig_column, split_column, remaining_after_split) AS (
     -- Anchor query
     SELECT row_id,
            csv_values AS orig_column,
            LEFT(csv_values, POSITION(',' IN csv_values || ',') - 1) AS split_column,
            SUBSTRING(csv_values, POSITION(',' IN csv_values || ',') + 1, LENGTH(csv_values)) AS remaining_after_split
       FROM csv_table
     UNION ALL
     SELECT row_id,
            orig_column,
            LEFT(remaining_after_split, POSITION(',' IN remaining_after_split || ',') - 1) AS split_column,
            SUBSTRING(remaining_after_split, POSITION(',' IN remaining_after_split || ',') + 1, LENGTH(remaining_after_split)) AS remaining_after_split
       FROM cte
      WHERE remaining_after_split > ''    
)
SELECT *
  FROM cte
 ORDER BY row_id, LENGTH(remaining_after_split) DESC;
```

In this situation, we'll need a column that uniquely identifies a row to ensure the separated values are associated with the correct identifier.

First, we use the `LEFT()` function to get the value before the first comma. Then we take the value before the first comma and use `SUBSTRING()` remove it from our comma-separated column.

This process repeats in the Recursive Query, with each Recursion working on a smaller and smaller list of comma-separated values. When there are no more values left, the Recursion stops.

## Discussion

```SQL
SELECT row_id,
       csv_values,
       LEFT(csv_values, POSITION(',' IN csv_values || ',') - 1) AS split_column,
       SUBSTRING(csv_values, POSITION(',' IN csv_values || ',') + 1, LENGTH(csv_values)) AS remaining_after_split
  FROM csv_table;
```

The [POSITION](https://github.com/lpinzari/sql-psql-udy/blob/master/06_string_functions/12_position.md) function returns the location of the first instance of the substring in the string. `POSITION('substring' IN string)`.

|row_id |     csv_values      | split_column | remaining_after_split|
|:-----:|:-------------------:|:------------:|:--------------------:|
|     1 | Purple,Green,Yellow | Purple       | Green,Yellow|
|     2 | Python              | Python       ||
|     3 | X,Y,Z               | X            | Y,Z|
|     4 |                     |              ||

```SQL
SELECT POSITION(',' IN 'Purple,Green,Yellow' || ',') - 1; -- position 6
SELECT POSITION('P' IN 'Purple,Green,Yellow' || ','); -- position 7
SELECT POSITION('P' IN 'Purple,Green,Yellow' || ',') + 1; -- position 8
```

```console
POSITION(',' IN 'Purple,Green,Yellow' || ',')   --> 7
                                                    |
                (7 - 1)   7  (7 + 1)
                     |    |   |
+-------------------------------------------------------------------------------+
| 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10| 11| 12| 13| 14| 15| 16| 17| 18| 19| 20|
| P | u | r | p | l | e | , | G | r | e | e | n | , | Y | e | l | l | o | w | , |
+-------------------------------------------------------------------------------+
                      |       |  SUBSTRING(csv_values, 8, 19)
                      |    +------------------------------------+
                      |    | G  r  e  e  n  ,  Y  e  l  l  o  w |
-------------------+  |    +------------------------------------+
| P  u  r  p  l  e |  LEFT(csv_values,6)                                      
+------------------+                          
```


**First Recursive call** for row_id equal `1`.

```console
remaining_after_split <->  'Green,Yellow'
```

```SQL
SELECT 'Green,Yellow' AS before_split,
       LEFT('Green,Yellow', POSITION(',' IN 'Green,Yellow' || ',') - 1) AS split_column,
       SUBSTRING('Green,Yellow', POSITION(',' IN 'Green,Yellow' || ',') + 1, LENGTH('Green,Yellow')) AS remaining_after_split;
```

|before_split | split_column | remaining_after_split|
|:-----------:|:------------:|:---------------------:|
|Green,Yellow | Green        | Yellow|

```SQL
SELECT 'Yellow' AS before_split,
       LEFT('Yellow', POSITION(',' IN 'Yellow' || ',') - 1) AS split_column,
       SUBSTRING('Yellow', POSITION(',' IN 'Yellow' || ',') + 1, LENGTH('Yellow')) AS remaining_after_split;
```

|before_split | split_column | remaining_after_split|
|:-----------:|:------------:|:--------------------:|
|Yellow       | Yellow       ||

```SQL
SELECT '' > '' AS terminal_condition;
```

|terminal_condition|
|:------------------:|
|f|

```SQL
WITH RECURSIVE cte
     (row_id, orig_column, split_column, remaining_after_split) AS (
     -- Anchor query
     SELECT row_id,
            csv_values AS orig_column,
            LEFT(csv_values, POSITION(',' IN csv_values || ',') - 1) AS split_column,
            SUBSTRING(csv_values, POSITION(',' IN csv_values || ',') + 1, LENGTH(csv_values)) AS remaining_after_split
       FROM csv_table
     UNION ALL
     SELECT row_id,
            orig_column,
            LEFT(remaining_after_split, POSITION(',' IN remaining_after_split || ',') - 1) AS split_column,
            SUBSTRING(remaining_after_split, POSITION(',' IN remaining_after_split || ',') + 1, LENGTH(remaining_after_split)) AS remaining_after_split
       FROM cte
      WHERE remaining_after_split > ''    
)
SELECT *
  FROM cte;
```


```console
row_id |     orig_column     | split_column | remaining_after_split
--------+---------------------+--------------+-----------------------
     1 | Purple,Green,Yellow | Purple       | Green,Yellow
     2 | Python              | Python       |
     3 | X,Y,Z               | X            | Y,Z
     4 |                     |              |
     --------------------------------------------- END ANCHOR QUERY
     1 | Purple,Green,Yellow | Green        | Yellow
     3 | X,Y,Z               | Y            | Z
     --------------------------------------------- END FIRST RECURSIVE CALL
     1 | Purple,Green,Yellow | Yellow       |
     3 | X,Y,Z               | Z            |
     --------------------------------------------- END LAST RECURSIVE CALL
```
