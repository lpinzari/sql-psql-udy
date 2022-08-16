# Creating a Calendar

You want to **create a calendar for the current month**.

The calendar should be formatted like a calendar you might have on your desk:

- **seven columns across** and (`usually`) **five rows down**.


## Problem

For example, the calendar for the month of `August` in `2022` is:

|mo | tu | we | th | fr | sa | su|
|:-:|:--:|:---:|:--:|:--:|:---:|:---:|
| 1 |  2 |  3 |  4 |  5 |  6 |  7|
| 8 |  9 | 10 | 11 | 12 | 13 | 14|
|15 | 16 | 17 | 18 | 19 | 20 | 21|
|22 | 23 | 24 | 25 | 26 | 27 | 28|
|29 | 30 | 31 |    |    |    ||

There are different formats available for calendars. For example, the Unix CAL com‐ mand formats the days from Sunday to Saturday. The examples in this recipe are based on ISO weeks, so the Monday through Friday format is the most convenient to generate.

## Solution

Each solution will look a bit different, but they all solve the problem the same way: `return each day for the current month, and then pivot on the day of the week for each week in the month` to create a calendar.

Use a **recursive CTE** to return `each day in the current month`. Then **pivot** on the day of the week using `MAX` and `CASE`:

```SQL
WITH RECURSIVE temp AS (
  SELECT dy,
         EXTRACT('DAY' FROM dy) AS dy_mth,
         EXTRACT('MONTH' FROM dy) AS mth,
         EXTRACT('DOW' FROM dy) AS dow,
         EXTRACT('WEEK' FROM dy) AS wk
    FROM (SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS dy) t
  UNION ALL
  SELECT dy + 1,
         EXTRACT('DAY' FROM dy + 1) AS dy_mth,
         EXTRACT('MONTH' FROM dy + 1) AS mth,
         EXTRACT('DOW' FROM dy + 1) AS dow,
         EXTRACT('WEEK' FROM dy + 1) AS wk
    FROM temp
   WHERE EXTRACT('MONTH' FROM dy + 1) = mth
)
SELECT MAX(CASE WHEN dow = 1 THEN dy_mth END) AS Mo,
       MAX(CASE WHEN dow = 2 THEN dy_mth END) AS Tu,
       MAX(CASE WHEN dow = 3 THEN dy_mth END) AS We,
       MAX(CASE WHEN dow = 4 THEN dy_mth END) AS Th,
       MAX(CASE WHEN dow = 5 THEN dy_mth END) AS Fr,
       MAX(CASE WHEN dow = 6 THEN dy_mth END) AS Sa,
       MAX(CASE WHEN dow = 0 THEN dy_mth END) AS Su
  FROM temp
 GROUP BY wk
 ORDER BY wk;
```

### Solution 2

Use the function `GENERATE_SERIES` to return every day in the current month. Then pivot on the day of the week using `MAX` and `CASE`:


```SQL
WITH firstDate AS (
  SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS dy
),
t1 AS (
  SELECT dy,
         EXTRACT('DAY' FROM dy) AS dy_mth,
         EXTRACT('MONTH' FROM dy)::INTEGER AS mth,
         EXTRACT('DOW' FROM dy) AS dow,
         EXTRACT('WEEK' FROM dy) AS wk
    FROM firstDate
),
t2 AS (
  SELECT dy + (x.id) AS dy,
         mth AS curr_mth,
         EXTRACT('DAY' FROM dy + x.id)::INTEGER AS dy_mth,
         EXTRACT('MONTH' FROM dy + x.id)::INTEGER AS mth,
         EXTRACT('DOW' FROM dy + x.id)::INTEGER AS dow,
         EXTRACT('WEEK' FROM dy + x.id)::INTEGER AS wk
    FROM t1, GENERATE_SERIES(0,31) x(id)
)
SELECT MAX(CASE WHEN dow = 1 THEN dy_mth END) AS Mo,
       MAX(CASE WHEN dow = 2 THEN dy_mth END) AS Tu,
       MAX(CASE WHEN dow = 3 THEN dy_mth END) AS We,
       MAX(CASE WHEN dow = 4 THEN dy_mth END) AS Th,
       MAX(CASE WHEN dow = 5 THEN dy_mth END) AS Fr,
       MAX(CASE WHEN dow = 6 THEN dy_mth END) AS Sa,
       MAX(CASE WHEN dow = 0 THEN dy_mth END) AS Su
  FROM t2
 WHERE mth = curr_mth
 GROUP BY wk
 ORDER BY wk;
```


