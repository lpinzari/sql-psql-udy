# Advanced Counting

Say I have a transaction table table in the following form, where a user can purchase different products:

```SQL
CREATE TABLE trx (
  id INTEGER,
  user_id INTEGER,
  item CHAR(1)
);

INSERT INTO trx
       (id, user_id, item)
VALUES (1, 100, 'a'),
       (2, 100, 'b' ),
       (3, 100, 'b'),
       (4, 200, 'b'),
       (5, 300, 'a');
```

Assume there are only two possible values for item. The class item `a` and `b`.

In reality these kinds of tables would normally have a date column, but we’ll exclude that component in this problem.

```SQL
SELECT *
  FROM trx;
```

```console
id | user_id | item
---+---------+------
 1 |     100 | a
 2 |     100 | b
 3 |     100 | b
 4 |     200 | b
 5 |     300 | a
(5 rows)
```

## Problem

Write a query to count the number of users in each class item such that any user
- who has label `a` and `b` gets sorted into `b`,
- any user with just `a` gets sorted into `a` and
- any user with just `b` gets into `b`.

```console
item | count | user_list
-----+-------+-----------
a    |     1 | 300
b    |     2 | 100,200
```

For example, the item classes:

```console
id | user_id | item
---+---------+------
 1 |     100 | a    |  
 2 |     100 | b    |------> Class b |
 3 |     100 | b    |                |
 -------------------                 |-----> (100,200) ---> count: 2
 4 |     200 | b    |------> Class b |
 5 |     300 | a    |------> Class a |-----> (300) ---> count: 1
(5 rows)
```

## Solution

```SQL
WITH usr_item_cnt AS (
  SELECT user_id
        , SUM(CASE WHEN item = 'a'
               THEN 1 ELSE 0
          END) AS a_cnt
        , SUM(CASE WHEN item = 'b'
               THEN 1 ELSE 0
          END) AS b_cnt
    FROM trx
   GROUP BY user_id
),
item_class AS (
  SELECT  user_id
        , CASE WHEN a_cnt > 0 AND b_cnt = 0
               THEN 'a'
               ELSE 'b'
          END AS item
    FROM usr_item_cnt
)
SELECT  item
      , COUNT(DISTINCT user_id) AS count  
      , STRING_AGG(user_id::TEXT, ',' ORDER BY user_id) AS user_list  
  FROM item_class
 GROUP BY item
 ORDER BY item;
```

### Solution 2

```SQL
WITH usr_item_agg AS (
  SELECT  DISTINCT user_id
         , STRING_AGG(item, ',' ORDER BY item) AS all_items
    FROM trx
   GROUP BY user_id
),
item_class AS (
  SELECT  user_id
        , CASE WHEN POSITION('a' IN all_items) > 0 AND
                    POSITION('b' IN all_items) <= 0
               THEN 'a'
               ELSE 'b'
          END AS item
    FROM usr_item_agg
)
SELECT  item
      , COUNT(DISTINCT user_id) AS count   
      , STRING_AGG(user_id::TEXT, ',' ORDER BY user_id) AS user_list    
  FROM item_class
 GROUP BY item
 ORDER BY item;
```


## Discussion


```SQL
WITH usr_item_cnt AS (
  SELECT user_id
        , SUM(CASE WHEN item = 'a'
               THEN 1 ELSE 0
          END) AS a_cnt
        , SUM(CASE WHEN item = 'b'
               THEN 1 ELSE 0
          END) AS b_cnt
    FROM trx
   GROUP BY user_id
)
SELECT *
  FROM usr_item_cnt
 ORDER BY user_id;
```

```console
user_id | a_cnt | b_cnt
--------+-------+-------
    100 |     1 |     2
    200 |     0 |     1
    300 |     1 |     0
(3 rows)
```

```SQL
WITH usr_item_cnt AS (
  SELECT user_id
        , SUM(CASE WHEN item = 'a'
               THEN 1 ELSE 0
          END) AS a_cnt
        , SUM(CASE WHEN item = 'b'
               THEN 1 ELSE 0
          END) AS b_cnt
    FROM trx
   GROUP BY user_id
)
SELECT  user_id
      , CASE WHEN a_cnt > 0 AND b_cnt = 0
             THEN 'a'
             ELSE 'b'
        END AS item
  FROM usr_item_cnt
 ORDER BY user_id;
```

```console
user_id | item
--------+------
    100 | b
    200 | b
    300 | a
(3 rows)
```

```SQL
WITH usr_item_cnt AS (
  SELECT user_id
        , SUM(CASE WHEN item = 'a'
               THEN 1 ELSE 0
          END) AS a_cnt
        , SUM(CASE WHEN item = 'b'
               THEN 1 ELSE 0
          END) AS b_cnt
    FROM trx
   GROUP BY user_id
),
item_class AS (
  SELECT  user_id
        , CASE WHEN a_cnt > 0 AND b_cnt = 0
               THEN 'a'
               ELSE 'b'
          END AS item
    FROM usr_item_cnt
)
SELECT  item
      , COUNT(DISTINCT user_id) AS count     
  FROM item_class
 GROUP BY item
 ORDER BY item;
```

```console
item | count
-----+-------
a    |     1
b    |     2
```

### Solution 2

```SQL
WITH usr_item_agg AS (
  SELECT  DISTINCT user_id
         , STRING_AGG(item, ',' ORDER BY item) AS all_items
    FROM trx
   GROUP BY user_id
)
SELECT *
  FROM usr_item_agg
 ORDER BY user_id;
```

```console
user_id | all_items
--------+-----------
    100 | a,b,b
    200 | b
    300 | a
(3 rows)
```

```SQL
WITH usr_item_agg AS (
  SELECT  DISTINCT user_id
         , STRING_AGG(item, ',' ORDER BY item) AS all_items
    FROM trx
   GROUP BY user_id
)
SELECT  user_id
      , CASE WHEN POSITION('a' IN all_items) > 0 AND
                  POSITION('b' IN all_items) <= 0
             THEN 'a'
             ELSE 'b'
        END AS item
  FROM usr_item_agg
 ORDER BY user_id;
```

```console
user_id | item
--------+------
    100 | b
    200 | b
    300 | a
(3 rows)
```

```SQL
WITH usr_item_agg AS (
  SELECT  DISTINCT user_id
         , STRING_AGG(item, ',' ORDER BY item) AS all_items
    FROM trx
   GROUP BY user_id
),
item_class AS (
  SELECT  user_id
        , CASE WHEN POSITION('a' IN all_items) > 0 AND
                    POSITION('b' IN all_items) <= 0
               THEN 'a'
               ELSE 'b'
          END AS item
    FROM usr_item_agg
)
SELECT  item
      , COUNT(DISTINCT user_id) AS count     
  FROM item_class
 GROUP BY item
 ORDER BY item;
```
