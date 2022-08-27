# Inserting Default Values

A table can be defined to **take default values for specific columns**.

You want to `insert a row` of **default values without having to specify those values**.

## Problem

Consider the following table:

```SQL
CREATE TABLE d (
  id INTEGER DEFAULT 0
);
```

You want to insert zero without explicitly specifying zero in the values list of an `INSERT` statement. You want to explicitly insert the default, whatever that default is.

## Solution

All brands support the use of the `DEFAULT` keyword as a way of explicitly specifying the default value for a column. Some brands provide additional ways to solve the problem.

The following example illustrates the use of the `DEFAULT` keyword:

```SQL
INSERT INTO d
VALUES (DEFAULT);
```

You may also explicitly specify the column name, which you’ll need to do anytime you are not inserting into all columns of a table:


```SQL
INSERT INTO d
       (id)
VALUES (DEFAULT);
```

`PostgreSQL` and SQL Server support a `DEFAULT VALUES` clause:

```SQL
INSERT INTO d DEFAULT VALUES;
```

The `DEFAULT VALUES` clause causes **all columns to take on their default values**.

## Discussion

The `DEFAULT` keyword in the values list will insert the value that was specified as the default for a particular column during table creation. The keyword is available for all DBMSs.

MySQL, PostgreSQL, and SQL Server users have another option available **if all columns in the table are defined with a default value** (as table `D` is in this case).

```SQL
INSERT INTO d DEFAULT VALUES;
```

The `DEFAULT VALUES` clause causes **all columns to take on their default values**.

For tables with a `mix of` **default** and **nondefault** columns, inserting default values for a column is as easy as `excluding the column from the insert list`; you do not need to use the `DEFAULT` keyword. Say that table `D` had an additional column that was not defined with a default value:

```SQL
CREATE TABLE d (
  id INTEGER DEFAULT 0,
  foo VARCHAR(10)
);
```

You can insert a default for `ID` by listing only `FOO` in the insert list:

```SQL
INSERT INTO d
       (foo)
VALUES ('Bar');
```

|id|foo|
|:--:|:--:|
|0|Bar|

This statement will result in a row in which `ID` is `0` and `FOO` is `BAR`. `ID` takes on its default value because no other value is specified.
