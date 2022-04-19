# Deleting all Records From a Table

SQL also provides a very easy way to delete all records from a table: Simply omit the `WHERE` clause.

## Using PostgreSQL DELETE to delete all rows from the table

![uniY tables3](../00_basic_intro/images/07_uniY.png)

If, for example, we wished to delete the record of every student in the uniY sample database, we could type:

```console
DELETE FROM students;
```

While to delete all the **teachers** table records, the command is:

```console
DELETE FROM teachers;
```
