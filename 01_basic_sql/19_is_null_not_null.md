# IS NULL and IS NOT NULL

In the previous chapters we descibed the **special value** of `NULL` and its use in PostgreSQL. In this lesson, we recall the terminology and concepts introduced in lesson [Introduction to NULL](../44_null_notnull_check.md) and further discuss the use of the operators `IS NULL` and `IS NOT NULL` in a `WHERE` clause of a `SELECT` statement when checking for missing values.

## INTRODUCTION TO NULL

In database theory, `NULL` represents `unknown` or **information missing**. Therefore, `NULL` does not represent any data type. To demonstrate this try the following query:

**query**
```console
test=# SELECT pg_typeof(NULL);
```

The function `pg_typeof()` is a PostgreSQL utility to return the data type of a value.

**Output**
```console
 pg_typeof
-----------
 unknown
(1 row)
```

The output shows that the `NULL` data type is `unknown`. What does it mean ?

If `NULL` is not a data type, it must be a **value** of any data type. To be more specific the `NULL` **value** is defined as follow:

> Null (or NULL) is a **special marker** used in Structured Query Language to indicate that a **data value does not exist in the database**. Introduced by the creator of the relational database model, E. F. Codd, SQL Null serves to fulfill the requirement that all true relational database management systems (RDBMS) support **a representation of missing information**.

NULL is not the same as an empty string or the number zero.
Unlike `CHAR` or numeric values, which can only be assigned to `CHAR` or numeric fields, respectively, the **value** `NULL` **can be assigned to any field**, **regardless of its type**.

Suppose that you need to insert an `email_address` of a contact into a table. You can request his or her email address. However, if you don’t know whether the contact has an email address or not, you can insert `NULL` into the `email_address` column. In this case, `NULL` **indicates that the** `email_address` **is not known at the time of recording**.

The previous example shows that you could find `NULL` **values** scattered around in the cells of a table :smile:. For handling `NULL CONSTRAINTS` in a table please refer to lesson: [Introduction to NULL CONSTRAINT](../44_null_notnull_check.md).

`NULL` is very special. **It does not equal anything, even itself**.

The `NULL` is special because any comparisons with a `NULL` can never result in true or false, but in a *third logical result*, *unknown* or `NULL`. In other words, `NULL` represents the missing data in the database.

The expression `NULL = NULL` **returns** `NULL` because it makes sense that two unknown values should not be equal. To demonstrate this for yourself, try the following query:

**SQL**
```SQL
SELECT NULL = NULL AS "NULL = NULL";
```


**Query**
```console
test=# SELECT NULL = NULL AS "NULL = NULL";
```

**Results**

|NULL = NULL|
|:---------:|
|NULL|

**Output**
```console
 NULL = NULL
-------------
 NULL
(1 row)
```

You cannot use arithmetic comparison operators such as `=`, `<`, or `!=` to test for NULL. To demonstrate this for yourself, try the following query:

- **Testing numeric value zero example**

**SQL**
```SQL
SELECT 0 = NULL AS "0 = NULL",
       0 != NULL AS "0 != NULL",
       0 < NULL AS "0 < NULL",
       0 > NULL AS "0 > NULL";
```

**Query**
```console
test=# SELECT 0 = NULL AS "0 = NULL",
test-#        0 != NULL AS "0 != NULL",
test-#        0 < NULL AS "0 < NULL",
test-#        0 > NULL AS "0 > NULL";
```

**Results**

|0 = NULL | 0 != NULL | 0 < NULL | 0 > NULL|
|:-------:|:----------:|:-------:|:-------:|
|NULL     | NULL      | NULL     | NULL|


**Output**
```console
 0 = NULL | 0 != NULL | 0 < NULL | 0 > NULL
----------+-----------+----------+----------
 NULL     | NULL      | NULL     | NULL
(1 row)
```

In this example, we tested the number zero, but it can be any value and the comparison operators return NULL.

- **Testing empty string example**


**SQL**
```SQL
SELECT '' = NULL AS "Check  = NULL",
       '' != NULL AS "Check != NULL",
       '' < NULL AS "Check  < NULL",
       '' > NULL AS "Check  > NULL";
```



