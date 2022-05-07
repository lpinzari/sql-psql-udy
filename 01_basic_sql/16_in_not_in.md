# IN and NOT IN

In this lesson, you will learn how to use the PostgreSQL `IN` operator in the `WHERE` clause to **check if a value matches any value in a list**.

Another possible way to restrict which records are selected is to use `IN` and `NOT IN`. Like the other mechanisms discussed so far, they appear in the `WHERE` clause, and **only records that match their requirements are returned**.

The PostgreSQL `IN` operator determines whether **a value matches any values in a** `list` **or a** `subquery`.

1. We'll first give basic examples on how the `IN` and `NOT` operators work with simple expressions value and list of values.
2. Then we show how to use the `IN` operator in a `WHERE` clause with a list of values and basic subqueries.
3. Lastly, we introduce the equivalent examples of the `NOT IN` operator for the `WHERE` clause.

## IN and NOT IN operator syntax

**The syntax of PostgreSQL** `IN` **operator** that determines whether an expression matches a list of value is as follows:

`<expression>` **IN** `(value1, value2, .., valueN)`

- `<expression>`: The first item is any valid expression, which can be a **value** or a **column**, (or a computation on a set of columns), of a table that you want to match in a `WHERE` clause.
- `(value1, value2, ...)`:  The second item consists of one `(value1)`, two (`value1, value2`) or more N values `(value1, value2, ..., valueN)`, separated by commas and enclosed in parentheses.

The `IN` operator returns **true** if the `<expression>` to be compared equals to any value in the list of values or false otherwise.

Using `IN` is equivalent to grouping several tests for equality together with `OR`s.

Technically, you can substitute the `IN` operator with the `=` and `OR` operators.

The condition that uses the `IN` operator **can be rewritten using** one or more `OR` operators as follows:

```SQL
<expression> = value1 OR
<expression> = value2 OR
...
<expression> = valueN;  
```

This situation is yet another example of a **shorthand form** provided by SQL for common requests.

Similarly, **the syntax of PostgreSQL** `NOT IN` **operator** that determines whether an expression does not match a list of value is as follows:

`<expression>` **NOT IN** `(value1, value2, ..)`

The `NOT IN` operator returns **true** if the `<expression>` does not equal any values in the list or false otherwise. Basically, The `NOT` operator negates the result of the `IN` operator.

Similarly, `NOT IN` is equivalent to grouping tests for inequality together with `AND`s.

Technically, you can substitute the `NOT IN` operator with the `!=` (or `<>`) and `AND` operators.

The condition that uses the `NOT IN` operator **can be rewritten using** one or more `AND` operators as follows:

```SQL
<expression> != value1 AND
<expression> != value2 AND
...
<expression> != valueN;  
```

:warning: **Note**: All the `values` must have the **same data type** as the expression.

### 1. expression value examples

`value` **IN** `(value1, value2, ..)`

The `IN` operator returns **true** if the `value` to be compared equals to any value in the list of values.

`value` **NOT IN** `(value1, value2, ..)`

The `NOT IN` operator returns **true** if the `value` to be compared does not equal to any value in the list of values.

For example, let's consider the case of strings, numeric, boolean and date data types.


#### STRINGS

- if `<expression>` is a **CHAR** value, the `values` separated by commas and enclosed in parentheses must all be **quoted character** strings, ex: `('value1', 'value2',...)`.


- **IN** example:

**SQL**
```SQL
SELECT 'Ludo' IN ('Alex', 'Albert', 'John', 'Ludo', 'Susan') -- True (t)
```

**Query**
```console
test=# SELECT 'Ludo' IN ('Alex', 'Albert', 'John', 'Susan', 'Ludo') AS "Ludo";
```
**Output**

```console
 Ludo
------
 t
(1 row)
```

The string `Ludo` is in the list of values and therefore the `IN` operator returns the boolean value true, `t`.

**SQL**
```SQL
SELECT 'Ludo' IN ('Alex', 'Albert', 'John', 'Susan', 'Maria'); -- FALSE
```

**Query**
```console
hr=# SELECT 'Ludo' IN ('Alex', 'Albert', 'John', 'Susan', 'Maria') AS "Ludo";
```

