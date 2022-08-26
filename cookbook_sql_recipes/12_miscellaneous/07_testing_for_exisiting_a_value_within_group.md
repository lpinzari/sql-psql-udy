# Testing for Existence of a Value Within a Group

You want to create a **Boolean flag** for a `row` depending on

- whether `any row` in **its group** `contains a specific value`.

## Problem

Consider an example of a student who has taken a certain number of exams during a period of time.

A student will take three exams over three months.
- If a student passes one of these exams, the requirement is satisfied and a flag should be returned to express that fact.
- If a student did not pass any of the three tests in the three-month period, then an additional flag should be returned to express that fact as well.

Consider the following example:

```SQL
CREATE VIEW v AS (
  SELECT 1 AS student_id,
         1 AS test_id,
         2 AS grade_id,
         1 AS period_id,
         '2020-02-01'::DATE AS test_date,
         0 AS pass_fail
  UNION ALL
  SELECT 1, 2, 2, 1, '2020-03-01'::DATE, 1 UNION ALL  
  SELECT 1, 3, 2, 1, '2020-04-01'::DATE, 0 UNION ALL  
  SELECT 1, 4, 2, 2, '2020-05-01'::DATE, 0 UNION ALL  
  SELECT 1, 5, 2, 2, '2020-06-01'::DATE, 0 UNION ALL  
  SELECT 1, 6, 2, 2, '2020-07-01'::DATE, 0  
);

SELECT * FROM v;
```

|student_id | test_id | grade_id | period_id | test_date  | pass_fail|
|:---------:|:-------:|:--------:|:----------:|:---------:|:--------:|
|         1 |       1 |        2 |         1 | 2020-02-01 |         0|
|         1 |       2 |        2 |         1 | 2020-03-01 |         1|
|         1 |       3 |        2 |         1 | 2020-04-01 |         0|
|         1 |       4 |        2 |         2 | 2020-05-01 |         0|
|         1 |       5 |        2 |         2 | 2020-06-01 |         0|
|         1 |       6 |        2 |         2 | 2020-07-01 |         0|

Examining the previous result set, you see that the student has taken six tests (`test_id`: **1** - **6**) over `two`, three-month periods (`period_id`: **1**,**2**). The student has passed one test (`pass_fail` **1** means “**pass**”; **0** means “**fail**”); thus, the requirement is satisfied for the entire first period.

Because the student did not pass any exams during the second period (the next three months), `PASS_FAIL` is **0** `for all three exams`. You want to return a result set that highlights whether a student has passed a test for a given period. Ultimately you want to return the following result set:

|student_id | test_id | grade_id | period_id | test_date  | metreq | in_progress|
|:---------:|:-------:|:--------:|:---------:|:----------:|:------:|:----------:|
|         1 |       1 |        2 |         1 | 2020-02-01 |      + |           0|
|         1 |       2 |        2 |         1 | 2020-03-01 |      + |           0|
|         1 |       3 |        2 |         1 | 2020-04-01 |      + |           0|
|         1 |       4 |        2 |         2 | 2020-05-01 |      - |           0|
|         1 |       5 |        2 |         2 | 2020-06-01 |      - |           0|
|         1 |       6 |        2 |         2 | 2020-07-01 |      - |           1|


The previous result set shows that the student passed at least one test during the first period; thus the entire group has value of `+` or **pass** for the `metreq`.

The next requirement is that if the student has not passed any tests in a period, return a value of `1` for the `IN_PROGESS` **flag** for **the latest test date in that group**.

## Solution

This problem appears tricky because you have to treat rows in a group as a group and not as individuals. Consider the values for `PASS_FAIL` in the “Problem” section.

By using the window function MAX OVER, you can easily determine whether a student passed at least one test during a particular period. Once you have that information, the “Boolean” values are a simple matter of using `CASE` expressions:

```SQL
WITH t AS (
  SELECT v.*,
         MAX(pass_fail) OVER(PARTITION BY student_id, grade_id, period_id) AS grp_pass_fail,
         MAX(test_date) OVER(PARTITION BY student_id, grade_id, period_id) AS last_test
    FROM v
)
SELECT student_id,
       test_id,
       grade_id,
       period_id,
       test_date,
       CASE WHEN grp_pass_fail = 1 THEN LPAD('+',6) ELSE LPAD('-',6) END AS metreq,
       CASE WHEN grp_pass_fail = 0
            THEN CASE WHEN test_date = last_test
                      THEN 1 ELSE 0
                      END
            ELSE 0
       END AS in_progress
  FROM t;
```