**Results**

|Check `'' = NULL` | Check `'' != NULL` | Check `'' < NULL` | Check `'' > NULL`|
|:-------------:|:-------------:|:------------:|:-------------:|
|NULL          | NULL          | NULL          | NULL|



**Query**
```console
dvdrental=# SELECT '' = NULL AS "Check  = NULL",
dvdrental-#        '' != NULL AS "Check != NULL",
dvdrental-#        '' < NULL AS "Check  < NULL",
dvdrental-#        '' > NULL AS "Check  > NULL";
```

**Output**
```console
 Check  = NULL | Check != NULL | Check  < NULL | Check  > NULL
---------------+---------------+---------------+---------------
 NULL          | NULL          | NULL          | NULL
(1 row)
```


Because the result of any arithmetic comparison with `NULL` is also `NULL`, you cannot obtain any meaningful results from such comparisons.


**Note**:

There are only two exceptions:

1. Two NULL values are regarded as equal in a `GROUP BY`.
2. When doing an `ORDER BY`, NULL values are presented
  - first if you do ORDER BY ... ASC and
  - last if you do ORDER BY ... DESC.


Since the comparisons operators, `=` and `!=`, cannot be used to compare a value to `NULL` any DBMS provides two operators to check if a data field record is a missing value or a data type value. The operators are **IS NULL** and **IS NOT NULL**.

## The IS NULL and IS NOT NULL operators syntax

In This section we introduce the syntax of the `IS NULL` and `IS NOT NULL` operators for comparison with expression values and use in a `WHERE` clause of a `SELECT` statement.

### IS NULL operator

To determine whether an expression, a value, is `NULL` or not, you use the **IS NULL** boolean operator as follows:

```SQL
expression IS NULL
```

In this syntax, the left hand side part `expression` can be a value like a numeric or literal string or any data type supported by your DBMS.

If the result of the expression is `NULL`, **IS NULL** operator returns **true**; otherwise, it returns false.

For example, the comparison examples we illustrated earlier can be now tested with the `IS NULL` operator as follow:


**SQL**
```SQL
SELECT NULL IS NULL AS "Check NULL IS NULL",
       0 IS NULL AS "Check 0 IS NULL";
```


**Query**
```console
test=# SELECT NULL IS NULL AS "Check NULL IS NULL",
test-#        0 IS NULL AS "Check 0 IS NULL";
```

**Results**

|Check `NULL IS NULL` | Check `0 IS NULL`|
|:-------------------:|:----------------:|
|t                    | f|


**Output**
```console
 Check NULL IS NULL | Check 0 IS NULL
--------------------+-----------------
 t                  | f
(1 row)
```

The general form of a `SELECT` statement with `IS NULL` in the `WHERE` clause is:

```SQL
SELECT <column names>
  FROM <table>
 WHERE <column name> IS NULL;
```

A query with `IS NULL` will renturn only those records in which the field identified by `<column name>` contains the value `NULL`.

We discuss a few examples in the following sections.

### IS NOT NULL operator

To negate the `IS NULL` operator, you use the **IS NOT NULL** operator as follows:

```SQL
expression IS NOT NULL
```
The operator **IS NOT NULL** returns **true** if the `expression` or value in the column **is not null**. Otherwise, it returns false.


For example, the comparison examples we illustrated earlier can be now tested with the `IS NULL` operator as follow:

**SQL**
```SQL
SELECT NULL IS NOT NULL AS "Check NULL IS NOT NULL",
       0 IS NOT NULL AS "Check 0 IS NOT NULL",
       '' IS NOT NULL AS "Check IS NOT NULL";
```

**Results**

|Check `NULL IS NOT NULL` | Check `0 IS NOT NULL` | Check `'' IS NOT NULL`|
|:---------------------:|:-------------------:|:----------------:|
|f                      | t                   | t|

**Query**
```console
dvdrental=# SELECT NULL IS NOT NULL AS "Check NULL IS NOT NULL",
dvdrental-#        0 IS NOT NULL AS "Check 0 IS NOT NULL",
dvdrental-#        '' IS NOT NULL AS "Check IS NOT NULL";
```

