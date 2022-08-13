# Determining the Number of Business Days Between Two Dates 2

Find the number of business days between the `HIREDATE` of an employee and the `HIREDATE` of all other employees in the `emp` table.

## Problem

Find the number of business days between the HIREDATEs of `BLAKE` and all the employees in the `emp` table.

For this recipe, a “**business day**” is defined as:
- any day that is not `Saturday` or `Sunday`.


```console
cookbook=> \d emp
                        Table "public.emp"
  Column  |         Type          | Collation | Nullable | Default
----------+-----------------------+-----------+----------+---------
 empno    | integer               |           | not null |
 ename    | character varying(10) |           |          |
 job      | character varying(9)  |           |          |
 mgr      | integer               |           |          |
 hiredate | date                  |           |          |
 sal      | integer               |           |          |
 comm     | integer               |           |          |
 deptno   | integer               |           |          |
Indexes:
    "emp_pkey" PRIMARY KEY, btree (empno)
```

```SQL
SELECT empno, ename, hiredate FROM emp;
```

|empno | ename  |  hiredate|
|:----:|:------:|:----------:|
| 7369 | SMITH  | 2015-12-17|
| 7499 | ALLEN  | 2006-01-20|
| 7521 | WARD   | 2006-02-22|
| 7566 | JONES  | 2006-04-02|
| 7654 | MARTIN | 2006-09-28|
| 7698 | BLAKE  | 2006-05-01|
| 7782 | CLARK  | 2006-06-09|
| 7788 | SCOTT  | 2007-12-09|
| 7839 | KING   | 2006-11-17|
| 7844 | TURNER | 2006-09-08|
| 7876 | ADAMS  | 2008-01-12|
| 7900 | JAMES  | 2006-12-03|
| 7902 | FORD   | 2006-12-03|
| 7934 | MILLER | 2007-01-23|

**Output**


|ename2 |  blake_hr  |    hr2     | b_day|
|:-----:|:-----------:|:---------:|:-------|
|ALLEN  | 2006-05-01 | 2006-01-20 |   -71|
|WARD   | 2006-05-01 | 2006-02-22 |   -48|
|JONES  | 2006-05-01 | 2006-04-02 |   -20|
|**BLAKE**  | **2006-05-01** | **2006-05-01** |     **0**|
|CLARK  | 2006-05-01 | 2006-06-09 |    29|
|TURNER | 2006-05-01 | 2006-09-08 |    94|
|MARTIN | 2006-05-01 | 2006-09-28 |   108|
|KING   | 2006-05-01 | 2006-11-17 |   144|
|FORD   | 2006-05-01 | 2006-12-03 |   155|
|JAMES  | 2006-05-01 | 2006-12-03 |   155|
|MILLER | 2006-05-01 | 2007-01-23 |   191|
|SCOTT  | 2006-05-01 | 2007-12-09 |   420|
|ADAMS  | 2006-05-01 | 2008-01-12 |   445|
|SMITH  | 2006-05-01 | 2015-12-17 |  2513|

The Resulting table must have 4 columns:

- `ename2`: the name of the employee, including the name of `BLAKE`.
- `blake_hr`: the hiredate of the employee `BLAKE`. (`2006-05-01`)
- `hr2`: the hiredate of the employee in column `ename2`. For example, the employee `ALLEN` in the first row has been hired in `2006-01-20`.
- `b_day`: A negative or positive integer value indicating the number of business days between the hiring date of `BLAKE` and the hiring date of the employee in column `ename2`.
  - A negative value indicates that an employee has been hired before the hiring date of  `BLAKE`.For example, the employee `ALLEN` has been hired `71 business days before` (**-71**) the hiring date of `BLAKE`.
  - On the other hand, a positive value indicates that an employee has been hired after the hiring date of `BLAKE`. For instance, the employee `KING` has been hired `144 days after`(**144**) the hiring date of `BLAKE`. It's clear that the value of `b_day` for `BLAKE` must be zero.

The result must be sorted in ascending order of `b_day`.


## Solution

- **Solution 1**:

```SQL
CREATE FUNCTION BDAY_DIFF(end_d DATE, start_d DATE)
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
    n INTEGER :=  end_d - start_d;
    cnt INTEGER := 0;
    dow VARCHAR(15);
BEGIN
    FOR iter in 1..n loop
        dow = TRIM(TO_CHAR(start_d + iter - 1,'DAY'));
        IF dow != 'SATURDAY' AND dow != 'SUNDAY'
           THEN cnt := cnt + 1;
        END IF;
    END LOOP;
    RETURN cnt;
END;
$$;
```
```SQL
WITH blk_hrs AS (
 SELECT e2.ename ename2, e1.hiredate blake_hr, e2.hiredate hr2
   FROM emp e1, emp e2
  WHERE e1.ename = 'BLAKE'
  ORDER BY e1.ename, hr2
)
SELECT b.*,
       CASE WHEN blake_hr > hr2 THEN -1 * BDAY_DIFF(blake_hr,hr2)
            WHEN blake_hr < hr2 THEN BDAY_DIFF(hr2,blake_hr)
            ELSE 0
       END AS b_day
  FROM blk_hrs b
 ORDER BY b_day;
```

- **Solution 2**:

```SQL
WITH blk_hrs AS (
 SELECT e2.empno,e2.ename ename2, e1.hiredate blake_hr, e2.hiredate hr2
   FROM emp e1, emp e2
  WHERE e1.ename = 'BLAKE'
  ORDER BY e1.ename, hr2
),
maxDays AS (
  SELECT MAX(hiredate) - MIN(hiredate) AS t_max
    FROM emp
),
idDays AS (
  SELECT generate_series(1,t_max) AS n
    FROM maxDays
)
SELECT b1.ename2, b1.blake_hr, b1.hr2,
       (SELECT CASE WHEN (SUM(CASE WHEN b1.blake_hr > b1.hr2
                        THEN CASE WHEN TRIM(TO_CHAR(b1.hr2 + n - 1,'DAY')) IN ('SATURDAY','SUNDAY') THEN 0 ELSE -1
                              END
                        WHEN b1.blake_hr < b1.hr2
                        THEN CASE WHEN TRIM(TO_CHAR(b1.blake_hr + n - 1,'DAY')) IN
                       ('SATURDAY','SUNDAY') THEN 0 ELSE 1
                              END
                        ELSE 0
                    END)) IS NULL THEN 0
                    ELSE  (SUM(CASE WHEN b1.blake_hr > b1.hr2
                                     THEN CASE WHEN TRIM(TO_CHAR(b1.hr2 + n - 1,'DAY')) IN ('SATURDAY','SUNDAY') THEN 0 ELSE -1
                                           END
                                     WHEN b1.blake_hr < b1.hr2
                                     THEN CASE WHEN TRIM(TO_CHAR(b1.blake_hr + n - 1,'DAY')) IN
                                    ('SATURDAY','SUNDAY') THEN 0 ELSE 1
                                           END
                                     ELSE 0
                                 END))
                    END AS b_day
          FROM idDays
         WHERE idDays.n < (SELECT CASE WHEN b1.blake_hr >= b1.hr2
                                       THEN b1.blake_hr - b1.hr2 +1
                                       ELSE b1.hr2 - b1.blake_hr + 1
                                  END)       
        )
  FROM blk_hrs b1, blk_hrs b2
 WHERE b1.empno = b2.empno
 ORDER BY b_day;
```




## Discussion


- Solution **Using a user defined function**:

The solution of this problem can be broken down in two parts:

1. Implement a function `BDAY(date1 DATE, date2 DATE)` to compute the number of business days between dates.
2. Apply the tthe **BDAY** function to the data in table emp and return the number of business days between the hire dates of all employees.


### Step 1:

```SQL
DO
$$
DECLARE
    start_d  DATE := '2022-01-01';
    end_d DATE := '2022-02-01';
    n INTEGER :=  end_d - start_d;
    cnt INTEGER := 0;
    dow VARCHAR(15);
BEGIN
    FOR iter in 1..n loop
        dow = TRIM(TO_CHAR(start_d + iter - 1,'DAY'));
        IF dow != 'SATURDAY' AND dow != 'SUNDAY'
           THEN cnt := cnt + 1;
           raise notice '%  %  counter: %',start_d + iter - 1, dow, cnt;
        END IF;
    END LOOP;
END;
$$;
```

