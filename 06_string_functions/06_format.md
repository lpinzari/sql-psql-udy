# FORMAT Function PostgreSQL

PostgreSQL **FORMAT()** function **formats arguments based on a format string**.

If you have worked with the C programming language, you will find that the FORMAT() function is similar to the `sprintf()` function.

The syntax of the PostgreSQL **FORMAT()** function is as follows:

```SQL
FORMAT(format_string [, format_arg [, ...] ])
```
The `FORMAT()` function is **variadic**, therefore, you can pass the arguments to be formatted as an **array marked with the** `VARIADIC` keyword.

The `FORMAT()` function treats the array’s elements as ordinary arguments and `NULL` as an array of zero elements.

## Arguments

1. **format_string**: The `format_string` argument is a string that specifies how the result string should be formatted.

The `format_string` consists of **text** and format **specifiers**. `Text` is copied directly to the result string while the `format specifiers` are **placeholders for the arguments to be inserted into the result string**.

The following shows the syntax of the `format specifier`:

```SQL
%[position][flags][width]type
```

A format specifier starts with `%` character. It has three optional components **position**, **flags**, **width** and a required component **type**.

### position

The `position` specifies which argument to be inserted in the result string. The position is in the form `n$` where `n` is the argument index. The first argument starts from `1`.

If you omit the position component, the default is the next argument in the list.

### flags

Currently, the flags can accept a minus sign (`-`) that instructs the format specifier’s output to be `left-justified`.

The flags component only takes effect when the width field is specified.

### width

The optional **width** field specifies the **minimum number of characters to use for displaying the format specifier’s output**.

The result string can be `padded left or right` with the spaces needed to fill the width.

If the **width** is too small, the output will be displayed as-is without any truncation.

The **width** can be one of the following values:

- A positive integer.
- An asterisk (*) to use the next function argument as the width.
- A string of the form `*n$` to use the nth function argument as the width.

### type

**type** is the type of format conversion to use to produce the format specifier’s output.

The permitted values for type argument are as follows:

- `s` formats the argument value as a string. NULL is treated as an empty string.
- `I` treats the argument value as an SQL identifier.
- `L` quotes the argument value as an SQL literal.

We often use `I` and `L` for constructing dynamic SQL statements.

If you want to include `%` in the result string, use double percentages `%%`.

2. **format_arg**: As mentioned earlier, you pass a number of format arguments to the FORMAT() function.

## Return value

The FORMAT() function returns a formatted string.

## Examples

Let’s take a look at some examples of using the FORMAT() function.

-  **Simple format**

The following statement uses the **FORMAT()** function to format a string:

```SQL
SELECT FORMAT('Hello, %s','PostgreSQL');
```

**Results**

|format|
|:-----------------:|
|Hello, PostgreSQL|

In this example, `%s` is replaced by the `'PostgreSQL'` string argument.

See the following **customer** table in `dvdrental` sample database.

```console
dvdrental=# \d customer
                                             Table "public.customer"
   Column    |            Type             | Collation | Nullable |                    Default
-------------+-----------------------------+-----------+----------+-----------------------------------------------
 customer_id | integer                     |           | not null | nextval('customer_customer_id_seq'::regclass)
 store_id    | smallint                    |           | not null |
 first_name  | character varying(45)       |           | not null |
 last_name   | character varying(45)       |           | not null |
 email       | character varying(50)       |           |          |
 address_id  | smallint                    |           | not null |
 activebool  | boolean                     |           | not null | true
 create_date | date                        |           | not null | ('now'::text)::date
 last_update | timestamp without time zone |           |          | now()
 active      | integer                     |           |          |
```

The following statement uses the FORMAT() function to construct customers’ full names from first names and last names:

```SQL
SELECT FORMAT('%s, %s',last_name, first_name) full_name
  FROM customer
 ORDER BY full_name;
```

**Results**

|full_name|
|:----------------------:|
|Abney, Rafael|
|Adam, Nathaniel|
|Adams, Kathleen|
|Alexander, Diana|
|Allard, Gordon|
|Allen, Shirley|
|Alvarez, Charlene|

In this example, we used two format specifiers %s %s which are then replaced by values in the first_name and last_name columns.

For more example see the following link: [examples](https://www.postgresqltutorial.com/postgresql-string-functions/postgresql-format/).