## Discussion

- **Solution 1**:


```SQL
WITH RECURSIVE temp AS (
  SELECT dy,
         EXTRACT('DAY' FROM dy) AS dy_mth,
         EXTRACT('MONTH' FROM dy) AS mth,
         EXTRACT('DOW' FROM dy) AS dow,
         EXTRACT('WEEK' FROM dy) AS wk
    FROM (SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS dy) t
  UNION ALL
  SELECT dy + 1,
         EXTRACT('DAY' FROM dy + 1) AS dy_mth,
         EXTRACT('MONTH' FROM dy + 1) AS mth,
         EXTRACT('DOW' FROM dy + 1) AS dow,
         EXTRACT('WEEK' FROM dy + 1) AS wk
    FROM temp
   WHERE EXTRACT('MONTH' FROM dy + 1) = mth
)
```


The first step is to return each day in the month for which you want to create a calendar. Do that using the `recursive WITH clause`. Along with each day of the month (`DY_MTH`), you will need to return different parts of each date: the day of the week (`DOW`), the current month you are working with (`MTH`), and the ISO week for each day of the month (`WK`).

The results of the recursive view `temp` prior to recursion taking place (the upper portion of the `UNION ALL`), also known as `BASE CASE` are shown here:


```SQL
WITH t AS (
  SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS first_date
)
SELECT first_date,
       EXTRACT('DAY' FROM first_date) AS day_month,
       EXTRACT('MONTH' FROM first_date) AS month,
       EXTRACT('DOW' FROM first_date) AS dow,
       EXTRACT('WEEK' FROM first_date) AS wk
  FROM t;
```

|first_date | day_month | month | dow | wk|
|:---------:|:---------:|:-----:|:----:|:---:|
|2022-08-01 |         1 |     8 |   1 | 31|

The first day of the current month is `2022-08-01`, the day part is `1`, month `8` and day of the week is `1` and corresponds to `Monday`, see the doc of `DOW`. Lastly, the number `31` indicates the 31st week of this year.



```SQL
WITH RECURSIVE temp AS (
  SELECT dy,
         EXTRACT('DAY' FROM dy) AS dy_mth,
         EXTRACT('MONTH' FROM dy) AS mth,
         EXTRACT('DOW' FROM dy) AS dow,
         EXTRACT('WEEK' FROM dy) AS wk
    FROM (SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS dy) t
  UNION ALL
  SELECT dy + 1,
         EXTRACT('DAY' FROM dy + 1) AS dy_mth,
         EXTRACT('MONTH' FROM dy + 1) AS mth,
         EXTRACT('DOW' FROM dy + 1) AS dow,
         EXTRACT('WEEK' FROM dy + 1) AS wk
    FROM temp
   WHERE EXTRACT('MONTH' FROM dy + 1) = mth
)
SELECT *
  FROM temp;
```

The next step is to repeatedly increase the value for `dy` (move through the days of the month) until you are no longer in the current month `EXTRACT('MONTH' FROM dy + 1) = mth`. As you move through each day in the month, you will also return the day of the week that each day is, and which ISO week the current day of the month falls into.

Partial results are shown here:

```console
|dy         | dy_mth | mth | dow | wk|
|:---------:|:------:|:---:|:---:|:--:|
|2022-08-01 |      1 |   8 |   1 | 31|
|2022-08-02 |      2 |   8 |   2 | 31|
|2022-08-03 |      3 |   8 |   3 | 31|
|2022-08-04 |      4 |   8 |   4 | 31|
|2022-08-05 |      5 |   8 |   5 | 31|
|2022-08-06 |      6 |   8 |   6 | 31|
|2022-08-07 |      7 |   8 |   0 | 31|
-------------------------------------------
|2022-08-08 |      8 |   8 |   1 | 32|
|2022-08-09 |      9 |   8 |   2 | 32|
|2022-08-10 |     10 |   8 |   3 | 32|
|2022-08-11 |     11 |   8 |   4 | 32|
|2022-08-12 |     12 |   8 |   5 | 32|
|2022-08-13 |     13 |   8 |   6 | 32|
|2022-08-14 |     14 |   8 |   0 | 32|
---------------------------------------------
|2022-08-15 |     15 |   8 |   1 | 33|
|2022-08-16 |     16 |   8 |   2 | 33|
|2022-08-17 |     17 |   8 |   3 | 33|
|2022-08-18 |     18 |   8 |   4 | 33|
|2022-08-19 |     19 |   8 |   5 | 33|
|2022-08-20 |     20 |   8 |   6 | 33|
|2022-08-21 |     21 |   8 |   0 | 33|
---------------------------------------------
|2022-08-22 |     22 |   8 |   1 | 34|
|2022-08-23 |     23 |   8 |   2 | 34|
|2022-08-24 |     24 |   8 |   3 | 34|
|2022-08-25 |     25 |   8 |   4 | 34|
|2022-08-26 |     26 |   8 |   5 | 34|
|2022-08-27 |     27 |   8 |   6 | 34|
|2022-08-28 |     28 |   8 |   0 | 34|
------------------------------------------
|2022-08-29 |     29 |   8 |   1 | 35|
|2022-08-30 |     30 |   8 |   2 | 35|
|2022-08-31 |     31 |   8 |   3 | 35|
```

