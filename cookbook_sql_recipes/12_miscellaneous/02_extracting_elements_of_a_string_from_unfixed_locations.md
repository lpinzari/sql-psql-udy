# Extracting Elements of a String from Unfixed Locations

You have a string field that contains `serialized log data`. You want to `parse` through the `string` and **extract the relevant information**.

Unfortunately, the relevant information is not at fixed points in the string. Instead, you must use the fact that
- **certain characters exist around the information you need**, to extract said information.

## Problem

For example, consider the following strings:


```SQL
CREATE VIEW v AS (
  SELECT 1 AS row_id , 'xxxxxabc[867]xxx[-]xxxx[5309]xxxxx'::VARCHAR AS msg
  UNION ALL
  SELECT 2 AS row_id, 'xxxxxtime:[11271978]favnum:[4]id:[Joe]xxxxx'::VARCHAR AS msg
  UNION ALL
  SELECT 3 AS row_id, 'call:[F_GET_ROWS()]b1:[ROSEWOOD...SIR]b2:[44400002]77.90xxxxx'::VARCHAR AS msg
  UNION ALL
  SELECT 4 AS row_id,
  'film:[non_marked]qq:[unit]tailpipe:[withabanana?]80sxxxxx'::VARCHAR AS msg
);
```

|row_id |                              msg|
|:------:|:--------------------------------------------------------------:|
|      1 | xxxxxabc[**867**]xxx[**-**]xxxx[**5309**]xxxxx|
|      2 | xxxxxtime:[**11271978**]favnum:[**4**]id:[**Joe**]xxxxx|
|      3 | call:[**F_GET_ROWS()**]b1:[**ROSEWOOD...SIR**]b2:[**44400002**]77.90xxxxx|
|      4 | film:[**non_marked**]qq:[**unit**]tailpipe:[**withabanana?**]80sxxxxx|

We want the following output:

|row_id | pos_val |     parsed|
|:-----:|:-------:|:--------------:|
|     1 |       1 | 867|
|     1 |       2 | -|
|     1 |       3 | 5309|
|     2 |       1 | 11271978|
|     2 |       2 | 4|
|     2 |       3 | Joe|
|     3 |       1 | F_GET_ROWS()|
|     3 |       2 | ROSEWOOD...SIR|
|     3 |       3 | 44400002|
|     4 |       1 | non_marked|
|     4 |       2 | unit|
|     4 |       3 | withabanana?|

- **Problem 2**:

Following the output table of the last exercise we want to aggregate the parsed strings into a single csv column.

|row_id |             filtered_csv|
|:-----:|:-------------------------------------:|
|     1 | 867,-,5309|
|     2 | 11271978,4,Joe|
|     3 | F_GET_ROWS(),ROSEWOOD...SIR,44400002|
|     4 | non_marked,unit,withabanana?|

## Solution

Despite not knowing the exact locations within the string of the interesting values, you do know that they are located between square brackets [].

Use Postgre’s built-in function `POSITION` to find the locations of the brackets. Use the built-in function `SUBSTR` to extract the values from the string. View V will contain the strings to parse and is defined as follows (its use is strictly for readability):

```SQL
WITH RECURSIVE cte
     (row_id, msg, parsed, remaining_after_split, pos_next1, pos_next2) AS (
      SELECT row_id,
             msg,
             SUBSTRING(msg, POSITION('[' IN msg) + 1, POSITION(']' IN msg) - POSITION('[' IN msg)-1)
             AS parsed,
             SUBSTRING(msg, POSITION(']' IN msg) + 1, LENGTH(msg))
             AS remaining_after_split,
             POSITION('[' IN SUBSTRING(msg, POSITION(']' IN msg) + 1, LENGTH(msg))) AS pos_next1,
             POSITION(']' IN SUBSTRING(msg, POSITION(']' IN msg) + 1, LENGTH(msg))) AS pos_next2
         FROM v
      UNION ALL
      SELECT row_id,
             msg,
             SUBSTRING(remaining_after_split, POSITION('[' IN remaining_after_split) + 1, POSITION(']' IN remaining_after_split) - POSITION('[' IN remaining_after_split)-1)
             AS parsed,
             SUBSTRING(remaining_after_split, POSITION(']' IN remaining_after_split) + 1, LENGTH(remaining_after_split))
             AS remaining_after_split,
             POSITION('[' IN SUBSTRING(remaining_after_split, POSITION(']' IN remaining_after_split) + 1, LENGTH(remaining_after_split))) AS pos_next1,
             POSITION(']' IN SUBSTRING(remaining_after_split, POSITION(']' IN remaining_after_split) + 1, LENGTH(remaining_after_split))) AS pos_next2
        FROM cte
       WHERE (pos_next1 > 0 AND pos_next2 > 0)
)
SELECT row_id,
       ROW_NUMBER()OVER(PARTITION BY row_id ORDER BY LENGTH(remaining_after_split) DESC) AS pos_val, parsed
  FROM cte
 ORDER BY row_id, LENGTH(remaining_after_split) DESC;
```
In this situation, we'll need a column that uniquely identifies a row to ensure the separated values are associated with the correct identifier.