**Output**
```console
 Check NULL IS NOT NULL | Check 0 IS NOT NULL | Check IS NOT NULL
------------------------+---------------------+-------------------
 f                      | t                   | t
```

The general form of a `SELECT` statement with `IS NULL` in the `WHERE` clause is:

```SQL
SELECT <column names>
  FROM <table>
 WHERE <column name> IS NOT NULL;
```

A query with `IS NULL` will renturn only those records in which the field identified by `<column name>` contains a value other than `NULL`.


### NULL and IS NOT NULL summary

The `IS NULL` and `IS NOT NULL` constructions are the only way to search for records containing the value `NULL`. `BETWEEN`, `LIKE` and the other `WHERE` clause options can never find `NULL` values.

You can test expression's value with these operators. For example the table below shows the comparison of numerical and literal string values.

|value| IS NULL| IS NOT NULL|
|:---:|:------:|:----------:|
|`0`| f| t|
|`''`|f|t|


### NULL and IS NOT NULL example

## PostgreSQL NULL vs NOT NULL

Now, let's see how `NULL` is used in PostgreSQL. We will use the  `locations` and `employees` tables in the `hr` sample database to demonstrate the functionality of the `NULL` and `IS NOT NULL` boolean operator.

### HR NULL and IS NOT NULL examples


- **Example 1**

**Table**
```console
hr=# \d locations
                                            Table "public.locations"
     Column     |         Type          | Collation | Nullable |                    Default
----------------+-----------------------+-----------+----------+------------------------------------------------
 location_id    | integer               |           | not null | nextval('locations_location_id_seq'::regclass)
 street_address | character varying(40) |           |          |
 postal_code    | character varying(12) |           |          |
 city           | character varying(30) |           | not null |
 state_province | character varying(25) |           |          |
 country_id     | character(2)          |           | not null |
Indexes:
    "locations_pkey" PRIMARY KEY, btree (location_id)
```


1. Let's see which rows (tuples or records) are present in the `locations` table of the `hr` sample database.

**SQL**
```SQL
SELECT *
  FROM locations;
```

**Results**

|location_id | street_address | `postal_code` | city | `state_province` | country_id|
|:----------:|:-------------:|:------------:|:----:|:--------------:|:---------:|
|1400 | 2014 Jabberwocky Rd | 26192 | Southlake | Texas | US|
|1500 | 2011 Interiors Blvd | 99236 | South San Francisco | California | US|
|1700 | 2004 Charade Rd | 98199 | Seattle  | Washington     | US|
|1800 | 147 Spadina Ave | M5V 2L7  | Toronto | Ontario        | CA|
|**2400** | 8204 Arthur St  |`          `| London  |`                `| UK|
|2500 | Magdalen Centre, The Oxford Science Park | OX9 9ZB  | Oxford| Oxford| UK|
|2700 | Schwanthalerstr. 7031 | 80925  | Munich  | Bavaria  | DE|




**Query**
```console
hr=> SELECT * FROM locations;
```

**Output**
```console
 location_id |              street_address              | postal_code |        city         | state_province | country_id
-------------+------------------------------------------+-------------+---------------------+----------------+------------
        1400 | 2014 Jabberwocky Rd                      | 26192       | Southlake           | Texas          | US
        1500 | 2011 Interiors Blvd                      | 99236       | South San Francisco | California     | US
        1700 | 2004 Charade Rd                          | 98199       | Seattle             | Washington     | US
        1800 | 147 Spadina Ave                          | M5V 2L7     | Toronto             | Ontario        | CA
        2400 | 8204 Arthur St                           |             | London              |                | UK
        2500 | Magdalen Centre, The Oxford Science Park | OX9 9ZB     | Oxford              | Oxford         | UK
        2700 | Schwanthalerstr. 7031                    | 80925       | Munich              | Bavaria        | DE
(7 rows)
```

The output shows that two fields, in the columns `postal_code` and `state_province`, are empty for the record (row) with primary key column `location_id` equal to `2400`.

Does the `empty field` represent an empty string or a `NULL` value?

Let's use the `=` operator to test for an empty field.