Before the creation of the function `BDAY_DIFF` we test the procedural program first.

```console
NOTICE:  2022-01-03  MONDAY  counter: 1
NOTICE:  2022-01-04  TUESDAY  counter: 2
NOTICE:  2022-01-05  WEDNESDAY  counter: 3
NOTICE:  2022-01-06  THURSDAY  counter: 4
NOTICE:  2022-01-07  FRIDAY  counter: 5
NOTICE:  2022-01-10  MONDAY  counter: 6
NOTICE:  2022-01-11  TUESDAY  counter: 7
NOTICE:  2022-01-12  WEDNESDAY  counter: 8
NOTICE:  2022-01-13  THURSDAY  counter: 9
NOTICE:  2022-01-14  FRIDAY  counter: 10
NOTICE:  2022-01-17  MONDAY  counter: 11
NOTICE:  2022-01-18  TUESDAY  counter: 12
NOTICE:  2022-01-19  WEDNESDAY  counter: 13
NOTICE:  2022-01-20  THURSDAY  counter: 14
NOTICE:  2022-01-21  FRIDAY  counter: 15
NOTICE:  2022-01-24  MONDAY  counter: 16
NOTICE:  2022-01-25  TUESDAY  counter: 17
NOTICE:  2022-01-26  WEDNESDAY  counter: 18
NOTICE:  2022-01-27  THURSDAY  counter: 19
NOTICE:  2022-01-28  FRIDAY  counter: 20
NOTICE:  2022-01-31  MONDAY  counter: 21
DO
```

In the last step of the algorithm the counter value is equal to `21`. There are, therefore, `21` days between `2022-01-01` and `2022-02-01`.


```SQL
CREATE FUNCTION BDAY_DIFF(end_d DATE, start_d DATE)
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
    n INTEGER :=  end_d - start_d;
    cnt INTEGER := 0;
    dow VARCHAR(15);
BEGIN
    FOR iter in 1..n loop
        dow = TRIM(TO_CHAR(start_d + iter - 1,'DAY'));
        IF dow != 'SATURDAY' AND dow != 'SUNDAY'
           THEN cnt := cnt + 1;
        END IF;
    END LOOP;
    RETURN cnt;
END;
$$;
```

```console
CREATE FUNCTION
cookbook=> \df
                            List of functions
 Schema |   Name    | Result data type |   Argument data types    | Type
--------+-----------+------------------+--------------------------+------
 public | bday_diff | integer          | end_d date, start_d date | func
(1 row)
```


The next step is the creation of the function `BDAY_DIFF`.

```SQL
SELECT '2022-01-01'::DATE AS start_d,
       '2022-02-01'::DATE AS end_d,
       BDAY_DIFF('2022-02-01'::DATE,'2022-01-01'::DATE);
```

Following the creation of the function `BDAY_DIFF`, we test the function with a simple input as we did at the beginning of this section.

|start_d   |   end_d    | bday_diff|
|:---------:|:----------:|:---------:|
|2022-01-01 | 2022-02-01 |        21|

```SQL
WITH blk_hrs AS (
 SELECT e2.ename ename2, e1.hiredate blake_hr, e2.hiredate hr2
   FROM emp e1, emp e2
  WHERE e1.ename = 'BLAKE'
  ORDER BY e1.ename, hr2
)
SELECT *
  FROM blk_hrs;
```

Next, create a table with all employee's hire dates pair in order to apply the `BDAY_DIFF` function.

```console
ename2 |  blake_hr  |    hr2
--------+------------+------------
ALLEN  | 2006-05-01 | 2006-01-20
WARD   | 2006-05-01 | 2006-02-22
JONES  | 2006-05-01 | 2006-04-02
BLAKE  | 2006-05-01 | 2006-05-01 <----------
CLARK  | 2006-05-01 | 2006-06-09
TURNER | 2006-05-01 | 2006-09-08
MARTIN | 2006-05-01 | 2006-09-28
KING   | 2006-05-01 | 2006-11-17
FORD   | 2006-05-01 | 2006-12-03
JAMES  | 2006-05-01 | 2006-12-03
MILLER | 2006-05-01 | 2007-01-23
SCOTT  | 2006-05-01 | 2007-12-09
ADAMS  | 2006-05-01 | 2008-01-12
SMITH  | 2006-05-01 | 2015-12-17
```

