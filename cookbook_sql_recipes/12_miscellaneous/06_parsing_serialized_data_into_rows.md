# Parsing Serialized Data into Rows

You have **serialized data** (stored in `strings`) that you want
- `to parse` and `return as rows`.

## Problem

For example, you store the following data:

```SQL
CREATE VIEW v AS (
  SELECT 'entry:stewiegriffin:lois:brian:' AS strings
  UNION ALL
  SELECT 'entry:moe::sizlack:' AS strings
  UNION ALL
  SELECT 'entry:petergriffin:meg:chris:' AS strings
  UNION ALL
  SELECT 'entry:willie:' AS strings
  UNION ALL
  SELECT 'entry:quagmire:mayorwest:cleveland:' AS strings
  UNION ALL
  SELECT 'entry:::flanders:' AS strings
  UNION ALL
  SELECT 'entry:robo:tchi:ken:'
);

SELECT *
  FROM v;
```

|strings|
|:-----------------------------------:|
|entry:stewiegriffin:lois:brian:|
|entry:moe::sizlack:|
|entry:petergriffin:meg:chris:|
|entry:willie:|
|entry:quagmire:mayorwest:cleveland:|
|entry:::flanders:|
|entry:robo:tchi:ken:|

You want to convert these serialized strings into the following result set:

|serialized_id |     val1      |   val2    |   val3|
|:-------------:|:------------:|:---------:|:----------:|
|            1 | willie        | NULL      | NULL|
|            2 |               |           | flanders|
|            3 | moe           |           | sizlack|
|            4 | robo          | tchi      | ken|
|            5 | petergriffin  | meg       | chris|
|            6 | stewiegriffin | lois      | brian|
|            7 | quagmire      | mayorwest | cleveland|

The `serialized_id` column contains a unique identifier for each row in the view table. The criterion applied to assign the `serialized_id` value is based on the length of the `strings` value.

Each serialized string in this example can store up to three values. The values are delimited by colons, and a string may or may not have all three entries. If a string does not have all three entries, you must be careful to place the entries that are available into the correct column in the result set.

For example, consider the following row:

- `entry:willie:`

This row represents an entry with only the first value. Hence, the second and third value do not exist and the columns `val2` and `val3` are `NULL.`

On the other hand the following row:

- `entry:::flanders:`

This row represents an entry with the first two values missing and only the third value available. Hence, if you examine the target result set you will notice that for the row `FLANDERS` is in, both `VAL1` and `VAL2` are empty strings.


## Solution

```SQL
WITH RECURSIVE cte
     (id, strings, pos, parsed, remaining_after_split) AS (
     -- Anchor query
     SELECT id, strings, 1 AS pos,
            SUBSTRING( strings,
                       POSITION(':' IN strings)+1, --first index
                       POSITION(':' IN SUBSTRING(strings, POSITION(':' IN strings) + 1)) - 1 -- #chars after index
                     ) AS parsed,
            SUBSTRING(strings,
                       POSITION(':' IN (SUBSTRING(strings,
                                        POSITION(':' IN strings) + 1,LENGTH(strings))))
                       + POSITION(':' IN strings) , -- first index
                       LENGTH(strings) -- #chars after index
                     ) AS remaining_after_split
       FROM v2
    UNION ALL
    -- Recursive query
    SELECT id, strings, pos + 1,
           SUBSTRING( remaining_after_split,
                      POSITION(':' IN remaining_after_split)+1, --first index
                      POSITION(':' IN SUBSTRING(remaining_after_split, POSITION(':' IN remaining_after_split) + 1)) - 1 -- #chars after index
                    ) AS parsed,
           SUBSTRING( remaining_after_split,
                      POSITION(':' IN (SUBSTRING(remaining_after_split,
                                       POSITION(':' IN remaining_after_split) + 1,LENGTH(remaining_after_split))))
                      + POSITION(':' IN remaining_after_split) , -- first index
                      LENGTH(remaining_after_split) -- #chars after index
                    ) AS remaining_after_split
      FROM cte
     WHERE LENGTH(remaining_after_split) > 1 -- terminal condition
),
cte_pivot AS (
  SELECT cte.id, cte.pos,
         CASE WHEN pos = 1 THEN parsed END AS val1,
         CASE WHEN pos = 2 THEN parsed END AS val2,
         CASE WHEN pos = 3 THEN parsed END AS val3
    FROM cte
)
SELECT id AS serialized_id,
       MAX(val1) AS val1,
       MAX(val2) AS val2,
       MAX(val3) AS val3
  FROM cte_pivot
 GROUP BY id
 ORDER BY id;
```