First, we use the `SUBSTRING` function to get the value between the brackets. Then we take the value after the closing bracket and use `SUBSTRING()` to get the string remaining after the split. Finally, we keep a column to store the position of the first opening bracket, `[` in the string to be parsed in the next recursive step. The function returns zero if no bracket is found and the recursive call is terminated.

This process repeats in the Recursive Query, with each Recursion working on a smaller and smaller substring. When there are no more values enclosed in brackets left, the Recursion stops.

- **Problem 2**:

```SQL
WITH RECURSIVE cte
     (row_id, msg, parsed, remaining_after_split, pos_next1, pos_next2) AS (
      SELECT row_id,
             msg,
             SUBSTRING(msg, POSITION('[' IN msg) + 1, POSITION(']' IN msg) - POSITION('[' IN msg)-1)
             AS parsed,
             SUBSTRING(msg, POSITION(']' IN msg) + 1, LENGTH(msg))
             AS remaining_after_split,
             POSITION('[' IN SUBSTRING(msg, POSITION(']' IN msg) + 1, LENGTH(msg))) AS pos_next1,
             POSITION(']' IN SUBSTRING(msg, POSITION(']' IN msg) + 1, LENGTH(msg))) AS pos_next2
         FROM v
      UNION ALL
      SELECT row_id,
             msg,
             SUBSTRING(remaining_after_split, POSITION('[' IN remaining_after_split) + 1, POSITION(']' IN remaining_after_split) - POSITION('[' IN remaining_after_split)-1)
             AS parsed,
             SUBSTRING(remaining_after_split, POSITION(']' IN remaining_after_split) + 1, LENGTH(remaining_after_split))
             AS remaining_after_split,
             POSITION('[' IN SUBSTRING(remaining_after_split, POSITION(']' IN remaining_after_split) + 1, LENGTH(remaining_after_split))) AS pos_next1,
             POSITION(']' IN SUBSTRING(remaining_after_split, POSITION(']' IN remaining_after_split) + 1, LENGTH(remaining_after_split))) AS pos_next2
        FROM cte
       WHERE (pos_next1 > 0 AND pos_next2 > 0)
),
parsed_string AS (
  SELECT row_id,
         ROW_NUMBER()OVER(PARTITION BY row_id ORDER BY LENGTH(remaining_after_split) DESC) AS pos_val,
         parsed
    FROM cte
)
SELECT row_id,
       STRING_AGG(parsed::VARCHAR, ',' ORDER BY pos_val) AS filtered_csv
  FROM parsed_string
 GROUP BY row_id
 ORDER BY row_id;
```

## Discussion

Let's start with the `Anchor query`:

```SQL
SELECT row_id,
       msg,
       SUBSTRING(msg, POSITION('[' IN msg) + 1, POSITION(']' IN msg) - POSITION('[' IN msg)-1)
       AS parsed,
       SUBSTRING(msg, POSITION(']' IN msg) + 1, LENGTH(msg))
       AS remaining_after_split,
       POSITION('[' IN SUBSTRING(msg, POSITION(']' IN msg) + 1, LENGTH(msg))) AS pos_next1,
       POSITION(']' IN SUBSTRING(msg, POSITION(']' IN msg) + 1, LENGTH(msg))) AS pos_next2
  FROM v;
```

|row_id |                              msg                              |    parsed    |           remaining_after_split            | pos_next1| pos_next2|
|:--------:|:---------------------------------------------------------------:|:--------------:|:--------------------------------------------:|:---------:|:---:|
|1 | xxxxxabc[867]xxx[-]xxxx[5309]xxxxx                            | 867          | xxx**[**-**]**xxxx[5309]xxxxx|                   4   |       6 |
|2 | xxxxxtime:[11271978]favnum:[4]id:[Joe]xxxxx                   | 11271978     | favnum:**[**4**]**id:[Joe]xxxxx                    |        8| 10 |
|3 | call:[F_GET_ROWS()]b1:[ROSEWOOD...SIR]b2:[44400002]77.90xxxxx | F_GET_ROWS() | b1:**[**ROSEWOOD...SIR**]**b2:[44400002]77.90xxxxx |        4| 19 |
|4 | film:[non_marked]qq:[unit]tailpipe:[withabanana?]80sxxxxx     | non_marked   | qq:**[**unit**]**tailpipe:[withabanana?]80sxxxxx   |        4| 9|

- **First Parsing**