```SQL
WITH blk_hrs AS (
 SELECT e2.ename ename2, e1.hiredate blake_hr, e2.hiredate hr2
   FROM emp e1, emp e2
  WHERE e1.ename = 'BLAKE'
  ORDER BY e1.ename, hr2
)
SELECT b.*,
       CASE WHEN blake_hr > hr2 THEN -1 * BDAY_DIFF(blake_hr,hr2)
            WHEN blake_hr < hr2 THEN BDAY_DIFF(hr2,blake_hr)
            ELSE 0
       END AS b_day
  FROM blk_hrs b
 ORDER BY b_day;
```

Finally, combine the two preceding steps.


### Solution 2


The solution can be broken down in three steps:

1. First create all the hiredates value pair with a CTE.
2. Second, create a pivot table big enough to count the number of business dates between the hiring dates in table emp. The size is determined as the difference between the maiximum and minimum value in the hiredate column.
3. Use a subquery to perform the calculation.


- **Step 1**

```SQL
WITH blk_hrs AS (
 SELECT e2.empno,e2.ename ename2, e1.hiredate blake_hr, e2.hiredate hr2
   FROM emp e1, emp e2
  WHERE e1.ename = 'BLAKE'
  ORDER BY e1.ename, hr2
)
SELECT *
  FROM blk_hrs;
```

|empno | ename2 |  blake_hr  |    hr2|
|:----:|:------:|:----------:|:---------:|
| 7499 | ALLEN  | 2006-05-01 | 2006-01-20|
| 7521 | WARD   | 2006-05-01 | 2006-02-22|
| 7566 | JONES  | 2006-05-01 | 2006-04-02|
| 7698 | BLAKE  | 2006-05-01 | 2006-05-01|
| 7782 | CLARK  | 2006-05-01 | 2006-06-09|
| 7844 | TURNER | 2006-05-01 | 2006-09-08|
| 7654 | MARTIN | 2006-05-01 | 2006-09-28|
| 7839 | KING   | 2006-05-01 | 2006-11-17|
| 7902 | FORD   | 2006-05-01 | 2006-12-03|
| 7900 | JAMES  | 2006-05-01 | 2006-12-03|
| 7934 | MILLER | 2006-05-01 | 2007-01-23|
| 7788 | SCOTT  | 2006-05-01 | 2007-12-09|
| 7876 | ADAMS  | 2006-05-01 | 2008-01-12|
| 7369 | SMITH  | 2006-05-01 | 2015-12-17|

- **Step 2**:

```SQL
WITH maxDays AS (
  SELECT MAX(hiredate) - MIN(hiredate) AS t_max
    FROM emp
)
SELECT *
  FROM maxDays;
```

|t_max|
|:---:|
| 3618|

This is the Upper Bound difference for our business days.


```SQL
WITH maxDays AS (
  SELECT MAX(hiredate) - MIN(hiredate) AS t_max
    FROM emp
),
idDays AS (
  SELECT generate_series(1,t_max) AS n
    FROM maxDays
)
SELECT *
  FROM idDays;
```

|n|
|:--:|
| 1|
| 2|
| 3|
| 4|
| ..|
| ..|
| 3618|


- **Step 3**

```SQL
WITH blk_hrs AS (
 SELECT e2.empno,e2.ename ename2, e1.hiredate blake_hr, e2.hiredate hr2
   FROM emp e1, emp e2
  WHERE e1.ename = 'BLAKE'
  ORDER BY e1.ename, hr2
)
SELECT b2.empno AS empno2, b1.*
  FROM blk_hrs b1, blk_hrs b2;
```