**(31 rows)**

The results are partitioned by `wk`.

```SQL
WITH RECURSIVE temp AS (
  SELECT dy,
         EXTRACT('DAY' FROM dy) AS dy_mth,
         EXTRACT('MONTH' FROM dy) AS mth,
         EXTRACT('DOW' FROM dy) AS dow,
         EXTRACT('WEEK' FROM dy) AS wk
    FROM (SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS dy) t
  UNION ALL
  SELECT dy + 1,
         EXTRACT('DAY' FROM dy + 1) AS dy_mth,
         EXTRACT('MONTH' FROM dy + 1) AS mth,
         EXTRACT('DOW' FROM dy + 1) AS dow,
         EXTRACT('WEEK' FROM dy + 1) AS wk
    FROM temp
   WHERE EXTRACT('MONTH' FROM dy + 1) = mth
)
SELECT wk,
       CASE WHEN dow = 1 THEN dy_mth END AS Mo,
       CASE WHEN dow = 2 THEN dy_mth END AS Tu,
       CASE WHEN dow = 3 THEN dy_mth END AS We,
       CASE WHEN dow = 4 THEN dy_mth END AS Th,
       CASE WHEN dow = 5 THEN dy_mth END AS Fr,
       CASE WHEN dow = 6 THEN dy_mth END AS Sa,
       CASE WHEN dow = 0 THEN dy_mth END AS Su
  FROM temp;
```
The resulting table will have 8 eight columns:

- `wk`, `Mo`, `Tu`, `We`, `Th`, `Fr`, `Sa`, `Su`.

On the basis of the `CASE` clause the columns' field will be the date of the recursive procedure or `NULL`.

```console
              Output
   +----------------------------------+----------------------------------+            
   |            dow                   |                      temp        V
--------------------------------------+    +-------------------------------------+
wk | mo | tu | we | th | fr | sa | su |    |dy         | dy_mth | mth | dow | wk |
----+----+----+----+----+----+----+---|    |:---------:|:------:|:---:|:---:|:--:|
31 |  1 |    |    |    |    |    |    |<-  |2022-08-01 |      1 |   8 |   1 | 31 |
31 |    |  2 |    |    |    |    |    |<-  |2022-08-02 |      2 |   8 |   2 | 31 |
31 |    |    |  3 |    |    |    |    |<-  |2022-08-03 |      3 |   8 |   3 | 31 |
31 |    |    |    |  4 |    |    |    |<-  |2022-08-04 |      4 |   8 |   4 | 31 |
31 |    |    |    |    |  5 |    |    |<-  |2022-08-05 |      5 |   8 |   5 | 31 |
31 |    |    |    |    |    |  6 |    |<-  |2022-08-06 |      6 |   8 |   6 | 31 |
31 |    |    |    |    |    |    |  7 |<-  |2022-08-07 |      7 |   8 |   0 | 31 |
---------------------------------------    ---------------------------------------
             WEEK 32
---------------------------------------
32 |  8 |    |    |    |    |    |    |      .....       .....     ...   ...  ...
32 |    |  9 |    |    |    |    |    |
32 |    |    | 10 |    |    |    |    |
32 |    |    |    | 11 |    |    |    |
32 |    |    |    |    | 12 |    |    |
32 |    |    |    |    |    | 13 |    |
32 |    |    |    |    |    |    | 14 |
---------------------------------------
              WEEK 33
---------------------------------------
33 | 15 |    |    |    |    |    |    |
33 |    | 16 |    |    |    |    |    |
33 |    |    | 17 |    |    |    |    |
33 |    |    |    | 18 |    |    |    |
33 |    |    |    |    | 19 |    |    |
33 |    |    |    |    |    | 20 |    |
33 |    |    |    |    |    |    | 21 |
---------------------------------------
              WEEK 34
---------------------------------------
34 | 22 |    |    |    |    |    |    |
34 |    | 23 |    |    |    |    |    |
34 |    |    | 24 |    |    |    |    |
34 |    |    |    | 25 |    |    |    |
34 |    |    |    |    | 26 |    |    |
34 |    |    |    |    |    | 27 |    |
34 |    |    |    |    |    |    | 28 |
---------------------------------------
              WEEK 35
----------------------------------------
35 | 29 |    |    |    |    |    |    |
35 |    | 30 |    |    |    |    |    |
35 |    |    | 31 |    |    |    |    |
```

