# Primary Key constraints

In the previous lesson we've created the `parch_posey` databases and populated the tables. However, the sql script file didn't not specified the **Primary key** of each table.

In this lesson, we will show you

- what the **primary key is** and
- **how to manage PostgreSQL primary key constraints through SQL statements**.

## What is a Primary Key ?

A **primary key** is a **column or a group of columns used to identify a row uniquely in a table**.

You define primary keys through primary key constraints.

Technically, a **primary key constraint** is the combination of
- a **not-null constraint** and
- a **UNIQUE constraint**.

Find more information about [not-null constraint](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-not-null-constraint/) and [unique constraint](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-unique-constraint/).

A **table can have one and only one primary key**.

It is a good practice to **add a primary key to every table**. When you add a primary key to a table, PostgreSQL creates a unique B-tree index on the column or a group of columns used to define the primary key.

## Defining Primary Key When Creating Table

Normally, we add the primary key to a table when we define the table’s structure using [CREATE TABLE](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-create-table/) statement.

```console
CREATE TABLE TABLE example1 (
	column_1 data_type PRIMARY KEY,
	column_2 data_type,
	…
);
```

The `column_1` is the primary key of the table **example1**, which uniquely identifies the row in the table.

In case the primary key consists of two or more columns, you define the primary key constraint as follows:

```console
CREATE TABLE TABLE example2 (
	column_1 data_type,
	column_2 data_type,
	…
  PRIMARY KEY (column_1, column_2)
);
```

If you don’t specify explicitly the name for primary key constraint, PostgreSQL will assign a default name to the primary key constraint. By default, PostgreSQL uses `table-name_pkey` as the default name for the **primary key constraint**. In this example, PostgreSQL creates the primary key constraint with the name **example2_pkey** for the **example2** table.

So, what is missing in the `parch-and-posey.sql` file ?

Let's see the **CREATE TABLE** STATEMENTS:


**web_events**

```console
CREATE TABLE web_events (
	id integer,
	account_id integer,
	occurred_at timestamp,
	channel bpchar
);
```
**sales_reps**

```console
CREATE TABLE sales_reps (
	id integer,
	name bpchar,
	region_id integer
);
```
**region**

```console
CREATE TABLE region (
	id integer,
	name bpchar
);
```

**orders**

```console
CREATE TABLE orders (
	id integer,
	account_id integer,
	occurred_at timestamp,
	standard_qty integer,
	gloss_qty integer,
	poster_qty integer,
	total integer,
	standard_amt_usd numeric(10,2),
	gloss_amt_usd numeric(10,2),
	poster_amt_usd numeric(10,2),
	total_amt_usd numeric(10,2)
);
```

**accounts**

```console
CREATE TABLE accounts (
	id integer,
	name bpchar,
	website bpchar,
	lat numeric(11,8),
	long numeric(11,8),
	primary_poc bpchar,
	sales_rep_id integer
);
```

We clearly see that the PRIMARY KEY constraint is missing in all the CREATE TABLE statements.

So, what are the PRIMARY KEY in these tables?

## ERD Parch and Posey

![parch and posey erd](../01_basic_sql/images/03_erd_parchposey.png)

Logically the `id` column of each table is the **Primary Key**.

For instance, if we wanted to create the **events** table with a PRIMARY KEY then you define the PRIMARY KEY constraint as follows:

**web_events**

```console
CREATE TABLE web_events (
	id integer PRIMARY KEY,
	account_id integer,
	occurred_at timestamp,
	channel bpchar
);
```

How do we define the PRIMARY KEY constraint to an existing table?

### Define primary key when changing the existing table structure

It is rare to define a primary key for existing table. In case you have to do it, you can use the [ALTER TABLE](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-alter-table/) statement to add a primary key constraint.

- `ALTER TABLE table_name ADD PRIMARY KEY (column_1);`

- `ALTER TABLE table_name ADD PRIMARY KEY (column_1, column_2);`

In the case of the **web_events** table:

```console
parch_posey=> ALTER TABLE web_events ADD PRIMARY KEY (id);
ALTER TABLE
```

Now, if we run the describe table command `\d web_events`:

```console
parch_posey=> \d web_events
                         Table "public.web_events"
   Column    |            Type             | Collation | Nullable | Default
-------------+-----------------------------+-----------+----------+---------
 id          | integer                     |           | not null |
 account_id  | integer                     |           |          |
 occurred_at | timestamp without time zone |           |          |
 channel     | bpchar                      |           |          |
Indexes:
    "web_events_pkey" PRIMARY KEY, btree (id)
```

The output shows that the `web_events_pkey` PRIMARY KEY of the `web_events` table is the `id` column. Note that the `id` column has the **not null** constraint.

We'll now execute the ALTER TABLE command on the remaining tables.

**accounts**

```console
parch_posey=> ALTER TABLE accounts ADD PRIMARY KEY (id);
ALTER TABLE
```

**orders**

```console
parch_posey=> ALTER TABLE orders ADD PRIMARY KEY (id);
ALTER TABLE
```

**region**

```console
parch_posey=> ALTER TABLE region ADD PRIMARY KEY (id);
ALTER TABLE
```

**sales_reps**

```console
parch_posey=> ALTER TABLE sales_reps ADD PRIMARY KEY (id);
ALTER TABLE
```

## Removing a Primary Key

We can remove an existing primary key by using the `DROP CONSTRAINT` keyword in the alter table syntax.

```console
ALTER TABLE table_name DROP CONSTRAINT primary_key_constraint;
```
