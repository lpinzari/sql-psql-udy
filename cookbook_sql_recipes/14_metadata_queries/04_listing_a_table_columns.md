# Listing a Table’s Columns


You want to list the **columns in a table**, along with their
- ordinal position,
- column default value,
- if it is nullable,
- data_type

## Problem

List all the above mentioned information about the `film` and `actor` tables in the `dvdrental` database.


## Solution

```console
information_schema
     |
     +-- columns

information_schema.tables.
```

```SQL
SELECT table_name,
       column_name,
       ordinal_position,
       column_default,
       is_nullable,
       data_type
  FROM information_schema.columns
 WHERE table_schema = 'public' AND table_name IN ('film','actor')
 ORDER BY table_name, ordinal_position;
```

Output

```console
table_name |   column_name    | ordinal_position |             column_default              | is_nullable |          data_type
------------+------------------+------------------+-----------------------------------------+-------------+-----------------------------
actor      | actor_id         |                1 | nextval('actor_actor_id_seq'::regclass) | NO          | integer
actor      | first_name       |                2 |                                         | NO          | character varying
actor      | last_name        |                3 |                                         | NO          | character varying
actor      | last_update      |                4 | now()                                   | NO          | timestamp without time zone
film       | film_id          |                1 | nextval('film_film_id_seq'::regclass)   | NO          | integer
film       | title            |                2 |                                         | NO          | character varying
film       | description      |                3 |                                         | YES         | text
film       | release_year     |                4 |                                         | YES         | integer
film       | language_id      |                5 |                                         | NO          | smallint
film       | rental_duration  |                6 | 3                                       | NO          | smallint
film       | rental_rate      |                7 | 4.99                                    | NO          | numeric
film       | length           |                8 |                                         | YES         | smallint
film       | replacement_cost |                9 | 19.99                                   | NO          | numeric
film       | rating           |               10 | 'G'::mpaa_rating                        | YES         | USER-DEFINED
film       | last_update      |               11 | now()                                   | NO          | timestamp without time zone
film       | special_features |               12 |                                         | YES         | ARRAY
film       | fulltext         |               13 |                                         | NO          | tsvector
(17 rows)
```

```SQL
SELECT column_name
       column_default,
       is_nullable,
       data_type,
       character_maximum_length,
       numeric_precision,
       datetime_precision
  FROM information_schema.columns
 WHERE table_schema = 'public' AND table_name = 'actor'
 ORDER BY ordinal_position;
```

```console
column_default | is_nullable |          data_type          | character_maximum_length | numeric_precision | datetime_precision
----------------+-------------+-----------------------------+--------------------------+-------------------+--------------------
actor_id       | NO          | integer                     |                          |                32 |
first_name     | NO          | character varying           |                       45 |                   |
last_name      | NO          | character varying           |                       45 |                   |
last_update    | NO          | timestamp without time zone |                          |                   |                  6
(4 rows)
```

## Discussion

Each vendor provides ways for you to get detailed information about your column data. In the previous examples, only a few information returned. Additional useful items of information include other attributes in the `information_schema.columns` table.

We can list all the columns available in the `information_schema.columns` with the following command:

```console
dvdrental=# \d information_schema.columns
                              View "information_schema.columns"
         Column          |                Type                | Collation | Nullable | Default
--------------------------+------------------------------------+-----------+----------+---------
table_catalog            | information_schema.sql_identifier  |           |          |
table_schema             | information_schema.sql_identifier  |           |          |
table_name               | information_schema.sql_identifier  |           |          |
column_name              | information_schema.sql_identifier  |           |          |
ordinal_position         | information_schema.cardinal_number |           |          |
column_default           | information_schema.character_data  |           |          |
is_nullable              | information_schema.yes_or_no       |           |          |
data_type                | information_schema.character_data  |           |          |
character_maximum_length | information_schema.cardinal_number |           |          |
character_octet_length   | information_schema.cardinal_number |           |          |
numeric_precision        | information_schema.cardinal_number |           |          |
numeric_precision_radix  | information_schema.cardinal_number |           |          |
numeric_scale            | information_schema.cardinal_number |           |          |
datetime_precision       | information_schema.cardinal_number |           |          |
interval_type            | information_schema.character_data  |           |          |
interval_precision       | information_schema.cardinal_number |           |          |
character_set_catalog    | information_schema.sql_identifier  |           |          |
character_set_schema     | information_schema.sql_identifier  |           |          |
character_set_name       | information_schema.sql_identifier  |           |          |
collation_catalog        | information_schema.sql_identifier  |           |          |
collation_schema         | information_schema.sql_identifier  |           |          |
collation_name           | information_schema.sql_identifier  |           |          |
domain_catalog           | information_schema.sql_identifier  |           |          |
domain_schema            | information_schema.sql_identifier  |           |          |
domain_name              | information_schema.sql_identifier  |           |          |
udt_catalog              | information_schema.sql_identifier  |           |          |
udt_schema               | information_schema.sql_identifier  |           |          |
udt_name                 | information_schema.sql_identifier  |           |          |
scope_catalog            | information_schema.sql_identifier  |           |          |
scope_schema             | information_schema.sql_identifier  |           |          |
scope_name               | information_schema.sql_identifier  |           |          |
maximum_cardinality      | information_schema.cardinal_number |           |          |
dtd_identifier           | information_schema.sql_identifier  |           |          |
is_self_referencing      | information_schema.yes_or_no       |           |          |
is_identity              | information_schema.yes_or_no       |           |          |
identity_generation      | information_schema.character_data  |           |          |
identity_start           | information_schema.character_data  |           |          |
identity_increment       | information_schema.character_data  |           |          |
identity_maximum         | information_schema.character_data  |           |          |
identity_minimum         | information_schema.character_data  |           |          |
identity_cycle           | information_schema.yes_or_no       |           |          |
is_generated             | information_schema.character_data  |           |          |
generation_expression    | information_schema.character_data  |           |          |
is_updatable             | information_schema.yes_or_no       |           |          |
```
