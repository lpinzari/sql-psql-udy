# Counting values in multiple columns

You want to `count the number of` **rows** with `non-NULL` values in multiple columns.

## Problem


```SQL
CREATE TABLE items (
  id INTEGER PRIMARY KEY,
  size VARCHAR(10),
  thickness VARCHAR(10),
  color VARCHAR(10),
  price INTEGER   
);

INSERT INTO items
       (id,    size, thickness,   color, price)
VALUES ( 1, 'Small',    'Hard', 'White',    10),
       ( 2,   NULL,       NULL,    NULL,  NULL),
       ( 3, 'Small',    'Soft',   'Blue',   20),
       ( 4,    NULL,      NULL,    NULL,  NULL),
       ( 5,    NULL,      NULL,   'Red',  NULL),
       ( 6, 'Small',    'Hard', 'White',    10),
       ( 7,'Medium',    'Hard', 'White',    20),
       ( 8, 'Small',    'Soft',  'Blue',    20),
       ( 9, 'Large',      NULL,   'Red',  NULL);
```


|id |  size  | thickness | color | price|
|:-:|:------:|:---------:|:-----:|:-----:|
| 1 | Small  | Hard      | White |    10|
| 2 | NULL   | NULL      | NULL  |  NULL|
| 3 | Small  | Soft      | Blue  |    20|
| 4 | NULL   | NULL      | NULL  |  NULL|
| 5 | NULL   | NULL      | Red   |  NULL|
| 6 | Small  | Hard      | White |    10|
| 7 | Medium | Hard      | White |    20|
| 8 | Small  | Soft      | Blue  |    20|
| 9 | Large  | NULL      | Red   |  NULL|

```SQL
SELECT thickness, color, price
  FROM items
 ORDER BY thickness, color;
```

|thickness | color | price|
|:--------:|:-----:|:----:|
|Hard      | White |    10|
|Hard      | White |    20|
|Hard      | White |    10|
|Soft      | Blue  |    20|
|Soft      | Blue  |    20|
|NULL      | Red   |  NULL|
|NULL      | Red   |  NULL|
|NULL      | NULL  |  NULL|
|NULL      | NULL  |  NULL|

**(9 rows)**

```SQL
SELECT thickness, color,
       COUNT(*) AS rows,
       COUNT(thickness)  thickness_rows,
       COUNT(color) color_rows
  FROM items
 GROUP BY thickness, color
 ORDER BY thickness, color;  
```

|thickness | color | price|
|:--------:|:-----:|:----:|
|Hard      | White |    10|
|Hard      | White |    20|
|Hard      | White |    10|

|thickness | color | rows | thickness_rows | color_rows|
|:--------:|:-----:|:----:|:--------------:|:---------:|
|Hard      | White |    3 |              3 |          3|

There are `3` rows in the grouping (`Hard,White`), where the number of `non-null` values in the thickness column is `3` as well as the number of rows in the color column.

|thickness | color | price|
|:--------:|:-----:|:----:|
|Soft      | Blue  |    20|
|Soft      | Blue  |    20|

|thickness | color | rows | thickness_rows | color_rows|
|:--------:|:-----:|:----:|:--------------:|:---------:|
|Soft      | Blue  |    2 |              2 |          2|

There are `2` rows in the grouping (`Soft,White`), where the number of `non-null` values in the thickness column is `2` as well as the number of rows in the color column.

|thickness | color | price|
|:--------:|:-----:|:----:|
|NULL      | Red   |  NULL|
|NULL      | Red   |  NULL|


|thickness | color | rows | thickness_rows | color_rows|
|:--------:|:-----:|:----:|:--------------:|:---------:|
|NULL      | Red   |    2 |              0 |          2|

There are `2` rows in the grouping (`NULL,Red`), where the number of `non-null` values in the thickness column is `0` and the number of `non-null` values in the `color` column is `2`. It follows that the number of `NULL` values in the thickness column is `COUNT(*) - COUNT(thickness)`.

|thickness | color | price|
|:--------:|:-----:|:----:|
|NULL      | NULL  |  NULL|
|NULL      | NULL  |  NULL|

|thickness | color | rows | thickness_rows | color_rows|
|:--------:|:-----:|:----:|:--------------:|:---------:|
|NULL      | NULL  |    2 |              0 |          0|

All `NULL` values.

## Single column

```SQL
SELECT id, thickness
  FROM items
 ORDER BY thickness;   
```

|id | thickness|
|:-:|:----------:|
| 6 | Hard|
| 7 | Hard|
| 1 | Hard|
| 8 | Soft|
| 3 | Soft|
| 9 | NULL|
| 2 | NULL|
| 4 | NULL|
| 5 | NULL|

**(9 rows)**

```SQL
SELECT COUNT(*),
       COUNT(thickness) not_null,
       COUNT(DISTINCT thickness) distinct_val
  FROM items;
```

|count | not_null | distinct_val|
|:----:|:--------:|:------------:|
|    9 |        5 |            2|


```SQL
SELECT thickness,
       COUNT(*),
       COUNT(thickness) not_null,
       COUNT(DISTINCT thickness) distinct_val
  FROM items
 GROUP BY thickness;
```

|thickness | count | not_null | distinct_val|
|:--------:|:-----:|:-----:|:----:|
|Hard      |     3 |     3 |     1|
|Soft      |     2 |     2 |     1|
|NULL      |     4 |     0 |     0|
