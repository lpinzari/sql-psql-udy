# PostgreSQL UNIQUE CONSTRAINT

In this lesson, you will learn about PostgreSQL `UNIQUE` constraint to make sure that `values stored in a column or a group of columns` **are unique across rows in a table**.

## UNIQUE CONSTRAINT

Sometimes, you want to ensure that values stored in a column or a group of columns are unique across the whole table such as `email addresses` or `usernames`.

PostgreSQL provides you with the `UNIQUE` constraint that maintains the uniqueness of the data correctly.

When a `UNIQUE` constraint is in place, every time you `insert a new row`,

- it checks if the value is already in the table. It rejects the change and issues an error if the value already exists. The same process is carried out for `updating existing data`.

When you add a UNIQUE constraint to a column or a group of columns, PostgreSQL will automatically create a [unique index](https://www.postgresqltutorial.com/postgresql-indexes/postgresql-unique-index/) on the column or the group of columns.

## PostgreSQL UNIQUE constraint example

The following statement `creates` a new table named **person** with a `UNIQUE` **constraint** for the `email` **column**.

```console
CREATE TABLE person (
	id SERIAL PRIMARY KEY,
	first_name VARCHAR (50),
	last_name VARCHAR (50),
	email VARCHAR (50) UNIQUE
);
```

Note that the UNIQUE constraint above can be rewritten as a **table constraint** as shown in the following query:

```console
CREATE TABLE person (
	id SERIAL  PRIMARY KEY,
	first_name VARCHAR (50),
	last_name  VARCHAR (50),
	email      VARCHAR (50),
  UNIQUE(email)
);
```

First, `insert` a new row into the **person** table using `INSERT` statement:

```console
INSERT INTO person(first_name,last_name,email)
       VALUES ('john','doe','j.doe@postgresqltutorial.com');
```
Second, insert another row with duplicate email:

```console
INSERT INTO person(first_name,last_name,email)
       VALUES ('jack','doe','j.doe@postgresqltutorial.com');
```

PostgreSQL issued an error message.

```console
[Err] ERROR:  duplicate key value violates unique constraint "person_email_key"
DETAIL:  Key (email)=(j.doe@postgresqltutorial.com) already exists.
```

## Creating a UNIQUE constraint on multiple columns

PostgreSQL allows you to create a `UNIQUE` constraint to a group of columns using the following syntax:

```console
CREATE TABLE table (
    c1 data_type,
    c2 data_type,
    c3 data_type,
    UNIQUE (c2, c3)
);
```

The combination of values in column c2 and c3 will be unique across the whole table. The value of the column c2 or c3 needs not to be unique.
