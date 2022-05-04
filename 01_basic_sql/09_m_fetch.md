# Introduction to FETCH clause

To constrain the number of rows returned by a query, you often use the `LIMIT` clause. The `LIMIT` clause is widely used by many relational database management systems such as `MySQL`, `H2`, and `HSQLDB`. However, the `LIMIT` clause **is not a SQL-standard**.

To conform with the SQL standard, PostgreSQL supports the `FETCH` clause to retrieve a number of rows returned by a query. Note that the `FETCH` clause was introduced in SQL:`2008`.

The following illustrates the syntax of the PostgreSQL `FETCH` clause:

```console
OFFSET start { ROW | ROWS }
FETCH { FIRST | NEXT } [ row_count ] { ROW | ROWS } ONLY
```

In this syntax:

- `ROW` is the synonym for ROWS, `FIRST` is the synonym for NEXT . SO you can use them interchangeably
- The `start` is an integer that **must be zero or positive**. By default, it is zero if the `OFFSET` clause is not specified. In case the `start` is greater than the number of rows in the result set, no rows are returned;
- The `row_count` is **1 or greater**. By default, the default value of `row_count` is 1 if you do not specify it explicitly.


Because the order of rows stored in the table is unspecified, you should always use the `FETCH` clause with the `ORDER BY` clause to make the order of rows in the returned result set consistent.

Note that the `OFFSET` clause must come before the `FETCH` clause in SQL:2008. However, OFFSET and FETCH clauses can appear in any order in PostgreSQL.

## FETCH vs. LIMIT

The `FETCH` clause is functionally equivalent to the `LIMIT` clause. If you plan to make your application compatible with other database systems, you should use the `FETCH` clause because it follows the standard SQL.

## DVDRENTAL PostgreSQL FETCH examples

Let’s use the `film` table in the sample database for the demonstration.

```console
dvdrental=# \d film
                                              Table "public.film"
      Column      |            Type             | Collation | Nullable |                Default
------------------+-----------------------------+-----------+----------+---------------------------------------
 film_id          | integer                     |           | not null | nextval('film_film_id_seq'::regclass)
 title            | character varying(255)      |           | not null |
 description      | text                        |           |          |
 release_year     | year                        |           |          |
 language_id      | smallint                    |           | not null |
 rental_duration  | smallint                    |           | not null | 3
 rental_rate      | numeric(4,2)                |           | not null | 4.99
 length           | smallint                    |           |          |
 replacement_cost | numeric(5,2)                |           | not null | 19.99
 rating           | mpaa_rating                 |           |          | 'G'::mpaa_rating
 last_update      | timestamp without time zone |           | not null | now()
 special_features | text[]                      |           |          |
 fulltext         | tsvector                    |           | not null |
Indexes:
    "film_pkey" PRIMARY KEY, btree (film_id)
```
The following query use the `FETCH` clause **to select the first film** sorted by `titles in ascending order`:

**Query**
```console
dvdrental=# SELECT film_id, title
dvdrental-#   FROM film
dvdrental-#  ORDER BY title
dvdrental-#  FETCH FIRST ROW ONLY;
```

**Output**
```console
 film_id |      title
---------+------------------
       1 | Academy Dinosaur
(1 row)
```

It is equivalent to the following query:

**Query**

```console
dvdrental=# SELECT film_id, title
dvdrental-#   FROM film
dvdrental-#  ORDER BY title
dvdrental-#  FETCH FIRST 1 ROW ONLY;
```
**Output**
```console
 film_id |      title
---------+------------------
       1 | Academy Dinosaur
(1 row)
```

The following query use the FETCH clause to select **the first five films sorted by titles**:

**Query**
```console
dvdrental=# SELECT film_id, title
dvdrental-#   FROM film
dvdrental-#  ORDER BY title
dvdrental-#  FETCH FIRST 5 ROW ONLY;
```

**Output**
```console
 film_id |      title
---------+------------------
       1 | Academy Dinosaur
       2 | Ace Goldfinger
       3 | Adaptation Holes
       4 | Affair Prejudice
       5 | African Egg
(5 rows)
```

The following statement returns **the next five films after the first five films sorted by titles**:

**Query**
```console
dvdrental=# SELECT film_id, title
dvdrental-#   FROM film
dvdrental-#  ORDER BY title
dvdrental-#  OFFSET 5 ROWS
dvdrental-#  FETCH FIRST 5 ROW ONLY;
```
**Output**
```console
 film_id |      title
---------+------------------
       6 | Agent Truman
       7 | Airplane Sierra
       8 | Airport Pollock
       9 | Alabama Devil
      10 | Aladdin Calendar
(5 rows)
```