```SQL
SELECT 'xxxxxabc[867]xxx[-]xxxx[5309]xxxxx'::VARCHAR AS msg,
       SUBSTRING('xxxxxabc[867]xxx[-]xxxx[5309]xxxxx', POSITION('[' IN 'xxxxxabc[867]xxx[-]xxxx[5309]xxxxx') + 1, POSITION(']' IN 'xxxxxabc[867]xxx[-]xxxx[5309]xxxxx') - POSITION('[' IN 'xxxxxabc[867]xxx[-]xxxx[5309]xxxxx')-1) AS parsed,
       SUBSTRING('xxxxxabc[867]xxx[-]xxxx[5309]xxxxx', POSITION(']' IN 'xxxxxabc[867]xxx[-]xxxx[5309]xxxxx') + 1, LENGTH('xxxxxabc[867]xxx[-]xxxx[5309]xxxxx')) AS remaining_after_split,
       POSITION('[' IN SUBSTRING('xxxxxabc[867]xxx[-]xxxx[5309]xxxxx', POSITION(']' IN 'xxxxxabc[867]xxx[-]xxxx[5309]xxxxx') + 1, LENGTH('xxxxxabc[867]xxx[-]xxxx[5309]xxxxx'))) AS pos_next1,
       POSITION(']' IN SUBSTRING('xxxxxabc[867]xxx[-]xxxx[5309]xxxxx', POSITION(']' IN 'xxxxxabc[867]xxx[-]xxxx[5309]xxxxx') + 1, LENGTH('xxxxxabc[867]xxx[-]xxxx[5309]xxxxx'))) AS pos_next2;
```

|msg                 | parsed | remaining_after_split | pos_next_1| pos_next2|
|:---------------------------------:|:------:|:---------------------:|:-------:|:--:|
|xxxxxabc[867]xxx[-]xxxx[5309]xxxxx | 867    | xxx**[**-**]**xxxx[5309]xxxxx |        4|6|


- **Second Parsing**:

```SQL
SELECT 'xxx[-]xxxx[5309]xxxxx'::VARCHAR AS msg,
       SUBSTRING('xxx[-]xxxx[5309]xxxxx', POSITION('[' IN 'xxx[-]xxxx[5309]xxxxx') + 1, POSITION(']' IN 'xxx[-]xxxx[5309]xxxxx') - POSITION('[' IN 'xxx[-]xxxx[5309]xxxxx')-1) AS parsed,
       SUBSTRING('xxx[-]xxxx[5309]xxxxx', POSITION(']' IN 'xxx[-]xxxx[5309]xxxxx') + 1, LENGTH('xxx[-]xxxx[5309]xxxxx')) AS remaining_after_split,
       POSITION('[' IN SUBSTRING('xxx[-]xxxx[5309]xxxxx', POSITION(']' IN 'xxx[-]xxxx[5309]xxxxx') + 1, LENGTH('xxx[-]xxxx[5309]xxxxx'))) AS pos_next1,
       POSITION(']' IN SUBSTRING('xxx[-]xxxx[5309]xxxxx', POSITION(']' IN 'xxx[-]xxxx[5309]xxxxx') + 1, LENGTH('xxx[-]xxxx[5309]xxxxx'))) AS pos_next2;
```

|msg          | parsed | remaining_after_split | pos_next1| pos_next2|
|:---------------------:|:-------:|:---------------------:|:---------:|:---:|
|xxx[-]xxxx[5309]xxxxx | -      | xxxx**[**5309**]**xxxxx       |        5| 10|

- **Last parsing**

```SQL
SELECT 'xxxx[5309]xxxxx'::VARCHAR AS msg,
       SUBSTRING('xxxx[5309]xxxxx', POSITION('[' IN 'xxxx[5309]xxxxx') + 1, POSITION(']' IN 'xxxx[5309]xxxxx') - POSITION('[' IN 'xxxx[5309]xxxxx')-1) AS parsed,
       SUBSTRING('xxxx[5309]xxxxx', POSITION(']' IN 'xxxx[5309]xxxxx') + 1, LENGTH('xxxx[5309]xxxxx')) AS remaining_after_split,
       POSITION('[' IN SUBSTRING('xxxx[5309]xxxxx', POSITION(']' IN 'xxxx[5309]xxxxx') + 1, LENGTH('xxxx[5309]xxxxx'))) AS pos_next1,
       POSITION(']' IN SUBSTRING('xxxx[5309]xxxxx', POSITION(']' IN 'xxxx[5309]xxxxx') + 1, LENGTH('xxxx[5309]xxxxx'))) AS pos_next2;
```

|msg       | parsed | remaining_after_split | pos_next1| pos_nex2|
|:--------------:|:------:|:---------------------:|:-------:|:---:|
|xxxx[5309]xxxxx | 5309   | xxxxx                 |        0|0|