```console
empno2 | empno | ename2 |  blake_hr  |    hr2
--------+-------+--------+------------+------------
  7499 |  7499 | ALLEN  | 2006-05-01 | 2006-01-20 <--------
  --------------------------------------------------
  7521 |  7499 | ALLEN  | 2006-05-01 | 2006-01-20
  7566 |  7499 | ALLEN  | 2006-05-01 | 2006-01-20
  7698 |  7499 | ALLEN  | 2006-05-01 | 2006-01-20
  7782 |  7499 | ALLEN  | 2006-05-01 | 2006-01-20
  7844 |  7499 | ALLEN  | 2006-05-01 | 2006-01-20
  7654 |  7499 | ALLEN  | 2006-05-01 | 2006-01-20
  7839 |  7499 | ALLEN  | 2006-05-01 | 2006-01-20
  7902 |  7499 | ALLEN  | 2006-05-01 | 2006-01-20
  7900 |  7499 | ALLEN  | 2006-05-01 | 2006-01-20
  7934 |  7499 | ALLEN  | 2006-05-01 | 2006-01-20
  7788 |  7499 | ALLEN  | 2006-05-01 | 2006-01-20
  7876 |  7499 | ALLEN  | 2006-05-01 | 2006-01-20
  7369 |  7499 | ALLEN  | 2006-05-01 | 2006-01-20
----------------------------------------------------
  7499 |  7521 | WARD   | 2006-05-01 | 2006-02-22 <-------
---------------------------------------------------
  7521 |  7521 | WARD   | 2006-05-01 | 2006-02-22

```

```SQL
WITH blk_hrs AS (
 SELECT e2.empno,e2.ename ename2, e1.hiredate blake_hr, e2.hiredate hr2
   FROM emp e1, emp e2
  WHERE e1.ename = 'BLAKE'
  ORDER BY e1.ename, hr2
)
SELECT b1.*
  FROM blk_hrs b1, blk_hrs b2
 WHERE b1.empno = b2.empno;
```

```console
|empno | ename2 |  blake_hr  |    hr2|
|:----:|:------:|:----------:|:---------:|
| 7369 | SMITH  | 2006-05-01 | 2015-12-17|
| 7499 | ALLEN  | 2006-05-01 | 2006-01-20|
| 7521 | WARD   | 2006-05-01 | 2006-02-22|
| 7566 | JONES  | 2006-05-01 | 2006-04-02|
| 7654 | MARTIN | 2006-05-01 | 2006-09-28|
| 7698 | BLAKE  | 2006-05-01 | 2006-05-01|
| 7782 | CLARK  | 2006-05-01 | 2006-06-09|
| 7788 | SCOTT  | 2006-05-01 | 2007-12-09|
| 7839 | KING   | 2006-05-01 | 2006-11-17|
| 7844 | TURNER | 2006-05-01 | 2006-09-08|
| 7876 | ADAMS  | 2006-05-01 | 2008-01-12|
| 7900 | JAMES  | 2006-05-01 | 2006-12-03|
| 7902 | FORD   | 2006-05-01 | 2006-12-03|
| 7934 | MILLER | 2006-05-01 | 2007-01-23|
```


```SQL
WITH blk_hrs AS (
 SELECT e2.empno,e2.ename ename2, e1.hiredate blake_hr, e2.hiredate hr2
   FROM emp e1, emp e2
  WHERE e1.ename = 'BLAKE'
  ORDER BY e1.ename, hr2
),
maxDays AS (
  SELECT MAX(hiredate) - MIN(hiredate) AS t_max
    FROM emp
),
idDays AS (
  SELECT generate_series(1,t_max) AS n
    FROM maxDays
)
SELECT b1.ename2, b1.blake_hr, b1.hr2,
       (SELECT CASE WHEN (SUM(CASE WHEN b1.blake_hr > b1.hr2
                        THEN CASE WHEN TRIM(TO_CHAR(b1.hr2 + n - 1,'DAY')) IN ('SATURDAY','SUNDAY') THEN 0 ELSE -1
                              END
                        WHEN b1.blake_hr < b1.hr2
                        THEN CASE WHEN TRIM(TO_CHAR(b1.blake_hr + n - 1,'DAY')) IN
                       ('SATURDAY','SUNDAY') THEN 0 ELSE 1
                              END
                        ELSE 0
                    END)) IS NULL THEN 0
                    ELSE  (SUM(CASE WHEN b1.blake_hr > b1.hr2
                                     THEN CASE WHEN TRIM(TO_CHAR(b1.hr2 + n - 1,'DAY')) IN ('SATURDAY','SUNDAY') THEN 0 ELSE -1
                                           END
                                     WHEN b1.blake_hr < b1.hr2
                                     THEN CASE WHEN TRIM(TO_CHAR(b1.blake_hr + n - 1,'DAY')) IN
                                    ('SATURDAY','SUNDAY') THEN 0 ELSE 1
                                           END
                                     ELSE 0
                                 END))
                    END AS b_day
          FROM idDays
         WHERE idDays.n < (SELECT CASE WHEN b1.blake_hr >= b1.hr2
                                       THEN b1.blake_hr - b1.hr2 +1
                                       ELSE b1.hr2 - b1.blake_hr + 1
                                  END)       
        )
  FROM blk_hrs b1, blk_hrs b2
 WHERE b1.empno = b2.empno
 ORDER BY b_day;
```