**31 rows**

As you can see from the partial output, every day in each week is returned as a row. What you want to do now is
- **to group the days by week** `wk`, and then
- **collapse all the days for each week into a single row**.

```console
Output
+----------------------------------+----------------------------------+            
|            dow                   |                      temp        V
--------------------------------------+    +-------------------------------------+
wk | mo | tu | we | th | fr | sa | su |    |dy         | dy_mth | mth | dow | wk |
----+----+----+----+----+----+----+---|    |:---------:|:------:|:---:|:---:|:--:|
31 |  1 |    |    |    |    |    |    |<-  |2022-08-01 |      1 |   8 |   1 | 31 |
31 |    |  2 |    |    |    |    |    |<-  |2022-08-02 |      2 |   8 |   2 | 31 |
31 |    |    |  3 |    |    |    |    |<-  |2022-08-03 |      3 |   8 |   3 | 31 |
31 |    |    |    |  4 |    |    |    |<-  |2022-08-04 |      4 |   8 |   4 | 31 |
31 |    |    |    |    |  5 |    |    |<-  |2022-08-05 |      5 |   8 |   5 | 31 |
31 |    |    |    |    |    |  6 |    |<-  |2022-08-06 |      6 |   8 |   6 | 31 |
31 |    |    |    |    |    |    |  7 |<-  |2022-08-07 |      7 |   8 |   0 | 31 |
---------------------------------------    ---------------------------------------
31 |  1 |  2 |  3 |  4 |  5 |  6 |  7 | 'mo' MAX(1,NULL,NULL,NULL,NULL,NULL,NULL)=1
--------------------------------------- 'tu' MAX(NULL,2,NULL,NULL,NULL,NULL,NULL)=2
32 |  8 |    |    |    |    |    |    | 'we' MAX(NULL,NULL,3,NULL,NULL,NULL,NULL)=3
32 |    |  9 |    |    |    |    |    | 'th' MAX(NULL,NULL,NULL,4,NULL,NULL,NULL)=4
32 |    |    | 10 |    |    |    |    | 'fr' MAX(NULL,NULL,NULL,NULL,5,NULL,NULL)=5
32 |    |    |    | 11 |    |    |    | 'sa' MAX(NULL,NULL,NULL,NULL,NULL,6,NULL)=6
32 |    |    |    |    | 12 |    |    | 'su' MAX(NULL,NULL,NULL,NULL,NULL,NULL,7)=7
32 |    |    |    |    |    | 13 |    |
32 |    |    |    |    |    |    | 14 |
---------------------------------------
32 |  8 |  9 | 10 | 11 | 12 | 13 | 14 | <---- SECOND GROUP WEEK 32
---------------------------------------
33 | 15 |    |    |    |    |    |    |
33 |    | 16 |    |    |    |    |    |
33 |    |    | 17 |    |    |    |    |
33 |    |    |    | 18 |    |    |    |
33 |    |    |    |    | 19 |    |    |
33 |    |    |    |    |    | 20 |    |
33 |    |    |    |    |    |    | 21 |
---------------------------------------
33 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | <----- THIRD GROUP WEEK 33
---------------------------------------
34 | 22 |    |    |    |    |    |    |
34 |    | 23 |    |    |    |    |    |
34 |    |    | 24 |    |    |    |    |
34 |    |    |    | 25 |    |    |    |
34 |    |    |    |    | 26 |    |    |
34 |    |    |    |    |    | 27 |    |
34 |    |    |    |    |    |    | 28 |
---------------------------------------
34 | 22 | 23 | 24 | 25 | 26 | 27 | 28 | <------ FOURTH GROUP WEEK 34
----------------------------------------
35 | 29 |    |    |    |    |    |    |
35 |    | 30 |    |    |    |    |    |
35 |    |    | 31 |    |    |    |    |
-----------------------------------------
35 | 29 | 30 | 31 |    |    |    |    | <------ FIFTH GROUP WEEK 35
```

