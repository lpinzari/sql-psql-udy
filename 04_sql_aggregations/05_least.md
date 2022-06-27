# Finding the smallest values from two or more columns

First, create a new table named ranks that consists of four columns: the first column stores user `id` and the other three columns to store `ranks` from 1 to 3.

**SQL**
```SQL
CREATE TABLE ranks (
        user_id INT PRIMARY KEY,
        rank_1 INT NOT NULL,
        rank_2 INT NOT NULL,
        rank_3 INT NOT NULL
);
```

Second, insert sample data into the ranks table as follows:

```SQL
INSERT INTO ranks
VALUES (1, 6, 3, 5),
       (2, 2, 8, 5),
       (3, 5, 9, 8);
```

**ranks**

|user_id | rank_1 | rank_2 | rank_3|
|:------:|:------:|:------:|:------:|
|      1 |      6 |      **3** |      5|
|      2 |      **2** |      8 |      5|
|      3 |      **5** |      9 |      8|

How do you get the largest rank per user as shown in the screenshot below:

|user_id | lowest_rank|
|:------:|:------------:|
|      1 |            3|
|      2 |            2|
|      3 |            5|

**SQL**

```SQL
SELECT user_id,
       LEAST (rank_1, rank_2, rank_3) As lowest_rank
  FROM ranks;
```

```console
hr=# SELECT user_id,
hr-#        LEAST (rank_1, rank_2, rank_3) As lowest_rank
hr-#   FROM ranks;
 user_id | lowest_rank
---------+--------------
       1 |            3
       2 |            2
       3 |            5
```
