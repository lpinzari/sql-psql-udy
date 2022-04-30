# PostgreSQL NOT NULL CONSTRAINT

In this lesson, you will learn about PostgreSQL not-null constraint to ensure the values of a column are not null.

## Introduction to NULL

In database theory, `NULL` represents `unknown` or **information missing**. NULL is not the same as an empty string or the number zero.

Suppose that you need to insert an `email_address` of a contact into a table. You can request his or her email address. However, if you don’t know whether the contact has an email address or not, you can insert `NULL` into the `email_address` column. In this case, `NULL` **indicates that the** `email_address` **is not known at the time of recording**.

`NULL` is very special. **It does not equal anything, even itself**.

The expression `NULL = NULL` **returns** `NULL` because it makes sense that two unknown values should not be equal.

To check if a value is `NULL` or not, you use the **IS NULL** `boolean operator`. For example, the following expression returns true if the value in the email address is NULL.

```console
email_address IS NULL
```

The **IS NOT NULL** operator negates the result of the **IS NULL** operator.

## PostgreSQL NOT NULL constraint

To control whether a column can accept `NULL`, you use the `NOT NULL` constraint:

```console
CREATE TABLE table_name(
   ...
   column_name data_type NOT NULL,
   ...
);
```

If a column has a `NOT NULL` constraint, any attempt to `insert` or `update` NULL in the column will result in an error.

## Declaring NOT NULL columns

The following `CREATE TABLE` statement creates a new table name **invoices** with the `NOT NULL` constraints.

```console
CREATE TABLE invoices(
  id SERIAL PRIMARY KEY,
  product_id INT NOT NULL,
  qty numeric NOT NULL CHECK(qty > 0),
  net_price numeric CHECK(net_price > 0)
);
```

This example uses the `NOT NULL` keywords that follow the *data type* of the `product_id` and `qty` columns to declare `NOT NULL` constraints.

- `qty numeric NOT NULL CHECK(qty > 0)`

Note that **a column can have multiple constraints** such as `NOT NULL`, `CHECK`, `UNIQUE`, `FOREIGN KEY` appeared next to each other. **The order of the constraints is not important**. PostgreSQL can check the constraint in the list in any order.

If you use `NULL` instead of NOT NULL, **the column will accept both** `NULL` and `non-NULL` values.

If you don’t explicitly specify NULL or NOT NULL, it will accept `NULL` by **default**.

## Adding NOT NULL Constraint to existing columns

To add the `NOT NULL` constraint to a column of an existing table, you use the following form of the `ALTER TABLE` statement:

```console
ALTER TABLE table_name
ALTER COLUMN column_name SET NOT NULL;
```

To add set multiple NOT NULL constraint to multiple columns, you use the following syntax:

```console
ALTER TABLE table_name
ALTER COLUMN column_name_1 SET NOT NULL,
ALTER COLUMN column_name_2 SET NOT NULL,
...;
```

### Example

Let’s take a look at the following example.

First, create a new table called production orders ( `production_orders`):

```console
CREATE TABLE production_orders (
	id SERIAL PRIMARY KEY,
	description VARCHAR (40) NOT NULL,
	material_id VARCHAR (16),
	qty NUMERIC,
	start_date DATE,
	finish_date DATE
);
```

Next, insert a new row into the `production_orders` table:

```console
INSERT INTO production_orders
            (description)
     VALUES ('Make for Infosys inc.');
```

Then, to make sure that the `qty` field is not null, you can add the `NOT NULL` constraint to the `qty` column. However, **the column already contains data**. If you try to add the `NOT NULL` constraint, PostgreSQL will issue an error.

To add the `NOT NULL` constraint to a column that already contains `NULL`, you need to update `NULL` to **non-null values** first, like this:

```console
UPDATE production_orders
   SET qty = 1
 WHERE qty IS NULL;
```

The values in the `qty` column are updated to one. Now, you can add the `NOT NULL` constraint to the `qty` column:

```console
ALTER TABLE production_orders
ALTER COLUMN qty
SET NOT NULL;
```

After that, you can update the `NOT NULL` constraints for `material_id`, `start_date`, and `finish_date` columns:

```console
UPDATE production_orders
   SET material_id = 'ABC'
 WHERE qty IS NULL;

UPDATE production_orders
   SET start_date = '2015-09-01'
 WHERE start_date IS NULL;

UPDATE production_orders
   SET finish_date = '2015-09-01'
 WHERE finish_date IS NULL;
```

Add not-null constraints to multiple columns:

```console
ALTER TABLE production_orders
ALTER COLUMN material_id SET NOT NULL,
ALTER COLUMN start_date SET NOT NULL,
ALTER COLUMN finish_date SET NOT NULL;
```
Finally, attempt to update values in the `qty` column to `NULL`:

```console
UPDATE production_orders
SET qty = NULL;
```
PostgreSQL issued an error message:

```console
[Err] ERROR:  null value in column "qty" violates not-null constraint
DETAIL:  Failing row contains (1, make for infosys inc., ABC, null, 2015-09-01, 2015-09-01).
```

## The special case of NOT NULL constraint

Besides the `NOT NULL` constraint, you can use a `CHECK` constraint to force a column to accept not NULL values. The `NOT NULL` constraint is equivalent to the following `CHECK` constraint:

```console
CHECK (column IS NOT NULL)
```
This is useful because sometimes you may want either column `a` **or** `b` **is not null**, but not both.

For example, you may want either `username` or `email` column of the user tables is not null or empty. In this case, you can use the `CHECK` constraint as follows:

```console
CREATE TABLE users (
 id serial PRIMARY KEY,
 username VARCHAR (50),
 password VARCHAR (50),
 email VARCHAR (50),
 CONSTRAINT username_email_notnull
 CHECK (
        NOT ( ( username IS NULL  OR  username = '' )
              AND
              ( email IS NULL  OR  email = '' )
            )
       )
);
```

The following statement works.

```console
INSERT INTO users (username, email)
VALUES
	('user1', NULL),
	(NULL, 'email1@example.com'),
	('user2', 'email2@example.com'),
	('user3', '');
```

However, the following statement will not work because it violates the `CHECK` constraint:

```console
INSERT INTO users (username, email)
VALUES
	(NULL, NULL),
	(NULL, ''),
	('', NULL),
	('', '');
```
Error:

```console
[Err] ERROR:  new row for relation "users" violates check constraint "username_email_notnull"
```