You may have noticed the condition `IS NULL THEN 0`. This condition must handle the case `blake_hr` is equal to `hr2`. In this scenario the difference `b1.blake_hr - b1.hr2 + 1` in the `WHERE` clause is equal to 1 and `idDays.n` will not be `< 1`.


```console
|empno | ename2 |  blake_hr  |    hr2|                idDays
|:----:|:------:|:----------:|:---------:|  SUBQUERY  |n|     flag
| 7369 | SMITH  | 2006-05-01 | 2015-12-17|----------->|1|       1
| 7499 | ALLEN  | 2006-05-01 | 2006-01-20|            |2|      
| 7521 | WARD   | 2006-05-01 | 2006-02-22|            |3|
| 7566 | JONES  | 2006-05-01 | 2006-04-02|            |.|
| 7654 | MARTIN | 2006-05-01 | 2006-09-28|            |.|     
| 7698 | BLAKE  | 2006-05-01 | 2006-05-01|            
| 7782 | CLARK  | 2006-05-01 | 2006-06-09|            
| 7788 | SCOTT  | 2006-05-01 | 2007-12-09|            
| 7839 | KING   | 2006-05-01 | 2006-11-17|            
| 7844 | TURNER | 2006-05-01 | 2006-09-08|            
| 7876 | ADAMS  | 2006-05-01 | 2008-01-12|            
| 7900 | JAMES  | 2006-05-01 | 2006-12-03|            
| 7902 | FORD   | 2006-05-01 | 2006-12-03|            
| 7934 | MILLER | 2006-05-01 | 2007-01-23|
```

**n = 1**

```SQL
SELECT CASE WHEN '2006-05-01'::DATE > '2015-12-17'::DATE
            THEN TRIM(TO_CHAR(('2015-12-17'::DATE) + 1 - 1,'DAY'))
            WHEN '2006-05-01'::DATE < '2015-12-17'::DATE
            THEN TRIM(TO_CHAR(('2006-05-01'::DATE) + 1 - 1,'DAY'))
       END AS dow,
       CASE WHEN '2006-05-01'::DATE > '2015-12-17'::DATE
            THEN CASE WHEN TRIM(TO_CHAR(('2015-12-17'::DATE) + 1 - 1,'DAY')) IN ('SATURDAY','SUNDAY') THEN 0 ELSE -1
                 END
            WHEN '2006-05-01'::DATE < '2015-12-17'::DATE
            THEN CASE WHEN TRIM(TO_CHAR('2006-05-01'::DATE + 1 - 1,'DAY')) IN ('SATURDAY','SUNDAY') THEN 0 ELSE 1
                 END
            ELSE 0
       END AS flag;
```

|dow   | flag|
|:-----:|:----:|
|MONDAY |    1|

**n = 2**

```SQL
SELECT '2015-12-17'::DATE - '2006-05-01'::DATE + 1; -- 3518
```

```console
|empno | ename2 |  blake_hr  |    hr2|                idDays
|:----:|:------:|:----------:|:---------:|  SUBQUERY  |n|     flag
| 7369 | SMITH  | 2006-05-01 | 2015-12-17|-------+    |1|       1
| 7499 | ALLEN  | 2006-05-01 | 2006-01-20|       |--->|2|       1
| 7521 | WARD   | 2006-05-01 | 2006-02-22|            |3|       1
| 7566 | JONES  | 2006-05-01 | 2006-04-02|            |.|       .
| 7654 | MARTIN | 2006-05-01 | 2006-09-28|            |.|       .
| 7698 | BLAKE  | 2006-05-01 | 2006-05-01|            |3518|   
| 7782 | CLARK  | 2006-05-01 | 2006-06-09|            
| 7788 | SCOTT  | 2006-05-01 | 2007-12-09|            
| 7839 | KING   | 2006-05-01 | 2006-11-17|            
| 7844 | TURNER | 2006-05-01 | 2006-09-08|            
| 7876 | ADAMS  | 2006-05-01 | 2008-01-12|            
| 7900 | JAMES  | 2006-05-01 | 2006-12-03|            
| 7902 | FORD   | 2006-05-01 | 2006-12-03|            
| 7934 | MILLER | 2006-05-01 | 2007-01-23|
```