2. So now, if we want to select all the tuples in which the `postal_code` is not present, we use the following:

**SQL**
```SQL
SELECT *
  FROM locations
 WHERE postal_code = '';
```

**Results**

`0` Rows.

**Query**
```console
hr=> SELECT *
hr->   FROM locations
hr->  WHERE postal_code = '';
```

**Output**
```console
 location_id | street_address | postal_code | city | state_province | country_id
-------------+----------------+-------------+------+----------------+------------
(0 rows)
```

As you can see, PostgreSQL does not return any records. This happens because the insert has entered a `NULL` value in the `postal_code`'s field.

:warning: Because **NULL** really means "**no value", representing it in query results is problematic. The default setting of many DBMS uses blanks to indicate a `NULL`, but different implementation of SQL use different representations. Luckily, PostgreSQL allows their users to choose how `NULL` values are represented in query results. The next step shows how.

3. In order to see the `NULL` values present in the tables, let's execute the following command, `\pset null NULL`:

```console
hr=> \pset null NULL
Null display is "NULL".
```

Sets the string `NULL` to be printed in place of a null value. The default is to print nothing, which can easily be mistaken for an empty string.

4. This tells psql to show NULL values ​​that are present in the table as NULL, as shown here:

**SQL**
```SQL
SELECT *
  FROM locations;
```

**Results**

|location_id | street_address | `postal_code` | city | `state_province` | country_id|
|:----------:|:-------------:|:------------:|:----:|:--------------:|:---------:|
|1400 | 2014 Jabberwocky Rd | 26192 | Southlake | Texas | US|
|1500 | 2011 Interiors Blvd | 99236 | South San Francisco | California | US|
|1700 | 2004 Charade Rd | 98199 | Seattle  | Washington     | US|
|1800 | 147 Spadina Ave | M5V 2L7  | Toronto | Ontario        | CA|
|**2400** | 8204 Arthur St  |**NULL**| London  |**NULL**| UK|
|2500 | Magdalen Centre, The Oxford Science Park | OX9 9ZB  | Oxford| Oxford| UK|
|2700 | Schwanthalerstr. 7031 | 80925  | Munich  | Bavaria  | DE|


**Query**
```console
hr=> SELECT * FROM locations;
```

**Output**
```console
 location_id |              street_address              | postal_code |        city         | state_province | country_id
-------------+------------------------------------------+-------------+---------------------+----------------+------------
        1400 | 2014 Jabberwocky Rd                      | 26192       | Southlake           | Texas          | US
        1500 | 2011 Interiors Blvd                      | 99236       | South San Francisco | California     | US
        1700 | 2004 Charade Rd                          | 98199       | Seattle             | Washington     | US
        1800 | 147 Spadina Ave                          | M5V 2L7     | Toronto             | Ontario        | CA
        2400 | 8204 Arthur St                           | NULL        | London              | NULL           | UK
        2500 | Magdalen Centre, The Oxford Science Park | OX9 9ZB     | Oxford              | Oxford         | UK
        2700 | Schwanthalerstr. 7031                    | 80925       | Munich              | Bavaria        | DE
(7 rows)
```

As you can see, the `postal_code` and `state_province` values associated with the `city` **London** are not
an empty strings; the fields contain a **NULL** value.

5. Now, if we want to see all records that **have** `NULL` values in the `postal_code`
field, we have to use the `IS NULL` operator:

**SQL**
```SQL
SELECT *
  FROM locations
 WHERE postal_code IS NULL;
```

**Results**

|location_id | street_address | postal_code |  city  | state_province | country_id|
|:----------:|:--------------:|:-----------:|:------:|:--------------:|:---------:|
|       2400 | 8204 Arthur St | **NULL**        | London | **NULL**           | UK|


**Query**
```console
hr=> SELECT *
hr->   FROM locations
hr->  WHERE postal_code IS NULL;
```

**Output**
```console
 location_id | street_address | postal_code |  city  | state_province | country_id
-------------+----------------+-------------+--------+----------------+------------
        2400 | 8204 Arthur St | NULL        | London | NULL           | UK
(1 row)
```

The preceding query looks for all records for which there is no value in the `postal_code` field.

