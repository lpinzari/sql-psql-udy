# REPLACE Function PostgreSQL

Sometimes, you want to search and replace a string in a column with a new one such as replacing outdated phone numbers, broken URLs, and spelling mistakes.

To search and replace all occurrences of a string with a new one, you use the **REPLACE()** function.

The following illustrates the syntax of the PostgreSQL **REPLACE()** function:

```SQL
REPLACE(source, old_text, new_text );
```

The **REPLACE()** function accepts three arguments:

- `source` is a string where you want to replace.
- `old_text` is the text that you want to search and replace. If the `old_text` appears multiple times in the string, all of its occurrences will be replaced.
- `new_text` is the new text that will replace the old text ( `old_text`).

## PostgreSQL REPLACE() function examples

See the following example of using the **REPLACE()** function:

```SQL
SELECT REPLACE ('ABC AA', 'A', 'Z');
```

**Results**

|replace|
|:-------:|
|ZBC ZZ|

If you want to **search and replace a substring in a table column**, you use the following syntax:

```SQL
UPDATE
   table_name
SET
   column_name = REPLACE(column,old_text,new_text)
WHERE
   condition
```

Let’s use the `customer` table in the `dvdrental` sample database for the demonstration. Now, suppose you want to update the email column to replace the domain `sakilacustomer.org` with `postgresqltutorial.com`, you use the following statement:

```SQL
UPDATE
   customer
SET
   email = REPLACE (
  	email,
	'sakilacustomer.org',
	'postgresqltutorial.com'
   );
```

Because we omitted the `WHERE` clause, all rows in the `customer` table were updated.