## Discussion


Let's first create a sequential identifier for each string in the view table.

```SQL
CREATE VIEW v2 AS (
  SELECT ROW_NUMBER() OVER(ORDER BY LENGTH(strings)) AS id,
         strings
    FROM v
);
SELECT * FROM v2;
```

|id |               strings|
|:-:|:-----------------------------------:|
| 1 | entry:willie:|
| 2 | entry:::flanders:|
| 3 | entry:moe::sizlack:|
| 4 | entry:robo:tchi:ken:|
| 5 | entry:petergriffin:meg:chris:|
| 6 | entry:stewiegriffin:lois:brian:|
| 7 | entry:quagmire:mayorwest:cleveland:|

Let's start with the `Anchor query`:

```SQL
SELECT strings,
       SUBSTRING( strings,
                  POSITION(':' IN strings)+1, --first index
                  POSITION(':' IN SUBSTRING(strings, POSITION(':' IN strings) + 1)) - 1 -- #chars after index
                ) AS parsed,
       SUBSTRING(strings,
                  POSITION(':' IN (SUBSTRING(strings,
                                   POSITION(':' IN strings) + 1,LENGTH(strings))))
                  + POSITION(':' IN strings) , -- first index
                  LENGTH(strings) -- #chars after index
                ) AS remaining_after_split
  FROM v2;
```

|strings               |    parsed     | remaining_after_split|
|:----------------------------------:|:-------------:|:----------------------:|
|entry:**stewiegriffin**:lois:brian:     | stewiegriffin | :lois:brian:|
|entry:**moe**::sizlack:                 | moe           | ::sizlack:|
|entry:**petergriffin**:meg:chris:       | petergriffin  | :meg:chris:|
|entry:**willie**:                       | willie        | :|
|entry:**quagmire**:mayorwest:cleveland: | quagmire      | :mayorwest:cleveland:|
|entry:::flanders:                   |               | ::flanders:|
|entry:**robo**:tchi:ken:                | robo          | :tchi:ken:|


Let's analyse the string:

- `entry`**:**`petergriffin`**:**`meg`**:**`chris`**:**

It contains the following words `petergriffin`, `meg` and `chris`. There are four separators. The first separator is mandatory and separates the `entry` string by the content of the serialized string.

- **First Parsing**

```SQL
SELECT 'entry:petergriffin:meg:chris:'::VARCHAR AS strings,
       SUBSTRING('entry:petergriffin:meg:chris:'::VARCHAR,
                  POSITION(':' IN 'entry:petergriffin:meg:chris:')+1, --first index
                  POSITION(':' IN SUBSTRING('entry:petergriffin:meg:chris:', POSITION(':' IN 'entry:petergriffin:meg:chris:') + 1)) - 1 -- #chars after index
                ) AS parsed,
       SUBSTRING('entry:petergriffin:meg:chris:',
                  POSITION(':' IN (SUBSTRING('entry:petergriffin:meg:chris:',
                                   POSITION(':' IN 'entry:petergriffin:meg:chris:') + 1,LENGTH('entry:petergriffin:meg:chris:'))))
                  + POSITION(':' IN 'entry:petergriffin:meg:chris:') , -- first index
                  LENGTH('entry:petergriffin:meg:chris:') -- #chars after index
                ) AS remaining_after_split;
```


|strings            |    parsed    | remaining_after_split|
|:----------------------------:|:------------:|:----------------------:|
|entry:petergriffin:meg:chris: | petergriffin | :meg:chris:|


- **Second Parsing**:

```SQL
SELECT ':meg:chris:'::VARCHAR AS strings,
       SUBSTRING(':meg:chris:'::VARCHAR,
                  POSITION(':' IN ':meg:chris:')+1, --first index
                  POSITION(':' IN SUBSTRING(':meg:chris:', POSITION(':' IN ':meg:chris:') + 1)) - 1 -- #chars after index
                ) AS parsed,
       SUBSTRING(':meg:chris:',
                  POSITION(':' IN (SUBSTRING(':meg:chris:',
                                   POSITION(':' IN ':meg:chris:') + 1,LENGTH(':meg:chris:'))))
                  + POSITION(':' IN ':meg:chris:') , -- first index
                  LENGTH(':meg:chris:') -- #chars after index
                ) AS remaining_after_split;
```