6. Now, we will search for all recrods for which **there is a value** in the `postal_code` field using the following query:

**SQL**
```SQL
SELECT *
  FROM locations
 WHERE postal_code IS NOT NULL;
```

**Results**

|location_id | street_address | `postal_code` | city | `state_province` | country_id|
|:----------:|:-------------:|:------------:|:----:|:--------------:|:---------:|
|1400 | 2014 Jabberwocky Rd | 26192 | Southlake | Texas | US|
|1500 | 2011 Interiors Blvd | 99236 | South San Francisco | California | US|
|1700 | 2004 Charade Rd | 98199 | Seattle  | Washington     | US|
|1800 | 147 Spadina Ave | M5V 2L7  | Toronto | Ontario        | CA|
|2500 | Magdalen Centre, The Oxford Science Park | OX9 9ZB  | Oxford| Oxford| UK|
|2700 | Schwanthalerstr. 7031 | 80925  | Munich  | Bavaria  | DE|


**Query**
```console
hr=> SELECT *
hr->   FROM locations
hr->  WHERE postal_code IS NOT NULL;
```
**Output**
```console
 location_id |              street_address              | postal_code |        city         | state_province | country_id
-------------+------------------------------------------+-------------+---------------------+----------------+------------
        1400 | 2014 Jabberwocky Rd                      | 26192       | Southlake           | Texas          | US
        1500 | 2011 Interiors Blvd                      | 99236       | South San Francisco | California     | US
        1700 | 2004 Charade Rd                          | 98199       | Seattle             | Washington     | US
        1800 | 147 Spadina Ave                          | M5V 2L7     | Toronto             | Ontario        | CA
        2500 | Magdalen Centre, The Oxford Science Park | OX9 9ZB     | Oxford              | Oxford         | UK
        2700 | Schwanthalerstr. 7031                    | 80925       | Munich              | Bavaria        | DE
(6 rows)
```

- **Example 2**

**Table**
```console
hr=# \d employees
                                            Table "public.employees"
    Column     |          Type          | Collation | Nullable |                    Default
---------------+------------------------+-----------+----------+------------------------------------------------
 employee_id   | integer                |           | not null | nextval('employees_employee_id_seq'::regclass)
 first_name    | character varying(20)  |           |          |
 last_name     | character varying(25)  |           | not null |
 email         | character varying(100) |           | not null |
 phone_number  | character varying(20)  |           |          |
 hire_date     | date                   |           | not null |
 job_id        | integer                |           | not null |
 salary        | numeric(8,2)           |           | not null |
 manager_id    | integer                |           |          |
 department_id | integer                |           |          |
Indexes:
    "employees_pkey" PRIMARY KEY, btree (employee_id)
```

**Problem**: Find all employees who do not have the phone numbers.

- **tables**: employees
- **columns**: employee_id, first_name, last_name
- **condition**: employees who do not have the phone numbers, phone number is missing.

**SQL**
```SQL
SELECT employee_id,
       first_name,
       last_name,
       phone_number
  FROM employees
 WHERE phone_number IS NULL;
```

**Results**

|employee_id | first_name | last_name  | `phone_number`|
|:----------:|:----------:|:----------:|:------------:|
|        145 | John       | Russell    | **NULL**|
|        146 | Karen      | Partners   | **NULL**|
|        176 | Jonathon   | Taylor     | **NULL**|
|        177 | Jack       | Livingston | **NULL**|
|        178 | Kimberely  | Grant      | **NULL**|
|        179 | Charles    | Johnson    | **NULL**|



**Query**
```console
hr=# SELECT employee_id,
hr-#        first_name,
hr-#        last_name,
hr-#        phone_number
hr-#   FROM employees
hr-#  WHERE phone_number IS NULL;
```

**Output**
```console
 employee_id | first_name | last_name  | phone_number
-------------+------------+------------+--------------
         145 | John       | Russell    | NULL
         146 | Karen      | Partners   | NULL
         176 | Jonathon   | Taylor     | NULL
         177 | Jack       | Livingston | NULL
         178 | Kimberely  | Grant      | NULL
         179 | Charles    | Johnson    | NULL
(6 rows)
```
