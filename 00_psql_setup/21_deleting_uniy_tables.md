# PostgreSQL TRUNCATE TABLE

In this lesson you will learn how to use PostgreSQL `TRUNCATE TABLE` statement **to quickly delete all data from large tables**.

## Introduction to PostgreSQL TRUNCATE TABLE statement

To remove all data from a table, you use the `DELETE` statement. However, when you use the `DELETE` statement to delete all data from a table that has a lot of data, **it is not efficient**. In this case, you need to use the `TRUNCATE TABLE` statement:

```console
TRUNCATE TABLE table_name;
```

The  `TRUNCATE TABLE` statement deletes all data from a table **without scanning it**. This is the reason why it is faster than the DELETE statement.

In addition, the `TRUNCATE TABLE` statement **reclaims the storage right away** so you do not have to perform a subsequent `VACUMM` operation, which is useful in the case of large tables.

## Remove all data from one table

The simplest form of the  `TRUNCATE TABLE` statement is as follows:

```console
TRUNCATE TABLE table_name;
```

The following CREATE TABLE statement creates a new table name invoices with the not-null constraints.

```console
CREATE TABLE invoices(
  id SERIAL PRIMARY KEY,
  product_id INT NOT NULL,
  qty numeric NOT NULL CHECK(qty > 0),
  net_price numeric CHECK(net_price > 0)
);
```

The following example uses the TRUNCATE TABLE statement to delete all data from the invoices table:

```console
TRUNCATE TABLE invoices;
```

Besides removing data, you may want to reset the values in the [identity](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-identity-column/) column by using the `RESTART IDENTITY` option like this:

```console
TRUNCATE TABLE table_name
RESTART IDENTITY;
```

For example, the following statement removes all rows from the **invoices** table and resets the [sequence](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-sequences/) associated with the  `invoice_no` column:

```console
TRUNCATE TABLE invoices
RESTART IDENTITY;
```

By default, the  `TRUNCATE TABLE` statement uses the `CONTINUE IDENTITY` option. This option basically does not restart the value in sequence associated with the column in the table.

## Remove all data from multiple tables

To remove all data from multiple tables at once, you separate each table by a comma (,) as follows:

```console
TRUNCATE TABLE
    table_name1,
    table_name2,
    ...;
```

For example, the following statement removes all data from **invoices** and **customers** tables:

```console
TRUNCATE TABLE invoices, customers;
```

## Remove all data from a table that has foreign key references

In practice, the table you want to truncate often has the **foreign key references** from other tables that are not listed in the  `TRUNCATE TABLE` statement.

By default, the  `TRUNCATE TABLE` statement **does not remove any data from the table that has foreign key references**.

To remove data from a table and other tables that have foreign key reference the table, you use `CASCADE` option in the `TRUNCATE TABLE` statement as follows :

```console
TRUNCATE TABLE table_name
CASCADE;
```

The `CASCADE` option should be used with further consideration or you may potentially delete data from tables that you did not want.

By default, the `TRUNCATE TABLE` statement uses the `RESTRICT` option which prevents you from truncating the table that has foreign key constraint references.

## PostgreSQL TRUNCATE TABLE and ON DELETE trigger

Even though the  `TRUNCATE TABLE` statement removes all data from a table, it does not fire any  `ON DELETE` [triggers](https://www.postgresqltutorial.com/postgresql-triggers/) associated with the table.

To fire the trigger when the  `TRUNCATE TABLE` command applied to a table, you must define  `BEFORE TRUNCATE` and/or  `AFTER TRUNCATE` triggers for that table.

## PostgreSQL TRUNCATE TABLE and transaction

The  `TRUNCATE TABLE` **is transaction-safe**. It means that if you place it within a transaction, you can roll it back safely.