**Output**
```console
 Ludo
------
 f
(1 row)
```

The string `Ludo` is in not in the list of values and therefore the `IN` operator returns the boolean value false, `f`.

- **NOT IN** example:

**SQL**
```SQL
SELECT 'Ludo' NOT IN ('Alex', 'Albert', 'John', 'Susan', 'Maria'); -- True.
```

**Query**
```console
hr=# SELECT 'Ludo' NOT IN ('Alex', 'Albert', 'John', 'Susan', 'Maria') AS "not_ludo";
```

**Output**
```console
 not_ludo
----------
 t
(1 row)
```

The string `Ludo` is not in the list of values and therefore the `NOT IN` operator returns the boolean value true, `t`.


**SQL**
```SQL
SELECT 'Ludo' NOT IN ('Alex', 'Albert', 'John', 'Susan', 'Ludo'); -- FALSE
```

**Query**
```console
hr=# SELECT 'Ludo' NOT IN ('Alex', 'Albert', 'John', 'Susan', 'Ludo') AS "not_Ludo";
```

**Output**
```console
 not_Ludo
----------
 f
(1 row)
```

The string `Ludo` is in the list of values and therefore the `NOT IN` operator returns the boolean value false, `f`.

#### NUMERIC

- if `<expression>` identifies a **numeric** value, such as `INTEGER` or `SMALLINT`, then the values must be number, so they can be entered directly. ex: `(value1, value2, ...)`.

**SQL**
```SQL
SELECT 4 IN (1, 2, 5, 4) AS "four"; -- True (t)
```

**Query**
```console
test=# SELECT 4 IN (1, 2, 5, 4) AS "four";
```

**Output**
```console
 four
------
 t
(1 row)
```

The `value` can be the result of a computation such as a sum or a function applied to a number of arguments. For example, let's say to apply the modulo function to a number to find the remainders greater than 10 for 13. The list of values are `(10, 11, 12)`.

```SQL
SELECT MOD(36, 13) IN (10, 11, 12) AS MOD_13_UP_10; -- True. MOD(36,13) = 10
```

**Query**
```console
parch_posey=# SELECT MOD(36, 13) IN (10, 11, 12) AS MOD_13_UP_10;
```

**Output**
```console
 mod_13_up_10
--------------
 t
(1 row)
```

It returns true since `36 = 13 * 2 +`**10**.

#### BOOLEAN

- if `<expression>` identifies a literal **Boolean** value, such as `(TRUE, 't','true','y','yes','on','1')` or `(FALSE, 'f','false','n','no','off','0')`, then the values must be literal booleans.


**SQL**
```SQL
SELECT 'y' IN (TRUE,'t','true','y','on','1'); -- True
SELECT `n` IN (FALSE, 'f','false','n','no','off','0'); -- True
SELECT 't' IN (TRUE,FALSE); -- True
SELECT TRUE IN ('t'); -- True
```

**Query**
```console
test=# SELECT 'y' IN ('t','true','y','on','1',TRUE) AS y_TRUE;
```

**Output**
```console
 y_true
--------
 t
(1 row)
```

However, if we use a value different than a boolean literals PostgreSQL throws an error:

**Query**
```console
test=# SELECT 'ok' IN ('t','true','y','on','1',TRUE) AS ok_TRUE;
```

**Output ERROR**:
```console
ERROR:  invalid input syntax for type boolean: "ok"
LINE 1: SELECT 'ok' IN ('t','true','y','on','1',TRUE) AS ok_TRUE;
               ^
```

#### DATE

- if `<expression>` identifies a literal **DATE** value, (i.e: `YYYY-mm-dd` format), then the values must be DATE type values.

For example, suppose we want to compare a set of date values with the current date.

To get the current date we use the PostgreSQL function `NOW()`.

```console
hr=# SELECT NOW()::date;
    now
------------
 2022-05-07
(1 row)
```

**SQL**
```SQL
SELECT NOW()::date IN ('1980-01-15', '1999-02-03', '2022-05-07'); -- True
```

**Query**
```console
hr=# SELECT NOW()::date IN ('1980-01-15', '1999-02-03','2022-05-07') AS now;
```