|strings   | parsed | remaining_after_split|
|:----------:|:------:|:----------------------:|
|:meg:chris: | meg    | :chris: |


- **Third Parsing**:

```SQL
SELECT ':chris:'::VARCHAR AS strings,
       SUBSTRING(':chris:'::VARCHAR,
                  POSITION(':' IN ':chris:')+1, --first index
                  POSITION(':' IN SUBSTRING(':chris:', POSITION(':' IN ':chris:') + 1)) - 1 -- #chars after index
                ) AS parsed,
       SUBSTRING(':chris:',
                  POSITION(':' IN (SUBSTRING(':chris:',
                                   POSITION(':' IN ':chris:') + 1,LENGTH(':chris:'))))
                  + POSITION(':' IN ':chris:') , -- first index
                  LENGTH(':chris:') -- #chars after index
                ) AS remaining_after_split;
```

|strings | parsed | remaining_after_split|
|:------:|:------:|:---------------------:|
|:chris: | chris  | :|

In the last iteration the `remaining_after_split` string is just the separator character `:`. This status is a good condition to terminates the recursive query in the `WHERE` clause.

Let's put everything together:

```SQL
WITH RECURSIVE cte
     (id, strings, pos, parsed, remaining_after_split) AS (
     -- Anchor query
     SELECT id, strings, 1 AS pos,
            SUBSTRING( strings,
                       POSITION(':' IN strings)+1, --first index
                       POSITION(':' IN SUBSTRING(strings, POSITION(':' IN strings) + 1)) - 1 -- #chars after index
                     ) AS parsed,
            SUBSTRING(strings,
                       POSITION(':' IN (SUBSTRING(strings,
                                        POSITION(':' IN strings) + 1,LENGTH(strings))))
                       + POSITION(':' IN strings) , -- first index
                       LENGTH(strings) -- #chars after index
                     ) AS remaining_after_split
       FROM v2
    UNION ALL
    -- Recursive query
    SELECT id, strings, pos + 1,
           SUBSTRING( remaining_after_split,
                      POSITION(':' IN remaining_after_split)+1, --first index
                      POSITION(':' IN SUBSTRING(remaining_after_split, POSITION(':' IN remaining_after_split) + 1)) - 1 -- #chars after index
                    ) AS parsed,
           SUBSTRING( remaining_after_split,
                      POSITION(':' IN (SUBSTRING(remaining_after_split,
                                       POSITION(':' IN remaining_after_split) + 1,LENGTH(remaining_after_split))))
                      + POSITION(':' IN remaining_after_split) , -- first index
                      LENGTH(remaining_after_split) -- #chars after index
                    ) AS remaining_after_split
      FROM cte
     WHERE LENGTH(remaining_after_split) > 1 -- terminal condition
)
SELECT *
  FROM cte
 ORDER BY id, pos;
```


|id |  strings               | pos |    parsed     | remaining_after_split|
|:-:|:----------------------:|:---:|:--------------:|:---------------------:|
|1 | entry:willie:                       |   1 | willie        | :|
|2 | entry:::flanders:                   |   1 |               | ::flanders:|
|2 | entry:::flanders:                   |   2 |               | :flanders:|
|2 | entry:::flanders:                   |   3 | flanders      | :|
|3 | entry:moe::sizlack:                 |   1 | moe           | ::sizlack:|
|3 | entry:moe::sizlack:                 |   2 |               | :sizlack:|
|3 | entry:moe::sizlack:                 |   3 | sizlack       | :|
|4 | entry:robo:tchi:ken:                |   1 | robo          | :tchi:ken:|
|4 | entry:robo:tchi:ken:                |   2 | tchi          | :ken:|
|4 | entry:robo:tchi:ken:                |   3 | ken           | :|
|5 | entry:petergriffin:meg:chris:       |   1 | petergriffin  | :meg:chris:|
|5 | entry:petergriffin:meg:chris:       |   2 | meg           | :chris:|
|5 | entry:petergriffin:meg:chris:       |   3 | chris         | :|
|6 | entry:stewiegriffin:lois:brian:     |   1 | stewiegriffin | :lois:brian:|
|6 | entry:stewiegriffin:lois:brian:     |   2 | lois          | :brian:|
|6 | entry:stewiegriffin:lois:brian:     |   3 | brian         | :|
|7 | entry:quagmire:mayorwest:cleveland: |   1 | quagmire      | :mayorwest:cleveland:|
|7 | entry:quagmire:mayorwest:cleveland: |   2 | mayorwest     | :cleveland:|
|7 | entry:quagmire:mayorwest:cleveland: |   3 | cleveland     | :|