Use the aggregate function `MAX`, and `group by WK` (the ISO week) to return all the days for a week as `one row`. To properly format the calendar and ensure that the days are in the right order, order the results by WK.


```SQL
WITH RECURSIVE temp AS (
  SELECT dy,
         EXTRACT('DAY' FROM dy) AS dy_mth,
         EXTRACT('MONTH' FROM dy) AS mth,
         EXTRACT('DOW' FROM dy) AS dow,
         EXTRACT('WEEK' FROM dy) AS wk
    FROM (SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS dy) t
  UNION ALL
  SELECT dy + 1,
         EXTRACT('DAY' FROM dy + 1) AS dy_mth,
         EXTRACT('MONTH' FROM dy + 1) AS mth,
         EXTRACT('DOW' FROM dy + 1) AS dow,
         EXTRACT('WEEK' FROM dy + 1) AS wk
    FROM temp
   WHERE EXTRACT('MONTH' FROM dy + 1) = mth
)
SELECT MAX(CASE WHEN dow = 1 THEN dy_mth END) AS Mo,
       MAX(CASE WHEN dow = 2 THEN dy_mth END) AS Tu,
       MAX(CASE WHEN dow = 3 THEN dy_mth END) AS We,
       MAX(CASE WHEN dow = 4 THEN dy_mth END) AS Th,
       MAX(CASE WHEN dow = 5 THEN dy_mth END) AS Fr,
       MAX(CASE WHEN dow = 6 THEN dy_mth END) AS Sa,
       MAX(CASE WHEN dow = 0 THEN dy_mth END) AS Su
  FROM temp
 GROUP BY wk
 ORDER BY wk;
```

The final output is shown here:

|mo | tu | we | th | fr | sa | su|
|:-:|:--:|:---:|:--:|:--:|:---:|:---:|
| 1 |  2 |  3 |  4 |  5 |  6 |  7|
| 8 |  9 | 10 | 11 | 12 | 13 | 14|
|15 | 16 | 17 | 18 | 19 | 20 | 21|
|22 | 23 | 24 | 25 | 26 | 27 | 28|
|29 | 30 | 31 |    |    |    ||

|mo | tu | we |  th  |  fr  |  sa  |  su|
|:-:|:--:|:--:|:----:|:----:|:----:|:----:|
| 1 |  2 |  3 |    4 |    5 |    6 |    7|
| 8 |  9 | 10 |   11 |   12 |   13 |   14|
|15 | 16 | 17 |   18 |   19 |   20 |   21|
|22 | 23 | 24 |   25 |   26 |   27 |   28|
|29 | 30 | 31 | NULL | NULL | NULL | NULL|


- **Solution 2**:

This solution is the same except for differences in the algorithm used to generate dates.

```SQL
WITH firstDate AS (
  SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS dy
),
t1 AS (
  SELECT dy,
         EXTRACT('DAY' FROM dy) AS dy_mth,
         EXTRACT('MONTH' FROM dy)::INTEGER AS mth,
         EXTRACT('DOW' FROM dy) AS dow,
         EXTRACT('WEEK' FROM dy) AS wk
    FROM firstDate
)
SELECT *
  FROM t1, GENERATE_SERIES(0,31) x(id);
```

