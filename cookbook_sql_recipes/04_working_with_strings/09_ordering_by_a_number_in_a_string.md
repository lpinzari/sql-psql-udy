# Ordering by a Number in a String

You want order your result set based on a number within a string.

Table **emp**:

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

Table **dept**:

```console
cookbook=> \d dept
                       Table "public.dept"
 Column |         Type          | Collation | Nullable | Default
--------+-----------------------+-----------+----------+---------
 deptno | integer               |           | not null |
 dname  | character varying(14) |           |          |
 loc    | character varying(13) |           |          |
Indexes:
    "dept_pkey" PRIMARY KEY, btree (deptno)
```


## Problem

Consider the following view:

```SQL
CREATE VIEW v AS
    SELECT e.ename || ' ' ||
           CAST(e.empno AS CHAR(4)) || ' ' ||
           d.dname AS data
      FROM emp e, dept d
     WHERE e.deptno = d.deptno;
```

This view returns the following data:

```SQL
SELECT * FROM v;
```

|data|
|:----------------------:|
|SMITH 7369 RESEARCH|
|ALLEN 7499 SALES|
|WARD 7521 SALES|
|JONES 7566 RESEARCH|
|MARTIN 7654 SALES|
|BLAKE 7698 SALES|
|CLARK 7782 ACCOUNTING|
|SCOTT 7788 RESEARCH|
|KING 7839 ACCOUNTING|
|TURNER 7844 SALES|
|ADAMS 7876 RESEARCH|
|JAMES 7900 SALES|
|FORD 7902 RESEARCH|
|MILLER 7934 ACCOUNTING|

**(14 rows)**

You want to **order the results based on the employee number**, which falls between the employee name and respective department:

|data|
|:----------------------:|
|SMITH 7369 RESEARCH|
|ALLEN 7499 SALES|
|WARD 7521 SALES|
|JONES 7566 RESEARCH|
|MARTIN 7654 SALES|
|BLAKE 7698 SALES|
|CLARK 7782 ACCOUNTING|
|SCOTT 7788 RESEARCH|
|KING 7839 ACCOUNTING|
|TURNER 7844 SALES|
|ADAMS 7876 RESEARCH|
|JAMES 7900 SALES|
|FORD 7902 RESEARCH|
|MILLER 7934 ACCOUNTING|


# Solution

**PostgreSQL**

Use the built-in functions `REPLACE` and `TRANSLATE` to order by numeric characters in a string:

```SQL
SELECT data
  FROM v
 ORDER BY CAST(
           REPLACE(
             TRANSLATE(data,
               REPLACE(TRANSLATE(data,'0123456789','##########'),'#',''),
                       rpad('#',20,'#')),
                   '#','') AS integer);
```

# Discussion

The purpose of view V is only to supply rows on which to demonstrate this recipe’s solution.

The view simply concatenates several columns from the `EMP` table. The solution shows how to take such concatenated text as input and sort it by the employee number embedded within.

The `ORDER BY` clause in each solution may look intimidating, but it performs quite well and is straightforward once you examine it piece by piece. To order by the numbers in the string, it’s easiest to remove any characters that are not numbers.

Once the nonnumeric characters are removed, all that is left to do is cast the string of numerals into a number and then sort as you see fit.

Before examining each function call, it is important to understand the order in which each function is called. Starting with the innermost call, `TRANSLATE` you see that:

```SQL
SELECT data,
       TRANSLATE(data,'0123456789','##########') AS tmp
  FROM v;
```
The first step is to convert the numbers into characters that do not exist in the rest of the string. For this example, we chose `#` and used `TRANSLATE` to convert all nonnumeric characters into occurrences of `#`. For example, the query shows the original data on the left and the results from the first translation:

|data          |          tmp|
|:---------------------:|:-----------------------:|
|SMITH 7369 RESEARCH    | SMITH #### RESEARCH|
|ALLEN 7499 SALES       | ALLEN #### SALES|
|WARD 7521 SALES        | WARD #### SALES|
|JONES 7566 RESEARCH    | JONES #### RESEARCH|
|MARTIN 7654 SALES      | MARTIN #### SALES|
|BLAKE 7698 SALES       | BLAKE #### SALES|
|CLARK 7782 ACCOUNTING  | CLARK #### ACCOUNTING|
|SCOTT 7788 RESEARCH    | SCOTT #### RESEARCH|
|KING 7839 ACCOUNTING   | KING #### ACCOUNTING|
|TURNER 7844 SALES      | TURNER #### SALES|
|ADAMS 7876 RESEARCH    | ADAMS #### RESEARCH|
|JAMES 7900 SALES       | JAMES #### SALES|
|FORD 7902 RESEARCH     | FORD #### RESEARCH|
|MILLER 7934 ACCOUNTING | MILLER #### ACCOUNTING|

TRANSLATE finds the numerals in each string and converts each one to the `#` character. The modified strings are then returned to REPLACE, which removes all occurrences of `#`:

```SQL
SELECT data,
       REPLACE(TRANSLATE(data,'0123456789','##########'),
               '#','') AS tmp
  FROM v;
```

|data          |        tmp|
|:---------------------:|:-------------------:|
|SMITH 7369 RESEARCH    | SMITH  RESEARCH|
|ALLEN 7499 SALES       | ALLEN  SALES|
|WARD 7521 SALES        | WARD  SALES|
|JONES 7566 RESEARCH    | JONES  RESEARCH|
|MARTIN 7654 SALES      | MARTIN  SALES|
|BLAKE 7698 SALES       | BLAKE  SALES|
|CLARK 7782 ACCOUNTING  | CLARK  ACCOUNTING|
|SCOTT 7788 RESEARCH    | SCOTT  RESEARCH|
|KING 7839 ACCOUNTING   | KING  ACCOUNTING|
|TURNER 7844 SALES      | TURNER  SALES|
|ADAMS 7876 RESEARCH    | ADAMS  RESEARCH|
|JAMES 7900 SALES       | JAMES  SALES|
|FORD 7902 RESEARCH     | FORD  RESEARCH|
|MILLER 7934 ACCOUNTING | MILLER  ACCOUNTING|


The strings are then returned to `TRANSLATE` once again, but this time it’s the second (outermost) `TRANSLATE` in the solution. `TRANSLATE` searches the original string for any characters that match the characters in `TMP`. If any are found, they too are converted to `#`s.

This conversion allows all nonnumeric characters to be treated as a single character (because they are all transformed to the same character):

```SQL
SELECT data,
       TRANSLATE(data,
                 REPLACE(TRANSLATE(data,'0123456789','##########'),
                         '#',''),
                 RPAD('#',20,'#'))
  FROM v;
```

|data          |       translate|
|:---------------------:|:-----------------------:|
|SMITH 7369 RESEARCH    | ######7369#########|
|ALLEN 7499 SALES       | ######7499######|
|WARD 7521 SALES        | #####7521######|
|JONES 7566 RESEARCH    | ######7566#########|
|MARTIN 7654 SALES      | #######7654######|
|BLAKE 7698 SALES       | ######7698######|
|CLARK 7782 ACCOUNTING  | ######7782###########|
|SCOTT 7788 RESEARCH    | ######7788#########|
|KING 7839 ACCOUNTING   | #####7839###########|
|TURNER 7844 SALES      | #######7844######|
|ADAMS 7876 RESEARCH    | ######7876#########|
|JAMES 7900 SALES       | ######7900######|
|FORD 7902 RESEARCH     | #####7902#########|
|MILLER 7934 ACCOUNTING | #######7934###########|


The next step is to remove all `#` characters through a call to `REPLACE`, leaving you with only numbers:

```SQL
SELECT data,
       REPLACE(
         TRANSLATE(data,
           REPLACE(TRANSLATE(data,'0123456789','##########'),'#',''),
                   rpad('#',20,'#')),
               '#','') AS tmp
  FROM v;
```

|data          | tmp|
|:---------------------:|:--------:|
|SMITH 7369 RESEARCH    | 7369|
|ALLEN 7499 SALES       | 7499|
|WARD 7521 SALES        | 7521|
|JONES 7566 RESEARCH    | 7566|
|MARTIN 7654 SALES      | 7654|
|BLAKE 7698 SALES       | 7698|
|CLARK 7782 ACCOUNTING  | 7782|
|SCOTT 7788 RESEARCH    | 7788|
|KING 7839 ACCOUNTING   | 7839|
|TURNER 7844 SALES      | 7844|
|ADAMS 7876 RESEARCH    | 7876|
|JAMES 7900 SALES       | 7900|
|FORD 7902 RESEARCH     | 7902|
|MILLER 7934 ACCOUNTING | 7934|

Finally, cast `TMP` to a number using the appropriate DBMS function (often `CAST`) to accomplish this:

```SQL
SELECT data,
       CAST(
          REPLACE(
            TRANSLATE(data,
              REPLACE(TRANSLATE(data,'0123456789','##########'),'#',''),
                      rpad('#',20,'#')),
                  '#','') AS integer) AS tmp
   FROM v;
```

|data          | tmp|
|:---------------------:|:-----:|
|SMITH 7369 RESEARCH    | 7369|
|ALLEN 7499 SALES       | 7499|
|WARD 7521 SALES        | 7521|
|JONES 7566 RESEARCH    | 7566|
|MARTIN 7654 SALES      | 7654|
|BLAKE 7698 SALES       | 7698|
|CLARK 7782 ACCOUNTING  | 7782|
|SCOTT 7788 RESEARCH    | 7788|
|KING 7839 ACCOUNTING   | 7839|
|TURNER 7844 SALES      | 7844|
|ADAMS 7876 RESEARCH    | 7876|
|JAMES 7900 SALES       | 7900|
|FORD 7902 RESEARCH     | 7902|
|MILLER 7934 ACCOUNTING | 7934|

When developing queries like this, it’s helpful to work with your expressions in the SELECT list. That way, you can easily view the intermediate results as you work toward a final solution. However, because the point of this recipe is to order the results, ultimately you should place all the function calls into the ORDER BY clause:

```SQL
SELECT data,
       CAST(
          REPLACE(
            TRANSLATE(data,
              REPLACE(TRANSLATE(data,'0123456789','##########'),'#',''),
                      rpad('#',20,'#')),
                  '#','') AS integer) AS tmp
   FROM v
   ORDER BY CAST(
             REPLACE(
               TRANSLATE(data,
                 REPLACE(TRANSLATE(data,'0123456789','##########'),'#',''),
                         rpad('#',20,'#')),
                     '#','') AS integer);
```

|data          | tmp|
|:---------------------:|:-----:|
|SMITH 7369 RESEARCH    | 7369|
|ALLEN 7499 SALES       | 7499|
|WARD 7521 SALES        | 7521|
|JONES 7566 RESEARCH    | 7566|
|MARTIN 7654 SALES      | 7654|
|BLAKE 7698 SALES       | 7698|
|CLARK 7782 ACCOUNTING  | 7782|
|SCOTT 7788 RESEARCH    | 7788|
|KING 7839 ACCOUNTING   | 7839|
|TURNER 7844 SALES      | 7844|
|ADAMS 7876 RESEARCH    | 7876|
|JAMES 7900 SALES       | 7900|
|FORD 7902 RESEARCH     | 7902|
|MILLER 7934 ACCOUNTING | 7934|

As a final note, the data in the view is comprised of three fields, only one being numeric. Keep in mind that if there had been multiple numeric fields, they would have all been concatenated into one number before the rows were sorted.