Now that you know the numeric positions for each pair of colons in each string, sim‐ ply pass the information to the function SUBSTR to extract values. Since you want to create a result set with three columns we create three `CASE` expressions.

```SQL
WITH RECURSIVE cte
     (id, strings, pos, parsed, remaining_after_split) AS (
     -- Anchor query
     SELECT id, strings, 1 AS pos,
            SUBSTRING( strings,
                       POSITION(':' IN strings)+1, --first index
                       POSITION(':' IN SUBSTRING(strings, POSITION(':' IN strings) + 1)) - 1 -- #chars after index
                     ) AS parsed,
            SUBSTRING(strings,
                       POSITION(':' IN (SUBSTRING(strings,
                                        POSITION(':' IN strings) + 1,LENGTH(strings))))
                       + POSITION(':' IN strings) , -- first index
                       LENGTH(strings) -- #chars after index
                     ) AS remaining_after_split
       FROM v2
    UNION ALL
    -- Recursive query
    SELECT id, strings, pos + 1,
           SUBSTRING( remaining_after_split,
                      POSITION(':' IN remaining_after_split)+1, --first index
                      POSITION(':' IN SUBSTRING(remaining_after_split, POSITION(':' IN remaining_after_split) + 1)) - 1 -- #chars after index
                    ) AS parsed,
           SUBSTRING( remaining_after_split,
                      POSITION(':' IN (SUBSTRING(remaining_after_split,
                                       POSITION(':' IN remaining_after_split) + 1,LENGTH(remaining_after_split))))
                      + POSITION(':' IN remaining_after_split) , -- first index
                      LENGTH(remaining_after_split) -- #chars after index
                    ) AS remaining_after_split
      FROM cte
     WHERE LENGTH(remaining_after_split) > 1 -- terminal condition
)
SELECT CASE WHEN pos = 1 THEN parsed END AS val1,
       CASE WHEN pos = 2 THEN parsed END AS val2,
       CASE WHEN pos = 3 THEN parsed END AS val3
  FROM cte
 ORDER BY pos;
```

|val1      |   val2    |   val3|
|:---------:|:--------:|:----------:|
|willie        |           ||
|          |           ||
|moe           |           ||
|robo          |           ||
|petergriffin  |           ||
|stewiegriffin |           ||
|quagmire      |           ||
|          |           ||
|          |           ||
|          | tchi      ||
|          | meg       ||
|          | lois      ||
|          | mayorwest ||
|          |           | flanders|
|          |           | sizlack|
|          |           | ken|
|          |           | chris|
|          |           | brian|
|          |           | cleveland|

The last step is to apply an aggregate function to the values returned by SUBSTR while grouping by ID, to make a human-readable result set:


```SQL
WITH RECURSIVE cte
     (id, strings, pos, parsed, remaining_after_split) AS (
     -- Anchor query
     SELECT id, strings, 1 AS pos,
            SUBSTRING( strings,
                       POSITION(':' IN strings)+1, --first index
                       POSITION(':' IN SUBSTRING(strings, POSITION(':' IN strings) + 1)) - 1 -- #chars after index
                     ) AS parsed,
            SUBSTRING(strings,
                       POSITION(':' IN (SUBSTRING(strings,
                                        POSITION(':' IN strings) + 1,LENGTH(strings))))
                       + POSITION(':' IN strings) , -- first index
                       LENGTH(strings) -- #chars after index
                     ) AS remaining_after_split
       FROM v2
    UNION ALL
    -- Recursive query
    SELECT id, strings, pos + 1,
           SUBSTRING( remaining_after_split,
                      POSITION(':' IN remaining_after_split)+1, --first index
                      POSITION(':' IN SUBSTRING(remaining_after_split, POSITION(':' IN remaining_after_split) + 1)) - 1 -- #chars after index
                    ) AS parsed,
           SUBSTRING( remaining_after_split,
                      POSITION(':' IN (SUBSTRING(remaining_after_split,
                                       POSITION(':' IN remaining_after_split) + 1,LENGTH(remaining_after_split))))
                      + POSITION(':' IN remaining_after_split) , -- first index
                      LENGTH(remaining_after_split) -- #chars after index
                    ) AS remaining_after_split
      FROM cte
     WHERE LENGTH(remaining_after_split) > 1 -- terminal condition
),
cte_pivot AS (
  SELECT cte.id, cte.pos,
         CASE WHEN pos = 1 THEN parsed END AS val1,
         CASE WHEN pos = 2 THEN parsed END AS val2,
         CASE WHEN pos = 3 THEN parsed END AS val3
    FROM cte
)
SELECT id AS serialized_id,
       MAX(val1) AS val1,
       MAX(val2) AS val2,
       MAX(val3) AS val3
  FROM cte_pivot
 GROUP BY id
 ORDER BY id;
```

|serialized_id |     val1      |   val2    |   val3|
|:------------:|:-------------:|:---------:|:----------:|
|            1 | willie        |           ||
|            2 |               |           | flanders|
|            3 | moe           |           | sizlack|
|            4 | robo          | tchi      | ken|
|            5 | petergriffin  | meg       | chris|
|            6 | stewiegriffin | lois      | brian|
|            7 | quagmire      | mayorwest | cleveland|


Keep in mind that the blank fields in the first row of the  resulting table are not empty strings but `NULL` values.


```SQL
WITH RECURSIVE cte
     (id, strings, pos, parsed, remaining_after_split) AS (
     -- Anchor query
     SELECT id, strings, 1 AS pos,
            SUBSTRING( strings,
                       POSITION(':' IN strings)+1, --first index
                       POSITION(':' IN SUBSTRING(strings, POSITION(':' IN strings) + 1)) - 1 -- #chars after index
                     ) AS parsed,
            SUBSTRING(strings,
                       POSITION(':' IN (SUBSTRING(strings,
                                        POSITION(':' IN strings) + 1,LENGTH(strings))))
                       + POSITION(':' IN strings) , -- first index
                       LENGTH(strings) -- #chars after index
                     ) AS remaining_after_split
       FROM v2
    UNION ALL
    -- Recursive query
    SELECT id, strings, pos + 1,
           SUBSTRING( remaining_after_split,
                      POSITION(':' IN remaining_after_split)+1, --first index
                      POSITION(':' IN SUBSTRING(remaining_after_split, POSITION(':' IN remaining_after_split) + 1)) - 1 -- #chars after index
                    ) AS parsed,
           SUBSTRING( remaining_after_split,
                      POSITION(':' IN (SUBSTRING(remaining_after_split,
                                       POSITION(':' IN remaining_after_split) + 1,LENGTH(remaining_after_split))))
                      + POSITION(':' IN remaining_after_split) , -- first index
                      LENGTH(remaining_after_split) -- #chars after index
                    ) AS remaining_after_split
      FROM cte
     WHERE LENGTH(remaining_after_split) > 1 -- terminal condition
),
cte_pivot AS (
  SELECT cte.id, cte.pos,
         CASE WHEN pos = 1 THEN parsed END AS val1,
         CASE WHEN pos = 2 THEN parsed END AS val2,
         CASE WHEN pos = 3 THEN parsed END AS val3
    FROM cte
)
SELECT id AS serialized_id,
       COALESCE(MAX(val1),'NULL') AS val1,
       COALESCE(MAX(val2),'NULL') AS val2,
       COALESCE(MAX(val3),'NULL') AS val3
  FROM cte_pivot
 GROUP BY id
 ORDER BY id;
```

|serialized_id |     val1      |   val2    |   val3|
|:-------------:|:------------:|:---------:|:----------:|
|            1 | willie        | NULL      | NULL|
|            2 |               |           | flanders|
|            3 | moe           |           | sizlack|
|            4 | robo          | tchi      | ken|
|            5 | petergriffin  | meg       | chris|
|            6 | stewiegriffin | lois      | brian|
|            7 | quagmire      | mayorwest | cleveland|