```SQL
SELECT CASE WHEN '2006-05-01'::DATE > '2015-12-17'::DATE
            THEN TRIM(TO_CHAR(('2015-12-17'::DATE) + 2 - 1,'DAY'))
            WHEN '2006-05-01'::DATE < '2015-12-17'::DATE
            THEN TRIM(TO_CHAR(('2006-05-01'::DATE) + 2 - 1,'DAY'))
       END AS dow,
       CASE WHEN '2006-05-01'::DATE > '2015-12-17'::DATE
            THEN CASE WHEN TRIM(TO_CHAR(('2015-12-17'::DATE) + 2 - 1,'DAY')) IN ('SATURDAY','SUNDAY') THEN 0 ELSE -1
                 END
            WHEN '2006-05-01'::DATE < '2015-12-17'::DATE
            THEN CASE WHEN TRIM(TO_CHAR('2006-05-01'::DATE + 2 - 1,'DAY')) IN ('SATURDAY','SUNDAY') THEN 0 ELSE -1
                 END
            ELSE 0
       END AS flag;
```

|dow   | flag|
|:------:|:---:|
|TUESDAY |   1|

```SQL
SELECT CASE WHEN '2006-05-01'::DATE > '2015-12-17'::DATE
            THEN TRIM(TO_CHAR(('2015-12-17'::DATE) + 3518 - 1,'DAY'))
            WHEN '2006-05-01'::DATE < '2015-12-17'::DATE
            THEN TRIM(TO_CHAR(('2006-05-01'::DATE) + 3518 - 1,'DAY'))
       END AS dow,
       CASE WHEN '2006-05-01'::DATE > '2015-12-17'::DATE
            THEN CASE WHEN TRIM(TO_CHAR(('2015-12-17'::DATE) + 3518 - 1,'DAY')) IN ('SATURDAY','SUNDAY') THEN 0 ELSE -1
                 END
            WHEN '2006-05-01'::DATE < '2015-12-17'::DATE
            THEN CASE WHEN TRIM(TO_CHAR('2006-05-01'::DATE + 3518 - 1,'DAY')) IN ('SATURDAY','SUNDAY') THEN 0 ELSE -1
                 END
            ELSE 0
       END AS flag;
```

|dow    | flag|
|:-------:|:-----:|
|THURSDAY |   1|

```console
|empno | ename2 |  blake_hr  |    hr2|                idDays
|:----:|:------:|:----------:|:---------:|  SUBQUERY  |n|     flag
| 7369 | SMITH  | 2006-05-01 | 2015-12-17|-------+    |1|       1
| 7499 | ALLEN  | 2006-05-01 | 2006-01-20|       |--->|2|       1
| 7521 | WARD   | 2006-05-01 | 2006-02-22|            |3|       1
| 7566 | JONES  | 2006-05-01 | 2006-04-02|            |.|       .
| 7654 | MARTIN | 2006-05-01 | 2006-09-28|            |.|       .
| 7698 | BLAKE  | 2006-05-01 | 2006-05-01|            |3518|    1
| 7782 | CLARK  | 2006-05-01 | 2006-06-09|                    ------
| 7788 | SCOTT  | 2006-05-01 | 2007-12-09|           SUM(flag) 2513
| 7839 | KING   | 2006-05-01 | 2006-11-17|            
| 7844 | TURNER | 2006-05-01 | 2006-09-08|            
| 7876 | ADAMS  | 2006-05-01 | 2008-01-12|            
| 7900 | JAMES  | 2006-05-01 | 2006-12-03|            
| 7902 | FORD   | 2006-05-01 | 2006-12-03|            
| 7934 | MILLER | 2006-05-01 | 2007-01-23|
```
