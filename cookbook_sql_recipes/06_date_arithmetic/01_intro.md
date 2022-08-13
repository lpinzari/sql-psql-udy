# Date Arithmetic

This chapter introduces techniques for performing simple date arithmetic. Recipes cover common tasks such as adding days to dates, finding the number of business days between dates, and finding the difference between dates in days.
Being able to successfully manipulate dates with your RDBMS’s built-in functions can greatly improve your productivity. For all the recipes in this chapter, we try to take advantage of each RDBMS’s built-in functions.

For Additional information about `Date` data type format in PostgreSql please refer to the following resource: [Date](https://github.com/lpinzari/sql-psql-udy/blob/master/04_sql_aggregations/14_date_grouping.md).

## Introduction to the PostgreSQL DATE data type

To store date values, you use the PostgreSQL `DATE` data type. PostgreSQL uses `4` bytes to store a date value.

The `lowest` and `highest` values of the `DATE` data type are `4713 BC` and `5874897 AD`.

When storing a date value, PostgreSQL uses the  **yyyy-mm-dd** format e.g.:

- `YYYY-MM-DD`: `2000-12-31`

It also uses this format for inserting data into a `date` column.

If you create a table that has a `DATE` column and you want to use the current date as the default value for the column, you can use the `CURRENT_DATE` after the `DEFAULT` keyword.

For example, the following statement creates the **documents** table that has the `posting_date` column with the `DATE` data type. The `posting_date` column accepts the current date as the default value.

```SQL
DROP TABLE IF EXISTS documents;

CREATE TABLE documents (
	document_id serial PRIMARY KEY,
	header_text VARCHAR (255) NOT NULL,
	posting_date DATE NOT NULL DEFAULT CURRENT_DATE
);

INSERT INTO documents (header_text)
VALUES('Billing to customer XYZ');

SELECT * FROM documents;
```

The following shows the output of the query above. Note that you may get a different posting date value based on the current date of the database server.

```console
document_id |       header_text       | posting_date
-------------+-------------------------+--------------
          1 | Billing to customer XYZ | 2021-07-06
(1 row)
```


## Timestamp

Timestamps are data types that contain both `time` and `date` parts. Timestamps are long and contain a ton of info on when an event occurred: The `year`, `month`, `day`, `hour`, `minute`, `second`, `millisecond`, and `zulu`, `UTC`.


- `2021-12-31 23:59:59`

For a complete description please refer to the following resource: [Date](https://github.com/lpinzari/sql-psql-udy/blob/master/04_sql_aggregations/14_date_grouping.md).
