# Determining Which Rows Are Reciprocals

You have a table containing the `results` of **two tests**, and you want to determine **which pair of scores are reciprocals**.

## Problem

Consider the following result set from  `V`:

```SQL
CREATE TABLE v (
  test1 INTEGER,
  test2 INTEGER
);

INSERT INTO v
       (test1, test2)
VALUES (20,20),
       (50,25),
       (20,20),
       (20,20),
       (60,30),
       (70,90),
       (80,130),
       (90,70),
       (100,50),
       (110,55),
       (120,60),
       (130,80),
       (140,70);
```

|test1 | test2|
|:----:|:-----:|
|   20 |    20|
|   50 |    25|
|   20 |    20|
|   20 |    20|
|   60 |    30|
|   **70** |    **90**|
|   **80** |   **130**|
|   **90** |    **70**|
|  100 |    50|
|  110 |    55|
|  120 |    60|
|  **130** |    **80**|
|  140 |    70|

Examining these results, you see that a test score for `TEST1` of `70` and `TEST2` of `90` is a reciprocal (there exists a score of `90` for `TEST1` and a score of `70` for `TEST2`).

Likewise, the scores of `80` for `TEST1` and `130` for `TEST2` are reciprocals of `130` for `TEST1` and `80` for `TEST2`.

Additionally, the scores of `20` for `TEST1` and `20` for `TEST2` are reciprocals of `20` for `TEST2` and `20` for `TEST1`. You want to identify only one set of reciprocals. You want your result set to be this:

|test1 | test2|
|:----:|:----:|
|   20 |    20|
|   70 |    90|
|   80 |   130|


## Solution

```SQL
SELECT DISTINCT v1.*
  FROM v v1
  JOIN v v2
  ON (v1.test1 = v2.test2 AND
      v1.test2 = v2.test1 AND
      v1.test1 <= v1.test2);
```

## Discussion

The self-join results in a Cartesian product in which every TEST1 score can be com‐ pared against every TEST2 score, and vice versa.

```SQL
SELECT DISTINCT v1.*
  FROM v v1
  JOIN v v2
  ON (v1.test1 = v2.test2 AND
      v1.test2 = v2.test1);
```

The use of `DISTINCT` ensures that duplicate rows are removed from the final result set.

|test1 | test2|
|:----:|:----:|
|   20 |    20|
|   70 |    90|
|   80 |   130|
|   90 |    70|
|  130 |    80|

```SQL
SELECT DISTINCT v1.*
  FROM v v1
  JOIN v v2
  ON (v1.test1 = v2.test2 AND
      v1.test2 = v2.test1 AND
      v1.test1 <= v1.test2);
```

The final filter (and `V1.TEST1 <= V1.TEST2`) **will ensure that only one pair of reciprocals** (where `TEST1` is the **smaller or equal value**) is returned.

```SQL
SELECT DISTINCT v1.*
  FROM v v1
  JOIN v v2
  ON (v1.test1 = v2.test2 AND
      v1.test2 = v2.test1 AND
      v1.test1 >= v1.test2);
```

|test1 | test2|
|:----:|:----:|
|   20 |    20|
|   90 |    70|
|  130 |    80|
