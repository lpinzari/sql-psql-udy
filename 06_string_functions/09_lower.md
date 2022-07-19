# LOWER Function PostgreSQL

To convert a `string`, an `expression`, or values in a column to **lower case**, you use the **LOWER** case function. The following illustrates the syntax of the **LOWER** function:

```SQL
LOWER(string_expression)
```
The `LOWER` function accepts an argument that is a string e.g., `char`, `varchar`, or `text` and **converts it to lower case format**. If the argument is string-convertible, you use the `CAST` **function to explicitly convert it to a string**.

The following statement uses `LOWER` function and `CONCAT_WS` function to get the full names of customers:

```SQL
SELECT concat_ws ( ', ', LOWER (last_name), LOWER (first_name)) as name
  FROM customer
 ORDER BY last_name
 LIMIT 3;
```

**Results**

|name|
|:---------------:|
|abney, rafael|
|adam, nathaniel|
|adams, kathleen|

The following statement uses the `CONCAT_WS` function and `LOWER` function to get the title, description, and year of **films** in the **film** table of the `dvdrental` sample database. Because `release_year` is a number, therefore we have to use type `cast` to **convert it to a string**.

Note that this example is just for demonstration only. You can remove the `LOWER` function that applies to the `release_year` column because it is not necessary.

```SQL
SELECT CONCAT_WS (' - ',
       title,
       LOWER (description),
       LOWER (CAST(release_year AS TEXT))
     ) AS film_info
  FROM film
 LIMIT 3;
```

**Results**

|film_info|
|:------------------------------------------------------------------------------------------------------------:|
|Chamber Italian - a fateful reflection of a moose and a husband who must overcome a monkey in nigeria - 2006|
|Grosse Wonderful - a epic drama of a cat and a explorer who must redeem a moose in australia - 2006|
|Airport Pollock - a epic tale of a moose and a girl who must confront a monkey in ancient india - 2006|