## Discussion

The key to the solution is using the window function `MAX OVER` to return the greatest value of `PASS_FAIL` for each group. Because the values for `PASS_FAIL` are only **1** or **0**, if a student `passed at least one exam`, then `MAX OVER` would return **1** for the entire group. How this works is shown here:

```SQL
SELECT v.*,
       MAX(pass_fail) OVER(PARTITION BY student_id, grade_id, period_id) grp_pass_fail
  FROM v;
```

```console
student_id | test_id | grade_id | period_id | test_date  | pass_fail | grp_pass_fail
-----------+---------+----------+-----------+------------+-----------+---------------
         1 |       1 |        2 |         1 | 2020-02-01 |         0 |             1
         1 |       2 |        2 |         1 | 2020-03-01 |         1 |             1
         1 |       3 |        2 |         1 | 2020-04-01 |         0 |             1
         -----------------------------------------------------------------------------
         1 |       4 |        2 |         2 | 2020-05-01 |         0 |             0
         1 |       5 |        2 |         2 | 2020-06-01 |         0 |             0
         1 |       6 |        2 |         2 | 2020-07-01 |         0 |             0
```

The previous result set shows that the student passed at least one test during the first period; thus the entire group has value of `1` or **pass**.

The next requirement is that if the student has not passed any tests in a period, return a value of `1` for the `IN_PROGESS` **flag** for **the latest test date in that group**. You can use the window function `MAX OVER` to do this as well:

```SQL
SELECT v.*,
       MAX(pass_fail) OVER(PARTITION BY student_id, grade_id, period_id) AS grp_pass_fail,
       MAX(test_date) OVER(PARTITION BY student_id, grade_id, period_id) AS last_test
  FROM v;
```

```console
student_id | test_id | grade_id | period_id | test_date  | pass_fail | grp_pass_fail | last_test
------------+---------+----------+-----------+------------+-----------+---------------+------------
         1 |       1 |        2 |         1 | 2020-02-01 |         0 |             1 | 2020-04-01
         1 |       2 |        2 |         1 | 2020-03-01 |         1 |             1 | 2020-04-01
         1 |       3 |        2 |         1 | 2020-04-01 |         0 |             1 | 2020-04-01
         ----------------------------------------------------------------------------
         1 |       4 |        2 |         2 | 2020-05-01 |         0 |             0 | 2020-07-01
         1 |       5 |        2 |         2 | 2020-06-01 |         0 |             0 | 2020-07-01
         1 |       6 |        2 |         2 | 2020-07-01 |         0 |             0 | 2020-07-01
```


Now that you have determined for which period the student has passed a test and what the latest test date for each period is, the last step is simply a matter of applying some formatting magic to make the result set look nice.

```SQL
WITH t AS (
  SELECT v.*,
         MAX(pass_fail) OVER(PARTITION BY student_id, grade_id, period_id) AS grp_pass_fail,
         MAX(test_date) OVER(PARTITION BY student_id, grade_id, period_id) AS last_test
    FROM v
)
SELECT student_id,
       test_id,
       grade_id,
       period_id,
       test_date,
       CASE WHEN grp_pass_fail = 1 THEN LPAD('+',6) ELSE LPAD('-',6) END AS metreq,
       CASE WHEN grp_pass_fail = 0
            THEN CASE WHEN test_date = last_test
                      THEN 1 ELSE 0
                      END
            ELSE 0
       END AS in_progress
  FROM t;
```

|student_id | test_id | grade_id | period_id | test_date  | metreq | in_progress|
|:---------:|:-------:|:--------:|:---------:|:----------:|:------:|:----------:|
|         1 |       1 |        2 |         1 | 2020-02-01 |      + |           0|
|         1 |       2 |        2 |         1 | 2020-03-01 |      + |           0|
|         1 |       3 |        2 |         1 | 2020-04-01 |      + |           0|
|         1 |       4 |        2 |         2 | 2020-05-01 |      - |           0|
|         1 |       5 |        2 |         2 | 2020-06-01 |      - |           0|
|         1 |       6 |        2 |         2 | 2020-07-01 |      - |           1|