**Output**
```console
 now
-----
 t
(1 row)
```

However, if we use a different format than PostgreSQL throws an error:

**Query**
```console
hr=# SELECT NOW()::date IN ('1980-01-15', '1999-15-03','2022-05-07') AS now;
```
**Output ERROR**
```console
ERROR:  date/time field value out of range: "1999-15-03"
LINE 1: SELECT NOW()::date IN ('1980-01-15', '1999-15-03','2022-05-0...
                                             ^
HINT:  Perhaps you need a different "datestyle" setting.
```

### 2. WHERE clause example

The general form of a SQL statement using `IN` that determines whether the **values in a table's column** `match` a **list of values** is:

```SQL
SELECT <column_names>
  FROM <table>
 WHERE <column_name> IN (value1, value2, ...);
```

In the `WHERE` clause:

- `<column_name>`: The first item must name a particular column in the table.
- `(value1, value2, ...)`:  The second item consists of one `(value1)`, two (`value1, value2`) or more values `(value1, value2, ...)`, separated by commas and enclosed in parentheses.

The `IN` operator returns **true** if the value to be compared equals to any value in the list of values.

Therefore, in this query:

```SQL
SELECT <column_names>
  FROM <table>
 WHERE <column_name> IN (value1, value2, ...);
```

The **records returned** are those where the field named `<column_name>` **contains one of the values specified in the parenthesized list**.

The condition that uses the `IN` operator **can be rewritten using** one or more `OR` operators as follows:

```SQL
SELECT <column_names>
  FROM <table>
 WHERE <column_name> = value1 OR
       <column_name> = value2 OR
       ...
       <column_name> = valueN;
```

This situation is yet another example of a shorthand form provided by SQL for common requests.

Similarly, **the syntax of PostgreSQL** `NOT IN` **operator** that determines whether the **values in a table's column** `do not match` a **list of values** is:

```SQL
SELECT <column_names>
  FROM <table>
 WHERE <column_name> NOT IN (value1, value2, ...);
```

The **records returned** are those where the field named `<column_name>` **does not contain any of the values specified in the parenthesized list**.

The condition that uses the `NOT IN` operator **can be rewritten using** one or more `AND` operators as follows:

```SQL
SELECT <column_names>
  FROM <table>
 WHERE <column_name> != value1 AND
       <column_name> != value2 AND
       ...
       <column_name> != valueN;
```

:warning: **Note**: All the `values` must have the **same data type** as the column identified by `<column_name`. In other words, all the values must be of a type comparable to that of the column identified by `<column_name>`.

For example,

- if `<column_name>` is a **CHAR** column, the `values` separated by commas and enclosed in parentheses must all be **quoted character** strings, ex: `('value1', 'value2',...)`.
- if `<column_name>` identifies a numeric column, such as `INTEGER` or `SMALLINT`, then the values must be number, so they can be entered directly. ex: `(value1, value2, ...)`.

#### Subquery

In the previous example we introduced the `IN` operator to **compare** `the column's values stored in the records of the table` to a list of values, such as literal strings or numbers.

What if we wanted to **compare** `the column's values stored in the records of the table` to another `set of values contained in another column`?  

In other words, we want to return the records columns stored in `<table>` and indicated in the `SELECT` statement based on the following condition:

- `<column_name>` **IN** (`result set of values contained in one column`);

The second part in the `IN` operator is a **subquery**.

```SQL
SELECT <column_names>
  FROM <table>
 WHERE <column_name> IN subquery;
```

The `subquery` **returns a result set of one column** `to test for the match`. The column must also have the same data type as `<column_name>`.  The `IN` operator returns **true** if the value equals to any value in the list of values or the result set returned by the subquery. Otherwise, it returns false.

The concept of `subquery` will be explained later in the course. However, we can give you a basic idea of what a subquery is with a trivial example.

For example, the list of values can be the result of a `SELECT` statement like this:

```SQL
SELECT <column_names>
  FROM <table>
 WHERE <column_name> IN ( SELECT column_name FROM table_name);
```

The query inside the parentheses is called a `subquery`, which is a **query nested inside another query**.

## DVDRENTAL examples