```console
dy          | dy_mth | mth | dow | wk | id
------------+--------+-----+-----+----+----
2022-08-01  |      1 |   8 |   1 | 31 |  0
2022-08-01  |      1 |   8 |   1 | 31 |  1
2022-08-01  |      1 |   8 |   1 | 31 |  2
2022-08-01  |      1 |   8 |   1 | 31 |  3
2022-08-01  |      1 |   8 |   1 | 31 |  4
2022-08-01  |      1 |   8 |   1 | 31 |  5
2022-08-01  |      1 |   8 |   1 | 31 |  6
2022-08-01  |      1 |   8 |   1 | 31 |  7
2022-08-01  |      1 |   8 |   1 | 31 |  8
2022-08-01  |      1 |   8 |   1 | 31 |  9
2022-08-01  |      1 |   8 |   1 | 31 | 10
2022-08-01  |      1 |   8 |   1 | 31 | 11
2022-08-01  |      1 |   8 |   1 | 31 | 12
2022-08-01  |      1 |   8 |   1 | 31 | 13
2022-08-01  |      1 |   8 |   1 | 31 | 14
2022-08-01  |      1 |   8 |   1 | 31 | 15
2022-08-01  |      1 |   8 |   1 | 31 | 16
2022-08-01  |      1 |   8 |   1 | 31 | 17
2022-08-01  |      1 |   8 |   1 | 31 | 18
2022-08-01  |      1 |   8 |   1 | 31 | 19
2022-08-01  |      1 |   8 |   1 | 31 | 20
2022-08-01  |      1 |   8 |   1 | 31 | 21
2022-08-01  |      1 |   8 |   1 | 31 | 22
2022-08-01  |      1 |   8 |   1 | 31 | 23
2022-08-01  |      1 |   8 |   1 | 31 | 24
2022-08-01  |      1 |   8 |   1 | 31 | 25
2022-08-01  |      1 |   8 |   1 | 31 | 26
2022-08-01  |      1 |   8 |   1 | 31 | 27
2022-08-01  |      1 |   8 |   1 | 31 | 28
2022-08-01  |      1 |   8 |   1 | 31 | 29
2022-08-01  |      1 |   8 |   1 | 31 | 30
2022-08-01  |      1 |   8 |   1 | 31 | 31
```

```SQL
WITH firstDate AS (
  SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS dy
),
t1 AS (
  SELECT dy,
         EXTRACT('DAY' FROM dy) AS dy_mth,
         EXTRACT('MONTH' FROM dy)::INTEGER AS mth,
         EXTRACT('DOW' FROM dy) AS dow,
         EXTRACT('WEEK' FROM dy) AS wk
    FROM firstDate
)
SELECT dy + (x.id) AS dy,
       mth AS curr_mth,
       EXTRACT('DAY' FROM dy + x.id)::INTEGER AS dy_mth,
       EXTRACT('MONTH' FROM dy + x.id)::INTEGER AS mth,
       EXTRACT('DOW' FROM dy + x.id)::INTEGER AS dow,
       EXTRACT('WEEK' FROM dy + x.id)::INTEGER AS wk
  FROM t1, GENERATE_SERIES(0,31) x(id);
```

```console
dy         | curr_mth | dy_mth | mth | dow | wk
------------+----------+--------+-----+-----+----
2022-08-01 |        8 |      1 |   8 |   1 | 31
2022-08-02 |        8 |      2 |   8 |   2 | 31
2022-08-03 |        8 |      3 |   8 |   3 | 31
2022-08-04 |        8 |      4 |   8 |   4 | 31
2022-08-05 |        8 |      5 |   8 |   5 | 31
2022-08-06 |        8 |      6 |   8 |   6 | 31
2022-08-07 |        8 |      7 |   8 |   0 | 31
2022-08-08 |        8 |      8 |   8 |   1 | 32
2022-08-09 |        8 |      9 |   8 |   2 | 32
2022-08-10 |        8 |     10 |   8 |   3 | 32
2022-08-11 |        8 |     11 |   8 |   4 | 32
2022-08-12 |        8 |     12 |   8 |   5 | 32
2022-08-13 |        8 |     13 |   8 |   6 | 32
2022-08-14 |        8 |     14 |   8 |   0 | 32
2022-08-15 |        8 |     15 |   8 |   1 | 33
2022-08-16 |        8 |     16 |   8 |   2 | 33
2022-08-17 |        8 |     17 |   8 |   3 | 33
2022-08-18 |        8 |     18 |   8 |   4 | 33
2022-08-19 |        8 |     19 |   8 |   5 | 33
2022-08-20 |        8 |     20 |   8 |   6 | 33
2022-08-21 |        8 |     21 |   8 |   0 | 33
2022-08-22 |        8 |     22 |   8 |   1 | 34
2022-08-23 |        8 |     23 |   8 |   2 | 34
2022-08-24 |        8 |     24 |   8 |   3 | 34
2022-08-25 |        8 |     25 |   8 |   4 | 34
2022-08-26 |        8 |     26 |   8 |   5 | 34
2022-08-27 |        8 |     27 |   8 |   6 | 34
2022-08-28 |        8 |     28 |   8 |   0 | 34
2022-08-29 |        8 |     29 |   8 |   1 | 35
2022-08-30 |        8 |     30 |   8 |   2 | 35
2022-08-31 |        8 |     31 |   8 |   3 | 35
2022-09-01 |        8 |      1 |   9 |   4 | 35
```
