# Pg_catalog: DATA DICTIONARY

In addition to public and user-created schemas, each database contains a `pg_catalog` schema, which contains the system tables and all the built-in data types, functions, and operators.

These are a set of tables used to store dynamic and static metadata for the PostgreSQL database and can be thought of as the “**data dictionary**” for the database. These tables are used for internal “bookkeeping”-type activities. All System catalog tables start with the `pg_`**prefix** and can be found in the [pg_catalog schema](https://www.postgresql.org/docs/11/catalogs-overview.html).

A "**Data Dictionary**" is simply a list of tables and views, their column properties such as name, ordinal position, data type/length/size/precision, allows nulls, and of course the column description. A good data dictionary also indicates which columns are a part of a primary key, foreign key, unique key, or distribution key.


## Problem


In this chapter, we're going to discuss on how to generate a **data dictionary**  from an existing schema using a sql in PostgreSql.

Let's say we are connected to the `dvdrental` database and we want to draw the `ER-diagram`.  The `ER-diagram` is given below:

![dvdrental erd](./images/16_dvdrental.png)

WE want to have all the information contained in the `ER-digram` automatically generated into a `DATA DICTIONARY` from an output schema.

We want to return the following **Output**:

```console
schema_nm |          table_nm          | obj_typ | ord_pos |    column_nm     |          data_typ           | nullable |       def_val       |   type_ctg   | is_key | fk_ref_table | fk_ref_col_name | update_rule | delete_rule
-----------+----------------------------+---------+---------+------------------+-----------------------------+----------+---------------------+--------------+--------+--------------+-----------------+-------------+-------------
public    | actor                      | TBL     |       1 | actor_id         | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK     |              |                 |             |
public    | actor                      | TBL     |       2 | first_name       | character varying(45)       | NOT NULL |                     | String       |        |              |                 |             |
public    | actor                      | TBL     |       3 | last_name        | character varying(45)       | NOT NULL |                     | String       |        |              |                 |             |
public    | actor                      | TBL     |       4 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |        |              |                 |             |
public    | address                    | TBL     |       1 | address_id       | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK     |              |                 |             |
public    | address                    | TBL     |       2 | address          | character varying(50)       | NOT NULL |                     | String       |        |              |                 |             |
public    | address                    | TBL     |       3 | address2         | character varying(50)       | NULL     |                     | String       |        |              |                 |             |
public    | address                    | TBL     |       4 | district         | character varying(20)       | NOT NULL |                     | String       |        |              |                 |             |
public    | address                    | TBL     |       5 | city_id          | smallint(16)                | NOT NULL |                     | Numeric      | FK     | city         | city_id         | NO ACTION   | NO ACTION
public    | address                    | TBL     |       6 | postal_code      | character varying(10)       | NULL     |                     | String       |        |              |                 |             |
public    | address                    | TBL     |       7 | phone            | character varying(20)       | NOT NULL |                     | String       |        |              |                 |             |
public    | address                    | TBL     |       8 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |        |              |                 |             |
public    | category                   | TBL     |       1 | category_id      | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK     |              |                 |             |
public    | category                   | TBL     |       2 | name             | character varying(25)       | NOT NULL |                     | String       |        |              |                 |             |
public    | category                   | TBL     |       3 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |        |              |                 |             |
public    | city                       | TBL     |       1 | city_id          | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK     |              |                 |             |
public    | city                       | TBL     |       2 | city             | character varying(50)       | NOT NULL |                     | String       |        |              |                 |             |
public    | city                       | TBL     |       3 | country_id       | smallint(16)                | NOT NULL |                     | Numeric      | FK     | country      | country_id      | NO ACTION   | NO ACTION
public    | city                       | TBL     |       4 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |        |              |                 |             |
public    | country                    | TBL     |       1 | country_id       | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK     |              |                 |             |
public    | country                    | TBL     |       2 | country          | character varying(50)       | NOT NULL |                     | String       |        |              |                 |             |
public    | country                    | TBL     |       3 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |        |              |                 |             |
public    | customer                   | TBL     |       1 | customer_id      | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK     |              |                 |             |
public    | customer                   | TBL     |       2 | store_id         | smallint(16)                | NOT NULL |                     | Numeric      |        |              |                 |             |
public    | customer                   | TBL     |       3 | first_name       | character varying(45)       | NOT NULL |                     | String       |        |              |                 |             |
public    | customer                   | TBL     |       4 | last_name        | character varying(45)       | NOT NULL |                     | String       |        |              |                 |             |
public    | customer                   | TBL     |       5 | email            | character varying(50)       | NULL     |                     | String       |        |              |                 |             |
public    | customer                   | TBL     |       6 | address_id       | smallint(16)                | NOT NULL |                     | Numeric      | FK     | address      | address_id      | CASCADE     | RESTRICT
public    | customer                   | TBL     |       7 | activebool       | boolean                     | NOT NULL | true                | Boolean      |        |              |                 |             |
public    | customer                   | TBL     |       8 | create_date      | date(3)                     | NOT NULL | ('now'::text)::date | Composite    |        |              |                 |             |
public    | customer                   | TBL     |       9 | last_update      | timestamp without time zone | NULL     | now()               | Composite    |        |              |                 |             |
public    | customer                   | TBL     |      10 | active           | integer(32)                 | NULL     |                     | Numeric      |        |              |                 |             |
public    | film                       | TBL     |       1 | film_id          | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK     |              |                 |             |
public    | film                       | TBL     |       2 | title            | character varying(255)      | NOT NULL |                     | String       |        |              |                 |             |
public    | film                       | TBL     |       3 | description      | text                        | NULL     |                     | String       |        |              |                 |             |
public    | film                       | TBL     |       4 | release_year     | integer(32)                 | NULL     |                     | Numeric      |        |              |                 |             |
public    | film                       | TBL     |       5 | language_id      | smallint(16)                | NOT NULL |                     | Numeric      | FK     | language     | language_id     | CASCADE     | RESTRICT
public    | film                       | TBL     |       6 | rental_duration  | smallint(16)                | NOT NULL | 3                   | Numeric      |        |              |                 |             |
public    | film                       | TBL     |       7 | rental_rate      | numeric(4,2)                | NOT NULL | 4.99                | Numeric      |        |              |                 |             |
public    | film                       | TBL     |       8 | length           | smallint(16)                | NULL     |                     | Numeric      |        |              |                 |             |
public    | film                       | TBL     |       9 | replacement_cost | numeric(5,2)                | NOT NULL | 19.99               | Numeric      |        |              |                 |             |
public    | film                       | TBL     |      10 | rating           | USER-DEFINED                | NULL     | 'G'::mpaa_rating    | Enum         |        |              |                 |             |
public    | film                       | TBL     |      11 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |        |              |                 |             |
public    | film                       | TBL     |      12 | special_features | ARRAY                       | NULL     |                     | Array        |        |              |                 |             |
public    | film                       | TBL     |      13 | fulltext         | tsvector                    | NOT NULL |                     | User-defined |        |              |                 |             |
public    | film_actor                 | TBL     |       1 | actor_id         | smallint(16)                | NOT NULL |                     | Numeric      | FK,PK  | actor        | actor_id        | CASCADE     | RESTRICT
public    | film_actor                 | TBL     |       2 | film_id          | smallint(16)                | NOT NULL |                     | Numeric      | FK,PK  | film         | film_id         | CASCADE     | RESTRICT
public    | film_actor                 | TBL     |       3 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |        |              |                 |             |
public    | film_category              | TBL     |       1 | film_id          | smallint(16)                | NOT NULL |                     | Numeric      | FK,PK  | film         | film_id         | CASCADE     | RESTRICT
public    | film_category              | TBL     |       2 | category_id      | smallint(16)                | NOT NULL |                     | Numeric      | FK,PK  | category     | category_id     | CASCADE     | RESTRICT
public    | film_category              | TBL     |       3 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |        |              |                 |             |
public    | inventory                  | TBL     |       1 | inventory_id     | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK     |              |                 |             |
public    | inventory                  | TBL     |       2 | film_id          | smallint(16)                | NOT NULL |                     | Numeric      | FK     | film         | film_id         | CASCADE     | RESTRICT
public    | inventory                  | TBL     |       3 | store_id         | smallint(16)                | NOT NULL |                     | Numeric      |        |              |                 |             |
public    | inventory                  | TBL     |       4 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |        |              |                 |             |
public    | language                   | TBL     |       1 | language_id      | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK     |              |                 |             |
public    | language                   | TBL     |       2 | name             | character(20)               | NOT NULL |                     | String       |        |              |                 |             |
public    | language                   | TBL     |       3 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |        |              |                 |             |
public    | payment                    | TBL     |       1 | payment_id       | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK     |              |                 |             |
public    | payment                    | TBL     |       2 | customer_id      | smallint(16)                | NOT NULL |                     | Numeric      | FK     | customer     | customer_id     | CASCADE     | RESTRICT
public    | payment                    | TBL     |       3 | staff_id         | smallint(16)                | NOT NULL |                     | Numeric      | FK     | staff        | staff_id        | CASCADE     | RESTRICT
public    | payment                    | TBL     |       4 | rental_id        | integer(32)                 | NOT NULL |                     | Numeric      | FK     | rental       | rental_id       | CASCADE     | SET NULL
public    | payment                    | TBL     |       5 | amount           | numeric(5,2)                | NOT NULL |                     | Numeric      |        |              |                 |             |
public    | payment                    | TBL     |       6 | payment_date     | timestamp without time zone | NOT NULL |                     | Composite    |        |              |                 |             |
public    | rental                     | TBL     |       1 | rental_id        | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK     |              |                 |             |
public    | rental                     | TBL     |       2 | rental_date      | timestamp without time zone | NOT NULL |                     | Composite    |        |              |                 |             |
public    | rental                     | TBL     |       3 | inventory_id     | integer(32)                 | NOT NULL |                     | Numeric      | FK     | inventory    | inventory_id    | CASCADE     | RESTRICT
public    | rental                     | TBL     |       4 | customer_id      | smallint(16)                | NOT NULL |                     | Numeric      | FK     | customer     | customer_id     | CASCADE     | RESTRICT
public    | rental                     | TBL     |       5 | return_date      | timestamp without time zone | NULL     |                     | Composite    |        |              |                 |             |
public    | rental                     | TBL     |       6 | staff_id         | smallint(16)                | NOT NULL |                     | Numeric      | FK     | staff        | staff_id        | NO ACTION   | NO ACTION
public    | rental                     | TBL     |       7 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |        |              |                 |             |
public    | staff                      | TBL     |       1 | staff_id         | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK     |              |                 |             |
public    | staff                      | TBL     |       2 | first_name       | character varying(45)       | NOT NULL |                     | String       |        |              |                 |             |
public    | staff                      | TBL     |       3 | last_name        | character varying(45)       | NOT NULL |                     | String       |        |              |                 |             |
public    | staff                      | TBL     |       4 | address_id       | smallint(16)                | NOT NULL |                     | Numeric      | FK     | address      | address_id      | CASCADE     | RESTRICT
public    | staff                      | TBL     |       5 | email            | character varying(50)       | NULL     |                     | String       |        |              |                 |             |
public    | staff                      | TBL     |       6 | store_id         | smallint(16)                | NOT NULL |                     | Numeric      |        |              |                 |             |
public    | staff                      | TBL     |       7 | active           | boolean                     | NOT NULL | true                | Boolean      |        |              |                 |             |
public    | staff                      | TBL     |       8 | username         | character varying(16)       | NOT NULL |                     | String       |        |              |                 |             |
public    | staff                      | TBL     |       9 | password         | character varying(40)       | NULL     |                     | String       |        |              |                 |             |
public    | staff                      | TBL     |      10 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |        |              |                 |             |
public    | staff                      | TBL     |      11 | picture          | bytea                       | NULL     |                     | User-defined |        |              |                 |             |
public    | store                      | TBL     |       1 | store_id         | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK     |              |                 |             |
public    | store                      | TBL     |       2 | manager_staff_id | smallint(16)                | NOT NULL |                     | Numeric      | FK     | staff        | staff_id        | CASCADE     | RESTRICT
public    | store                      | TBL     |       3 | address_id       | smallint(16)                | NOT NULL |                     | Numeric      | FK     | address      | address_id      | CASCADE     | RESTRICT
public    | store                      | TBL     |       4 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |        |              |                 |             |
public    | actor_info                 | VW      |       1 | actor_id         | integer(32)                 | NULL     |                     | Numeric      |        |              |                 |             |
public    | actor_info                 | VW      |       2 | first_name       | character varying(45)       | NULL     |                     | String       |        |              |                 |             |
public    | actor_info                 | VW      |       3 | last_name        | character varying(45)       | NULL     |                     | String       |        |              |                 |             |
public    | actor_info                 | VW      |       4 | film_info        | text                        | NULL     |                     | String       |        |              |                 |             |
public    | customer_list              | VW      |       1 | id               | integer(32)                 | NULL     |                     | Numeric      |        |              |                 |             |
public    | customer_list              | VW      |       2 | name             | text                        | NULL     |                     | String       |        |              |                 |             |
public    | customer_list              | VW      |       3 | address          | character varying(50)       | NULL     |                     | String       |        |              |                 |             |
public    | customer_list              | VW      |       4 | zip code         | character varying(10)       | NULL     |                     | String       |        |              |                 |             |
public    | customer_list              | VW      |       5 | phone            | character varying(20)       | NULL     |                     | String       |        |              |                 |             |
public    | customer_list              | VW      |       6 | city             | character varying(50)       | NULL     |                     | String       |        |              |                 |             |
public    | customer_list              | VW      |       7 | country          | character varying(50)       | NULL     |                     | String       |        |              |                 |             |
public    | customer_list              | VW      |       8 | notes            | text                        | NULL     |                     | String       |        |              |                 |             |
public    | customer_list              | VW      |       9 | sid              | smallint(16)                | NULL     |                     | Numeric      |        |              |                 |             |
public    | film_list                  | VW      |       1 | fid              | integer(32)                 | NULL     |                     | Numeric      |        |              |                 |             |
public    | film_list                  | VW      |       2 | title            | character varying(255)      | NULL     |                     | String       |        |              |                 |             |
public    | film_list                  | VW      |       3 | description      | text                        | NULL     |                     | String       |        |              |                 |             |
public    | film_list                  | VW      |       4 | category         | character varying(25)       | NULL     |                     | String       |        |              |                 |             |
public    | film_list                  | VW      |       5 | price            | numeric(4,2)                | NULL     |                     | Numeric      |        |              |                 |             |
public    | film_list                  | VW      |       6 | length           | smallint(16)                | NULL     |                     | Numeric      |        |              |                 |             |
public    | film_list                  | VW      |       7 | rating           | USER-DEFINED                | NULL     |                     | Enum         |        |              |                 |             |
public    | film_list                  | VW      |       8 | actors           | text                        | NULL     |                     | String       |        |              |                 |             |
public    | nicer_but_slower_film_list | VW      |       1 | fid              | integer(32)                 | NULL     |                     | Numeric      |        |              |                 |             |
public    | nicer_but_slower_film_list | VW      |       2 | title            | character varying(255)      | NULL     |                     | String       |        |              |                 |             |
public    | nicer_but_slower_film_list | VW      |       3 | description      | text                        | NULL     |                     | String       |        |              |                 |             |
public    | nicer_but_slower_film_list | VW      |       4 | category         | character varying(25)       | NULL     |                     | String       |        |              |                 |             |
public    | nicer_but_slower_film_list | VW      |       5 | price            | numeric(4,2)                | NULL     |                     | Numeric      |        |              |                 |             |
public    | nicer_but_slower_film_list | VW      |       6 | length           | smallint(16)                | NULL     |                     | Numeric      |        |              |                 |             |
public    | nicer_but_slower_film_list | VW      |       7 | rating           | USER-DEFINED                | NULL     |                     | Enum         |        |              |                 |             |
public    | nicer_but_slower_film_list | VW      |       8 | actors           | text                        | NULL     |                     | String       |        |              |                 |             |
public    | sales_by_film_category     | VW      |       1 | category         | character varying(25)       | NULL     |                     | String       |        |              |                 |             |
public    | sales_by_film_category     | VW      |       2 | total_sales      |                             | NULL     |                     | Numeric      |        |              |                 |             |
public    | sales_by_store             | VW      |       1 | store            | text                        | NULL     |                     | String       |        |              |                 |             |
public    | sales_by_store             | VW      |       2 | manager          | text                        | NULL     |                     | String       |        |              |                 |             |
public    | sales_by_store             | VW      |       3 | total_sales      |                             | NULL     |                     | Numeric      |        |              |                 |             |
public    | staff_list                 | VW      |       1 | id               | integer(32)                 | NULL     |                     | Numeric      |        |              |                 |             |
public    | staff_list                 | VW      |       2 | name             | text                        | NULL     |                     | String       |        |              |                 |             |
public    | staff_list                 | VW      |       3 | address          | character varying(50)       | NULL     |                     | String       |        |              |                 |             |
public    | staff_list                 | VW      |       4 | zip code         | character varying(10)       | NULL     |                     | String       |        |              |                 |             |
public    | staff_list                 | VW      |       5 | phone            | character varying(20)       | NULL     |                     | String       |        |              |                 |             |
public    | staff_list                 | VW      |       6 | city             | character varying(50)       | NULL     |                     | String       |        |              |                 |             |
public    | staff_list                 | VW      |       7 | country          | character varying(50)       | NULL     |                     | String       |        |              |                 |             |
public    | staff_list                 | VW      |       8 | sid              | smallint(16)                | NULL     |                     | Numeric      |        |              |                 |             |
public    | usa_cities                 | VW      |       1 | city             | character varying(50)       | NULL     |                     | String       |        |              |                 |             |
public    | usa_cities                 | VW      |       2 | country_id       | smallint(16)                | NULL     |                     | Numeric      |        |              |                 |             |
public    | usa_city                   | VW      |       1 | city_id          | integer(32)                 | NULL     |                     | Numeric      |        |              |                 |             |
public    | usa_city                   | VW      |       2 | city             | character varying(50)       | NULL     |                     | String       |        |              |                 |             |
public    | usa_city                   | VW      |       3 | country_id       | smallint(16)                | NULL     |                     | Numeric      |        |              |                 |             |
(133 rows)
```

## Solution

- **Data Dictionary script**

```SQL
WITH vars
AS (
  SELECT
    'public'  AS v_SchemaName -- Set to the schema whose tables you want in the Data Dictionary
    ,'NO'      AS v_TablesOnly -- 'YES'=> Limit To Tables only; 'NO' => Include views too
)

,baseTbl
AS (
  SELECT table_schema AS SchemaName
       , table_catalog
       , table_type
       , table_name
       , table_schema
    FROM INFORMATION_SCHEMA.TABLES
   WHERE table_schema = (SELECT v_SchemaName FROM vars)
     AND ( ( table_type = 'BASE TABLE')
            OR ((SELECT v_TablesOnly FROM vars) = 'NO')
         )
)

,metadata
AS (
  SELECT bt.SchemaName AS schema_nm
       , bt.table_name AS table_nm
       , CASE WHEN bt.table_type = 'BASE TABLE' THEN 'TBL'
              WHEN bt.table_type = 'VIEW' THEN 'VW'
              ELSE 'UK'
         END AS obj_typ
       , tut.ordinal_position AS ord_pos
       , tut.column_name AS column_nm
       , COALESCE(tut.data_type,'unknown') ||
         CASE WHEN tut.data_type IN ('character varying','character')
                   THEN '(' || tut.CHARACTER_MAXIMUM_LENGTH::VARCHAR(10) || ')'
              WHEN tut.data_type IN ('date', 'time') THEN '(3)'
              WHEN tut.data_type = 'datetime' THEN '(8)'
              WHEN tut.data_type = 'timestamp' THEN '(4)'
              WHEN tut.data_type IN ('bigint','integer','smallint')
                   THEN '(' || tut.NUMERIC_PRECISION::VARCHAR(10) || ')'
              WHEN tut.data_type IN ('decimal','numeric')
                   THEN '(' || tut.NUMERIC_PRECISION::VARCHAR(10) ||
                        ',' || tut.NUMERIC_SCALE::VARCHAR(10) || ')'
              ELSE ''
         END AS data_typ  
       , CASE WHEN tut.IS_NULLABLE = 'YES'
             THEN 'NULL'
             ELSE 'NOT NULL'
         END AS nullable
       , CASE WHEN LEFT(tut.column_default,8) = 'nextval('
              THEN 'seq_id'
              ELSE tut.column_default
         END AS def_val  
   FROM INFORMATION_SCHEMA.COLUMNS AS tut
  INNER JOIN baseTbl bt
     ON bt.table_catalog = tut.table_catalog
    AND bt.table_name = tut.table_name         
)
,cat_tables
AS (
  SELECT oid, relkind, relname
    FROM pg_catalog.pg_class
   WHERE relkind IN ('r','v')
)
,metadata_col
AS (
  SELECT m.*,
         CASE WHEN typ.typcategory = 'A' THEN 'Array'
              WHEN typ.typcategory = 'B' THEN 'Boolean'
              WHEN typ.typcategory = 'D' THEN 'Composite'
              WHEN typ.typcategory = 'E' THEN 'Enum'
              WHEN typ.typcategory = 'G' THEN 'Geometric'
              WHEN typ.typcategory = 'I' THEN 'Network address'
              WHEN typ.typcategory = 'N' THEN 'Numeric'
              WHEN typ.typcategory = 'P' THEN 'Pseudo-types'
              WHEN typ.typcategory = 'R' THEN 'Range'
              WHEN typ.typcategory = 'S' THEN 'String'
              WHEN typ.typcategory = 'T' THEN 'Timespan'
              WHEN typ.typcategory = 'U' THEN 'User-defined'
              WHEN typ.typcategory = 'V' THEN 'Bit-string'
              WHEN typ.typcategory = 'X' THEN 'unknown'
         END AS type_ctg
    FROM cat_tables AS t
   INNER JOIN pg_catalog.pg_attribute AS c
      ON t.oid = c.attrelid
   INNER JOIN pg_catalog.pg_type AS typ
      ON typ.oid = c.atttypid
    LEFT JOIN pg_catalog.pg_attrdef AS pgadf
      ON t.oid = pgadf.adrelid AND c.attnum = pgadf.adnum
   INNER JOIN metadata AS m
      ON t.relname  = m.table_nm AND c.attnum = m.ord_pos
   WHERE c.attnum > 0
)


,t
AS (
  SELECT  cons.table_schema AS schema_nm
        , cons.table_name AS table_nm
        , kcu.column_name AS column_nm
        , CASE WHEN cons.constraint_type = 'PRIMARY KEY' THEN 'PK'
               WHEN cons.constraint_type = 'FOREIGN KEY' THEN 'FK'
               WHEN cons.constraint_type = 'UNIQUE' THEN 'UK'
               ELSE 'X'
          END AS is_key
    FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS cons
   INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu
           ON  cons.table_schema = kcu.table_schema
          AND cons.constraint_name = kcu.constraint_name
          AND cons.table_name = kcu.table_name
   WHERE cons.table_schema = (SELECT v_SchemaName FROM vars)
     AND cons.table_name IN (SELECT DISTINCT table_name FROM baseTbl)
     AND cons.constraint_type IN ('PRIMARY KEY','FOREIGN KEY','UNIQUE')
   GROUP BY cons.table_schema,
            cons.table_name,
            kcu.column_name,
            cons.constraint_type
)

, meta_for_keys
AS (
  SELECT schema_nm
        , table_nm
        , column_nm
        , STRING_AGG(is_key, ',' ORDER BY is_key) AS is_key
    FROM t
   GROUP BY schema_nm, table_nm, column_nm
)

, meta_ref_fks
AS (
  SELECT tc.table_name
       , kcu.column_name AS column_name
       , tc2.table_name AS ref_table_name
       , kcu2.column_name AS ref_col_name
       , update_rule
       , delete_rule
   FROM information_schema.referential_constraints rc
  INNER JOIN information_schema.table_constraints tc
     ON rc.constraint_name = tc.constraint_name
  INNER JOIN information_schema.table_constraints tc2
     ON rc.unique_constraint_name = tc2.constraint_name
  INNER JOIN information_schema.key_column_usage kcu
     ON rc.constraint_name = kcu.constraint_name
    AND tc.table_name = kcu.table_name
  INNER JOIN information_schema.key_column_usage kcu2
     ON rc.unique_constraint_name = kcu2.constraint_name
    AND tc2.table_name = kcu2.table_name
  INNER JOIN information_schema.columns c
     ON tc.table_name = c.table_name
    AND kcu.column_name = c.column_name
)

SELECT mc.*
     , mk.is_key
     , mfk.ref_table_name AS fk_ref_table
     , mfk.ref_col_name AS fk_ref_col_name
     , mfk.update_rule AS update_rule
     , mfk.delete_rule AS delete_rule
  FROM metadata_col mc
  LEFT JOIN meta_for_keys mk
    ON mc.table_nm = mk.table_nm AND mc.column_nm = mk.column_nm
  LEFT JOIN meta_ref_fks mfk
    ON mc.table_nm = mfk.table_name AND mc.column_nm = mfk.column_name
 ORDER BY 3, 2, 4;
```


You can save it as a table by adding the `CREATE` command at the beginning of the script:

```SQL
CREATE TABLE dictionary_db AS
...
```
See the file `create_dictionary_table.sql`.

Then execute from the `psql` command line the script:

```console
dvdrental=# \i create_dictionary_table.sql
SELECT 133
```

The file must be in the same directory you are running PostgreSQl, otherwise use the command `\ir` for the absolute path of the file.

Now you can execute:

```console
dvdrental=# \d dictionary_db
                             Table "public.dictionary_db"
     Column      |                Type                | Collation | Nullable | Default
-----------------+------------------------------------+-----------+----------+---------
 schema_nm       | information_schema.sql_identifier  |           |          |
 table_nm        | information_schema.sql_identifier  |           |          |
 obj_typ         | text                               |           |          |
 ord_pos         | information_schema.cardinal_number |           |          |
 column_nm       | information_schema.sql_identifier  |           |          |
 data_typ        | text                               |           |          |
 nullable        | text                               |           |          |
 def_val         | character varying                  |           |          |
 type_ctg        | text                               |           |          |
 is_key          | text                               |           |          |
 fk_ref_table    | information_schema.sql_identifier  |           |          |
 fk_ref_col_name | information_schema.sql_identifier  |           |          |
 update_rule     | information_schema.character_data  |           |          |
 delete_rule     | information_schema.character_data  |           |          |
```

## Discussion

```SQL
------------------------------------------------------------------------------------
-- Data Dictionary Dump:  
-- This SQL script will dump table, column, key, and description design related
-- metadata so that you can copy-paste or export to Excel as a Data Dictionary.  
------------------------------------------------------------------------------------
-- Platform:          PostgreSQL
----------------------------------------------------------------------------------

WITH vars
AS (
  SELECT
    'public'  AS v_SchemaName -- Set to the schema whose tables you want in the Data Dictionary
    ,'NO'      AS v_TablesOnly -- 'YES'=> Limit To Tables only; 'NO' => Include views too
)

,baseTbl
AS (
  SELECT table_schema AS SchemaName
       , table_catalog
       , table_type
       , table_name
       , table_schema
    FROM INFORMATION_SCHEMA.TABLES
   WHERE table_schema = (SELECT v_SchemaName FROM vars)
     AND ( ( table_type = 'BASE TABLE')
            OR ((SELECT v_TablesOnly FROM vars) = 'NO')
         )
)

,metadata
AS (
  SELECT bt.SchemaName AS schema_nm
       , bt.table_name AS table_nm
       , CASE WHEN bt.table_type = 'BASE TABLE' THEN 'TBL'
              WHEN bt.table_type = 'VIEW' THEN 'VW'
              ELSE 'UK'
         END AS obj_typ
       , tut.ordinal_position AS ord_pos
       , tut.column_name AS column_nm
       , COALESCE(tut.data_type,'unknown') ||
         CASE WHEN tut.data_type IN ('character varying','char')
                   THEN '(' || tut.CHARACTER_MAXIMUM_LENGTH::VARCHAR(10) || ')'
              WHEN tut.data_type IN ('date', 'time') THEN '(3)'
              WHEN tut.data_type = 'datetime' THEN '(8)'
              WHEN tut.data_type = 'timestamp' THEN '(4)'
              WHEN tut.data_type IN ('bigint','integer','smallint')
                   THEN '(' || tut.NUMERIC_PRECISION::VARCHAR(10) || ')'
              WHEN tut.data_type IN ('decimal','numeric')
                   THEN '(' || tut.NUMERIC_PRECISION::VARCHAR(10) ||
                        ',' || tut.NUMERIC_SCALE::VARCHAR(10) || ')'
              ELSE ''
         END AS data_typ  
       , CASE WHEN tut.IS_NULLABLE = 'YES'
             THEN 'NULL'
             ELSE 'NOT NULL'
         END AS nullable
       , CASE WHEN LEFT(tut.column_default,8) = 'nextval('
              THEN 'seq_id'
              ELSE tut.column_default
         END AS def_val  
   FROM INFORMATION_SCHEMA.COLUMNS AS tut
  INNER JOIN baseTbl bt
     ON bt.table_catalog = tut.table_catalog
    AND bt.table_name = tut.table_name         
)
SELECT *
  FROM metadata
 ORDER BY table_nm, ord_pos;
```

```console
schema_nm |          table_nm          | obj_typ | ord_pos |    column_nm     |          data_typ           | nullable |       def_val
-----------+----------------------------+---------+---------+------------------+-----------------------------+----------+---------------------
public    | actor                      | TBL     |       1 | actor_id         | integer(32)                 | NOT NULL | seq_id
public    | actor                      | TBL     |       2 | first_name       | character varying(45)       | NOT NULL |
public    | actor                      | TBL     |       3 | last_name        | character varying(45)       | NOT NULL |
public    | actor                      | TBL     |       4 | last_update      | timestamp without time zone | NOT NULL | now()
public    | actor_info                 | VW      |       1 | actor_id         | integer(32)                 | NULL     |
public    | actor_info                 | VW      |       2 | first_name       | character varying(45)       | NULL     |
public    | actor_info                 | VW      |       3 | last_name        | character varying(45)       | NULL     |
public    | actor_info                 | VW      |       4 | film_info        | text                        | NULL     |
public    | address                    | TBL     |       1 | address_id       | integer(32)                 | NOT NULL | seq_id
public    | address                    | TBL     |       2 | address          | character varying(50)       | NOT NULL |
public    | address                    | TBL     |       3 | address2         | character varying(50)       | NULL     |
public    | address                    | TBL     |       4 | district         | character varying(20)       | NOT NULL |
public    | address                    | TBL     |       5 | city_id          | smallint(16)                | NOT NULL |
public    | address                    | TBL     |       6 | postal_code      | character varying(10)       | NULL     |
public    | address                    | TBL     |       7 | phone            | character varying(20)       | NOT NULL |
public    | address                    | TBL     |       8 | last_update      | timestamp without time zone | NOT NULL | now()
public    | category                   | TBL     |       1 | category_id      | integer(32)                 | NOT NULL | seq_id
public    | category                   | TBL     |       2 | name             | character varying(25)       | NOT NULL |
```


```SQL
------------------------------------------------------------------------------------
-- Data Dictionary Dump:  
-- This SQL script will dump table, column, key, and description design related
-- metadata so that you can copy-paste or export to Excel as a Data Dictionary.  
------------------------------------------------------------------------------------
-- Platform:          PostgreSQL
----------------------------------------------------------------------------------

WITH vars
AS (
  SELECT
    'public'  AS v_SchemaName -- Set to the schema whose tables you want in the Data Dictionary
    ,'NO'      AS v_TablesOnly -- 'YES'=> Limit To Tables only; 'NO' => Include views too
)

,baseTbl
AS (
  SELECT table_schema AS SchemaName
       , table_catalog
       , table_type
       , table_name
       , table_schema
    FROM INFORMATION_SCHEMA.TABLES
   WHERE table_schema = (SELECT v_SchemaName FROM vars)
     AND ( ( table_type = 'BASE TABLE')
            OR ((SELECT v_TablesOnly FROM vars) = 'NO')
         )
)

,t
AS (
  SELECT  cons.table_schema AS schema_nm
        , cons.table_name AS table_nm
        , kcu.column_name AS column_nm
        , CASE WHEN cons.constraint_type = 'PRIMARY KEY' THEN 'PK'
               WHEN cons.constraint_type = 'FOREIGN KEY' THEN 'FK'
               WHEN cons.constraint_type = 'UNIQUE' THEN 'UK'
               ELSE 'X'
          END AS is_key
    FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS cons
   INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu
           ON  cons.table_schema = kcu.table_schema
          AND cons.constraint_name = kcu.constraint_name
          AND cons.table_name = kcu.table_name
   WHERE cons.table_schema = (SELECT v_SchemaName FROM vars)
     AND cons.table_name IN (SELECT DISTINCT table_name FROM baseTbl)
     AND cons.constraint_type IN ('PRIMARY KEY','FOREIGN KEY','UNIQUE')
   GROUP BY cons.table_schema,
            cons.table_name,
            kcu.column_name,
            cons.constraint_type
)
SELECT * FROM t;
```

```console
schema_nm |   table_nm    |    column_nm     | is_key
-----------+---------------+------------------+--------
public    | actor         | actor_id         | PK
public    | address       | address_id       | PK
public    | address       | city_id          | FK
public    | category      | category_id      | PK
public    | city          | city_id          | PK
public    | city          | country_id       | FK
public    | country       | country_id       | PK
public    | customer      | address_id       | FK
public    | customer      | customer_id      | PK
public    | film          | film_id          | PK
public    | film          | language_id      | FK
public    | film_actor    | actor_id         | FK
public    | film_actor    | actor_id         | PK
public    | film_actor    | film_id          | FK
public    | film_actor    | film_id          | PK
public    | film_category | category_id      | FK
```

```SQL
WITH vars
AS (
  SELECT
    'public'  AS v_SchemaName -- Set to the schema whose tables you want in the Data Dictionary
    ,'NO'      AS v_TablesOnly -- 'YES'=> Limit To Tables only; 'NO' => Include views too
)

,baseTbl
AS (
  SELECT table_schema AS SchemaName
       , table_catalog
       , table_type
       , table_name
       , table_schema
    FROM INFORMATION_SCHEMA.TABLES
   WHERE table_schema = (SELECT v_SchemaName FROM vars)
     AND ( ( table_type = 'BASE TABLE')
            OR ((SELECT v_TablesOnly FROM vars) = 'NO')
         )
)

,t
AS (
  SELECT  cons.table_schema AS schema_nm
        , cons.table_name AS table_nm
        , kcu.column_name AS column_nm
        , CASE WHEN cons.constraint_type = 'PRIMARY KEY' THEN 'PK'
               WHEN cons.constraint_type = 'FOREIGN KEY' THEN 'FK'
               WHEN cons.constraint_type = 'UNIQUE' THEN 'UK'
               ELSE 'X'
          END AS is_key
    FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS cons
   INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu
           ON  cons.table_schema = kcu.table_schema
          AND cons.constraint_name = kcu.constraint_name
          AND cons.table_name = kcu.table_name
   WHERE cons.table_schema = (SELECT v_SchemaName FROM vars)
     AND cons.table_name IN (SELECT DISTINCT table_name FROM baseTbl)
     AND cons.constraint_type IN ('PRIMARY KEY','FOREIGN KEY','UNIQUE')
   GROUP BY cons.table_schema,
            cons.table_name,
            kcu.column_name,
            cons.constraint_type
)

, meta_for_keys
AS (
  SELECT schema_nm
        , table_nm
        , column_nm
        , STRING_AGG(is_key, ',' ORDER BY is_key) AS is_key
    FROM t
   GROUP BY schema_nm, table_nm, column_nm
)

SELECT *
  FROM meta_for_keys;  
```

```console
schema_nm |   table_nm    |    column_nm     | is_key
-----------+---------------+------------------+--------
public    | actor         | actor_id         | PK
public    | address       | address_id       | PK
public    | address       | city_id          | FK
public    | category      | category_id      | PK
public    | city          | city_id          | PK
public    | city          | country_id       | FK
public    | country       | country_id       | PK
public    | customer      | address_id       | FK
public    | customer      | customer_id      | PK
public    | film          | film_id          | PK
public    | film          | language_id      | FK
public    | film_actor    | actor_id         | FK,PK
public    | film_actor    | film_id          | FK,PK
public    | film_category | category_id      | FK,PK
public    | film_category | film_id          | FK,PK
```


```SQL
WITH vars
AS (
  SELECT
    'public'  AS v_SchemaName -- Set to the schema whose tables you want in the Data Dictionary
    ,'NO'      AS v_TablesOnly -- 'YES'=> Limit To Tables only; 'NO' => Include views too
)

,baseTbl
AS (
  SELECT table_schema AS SchemaName
       , table_catalog
       , table_type
       , table_name
       , table_schema
    FROM INFORMATION_SCHEMA.TABLES
   WHERE table_schema = (SELECT v_SchemaName FROM vars)
     AND ( ( table_type = 'BASE TABLE')
            OR ((SELECT v_TablesOnly FROM vars) = 'NO')
         )
)
,metadata
AS (
  SELECT bt.SchemaName AS schema_nm
       , bt.table_name AS table_nm
       , CASE WHEN bt.table_type = 'BASE TABLE' THEN 'TBL'
              WHEN bt.table_type = 'VIEW' THEN 'VW'
              ELSE 'UK'
         END AS obj_typ
       , tut.ordinal_position AS ord_pos
       , tut.column_name AS column_nm
       , COALESCE(tut.data_type,'unknown') ||
         CASE WHEN tut.data_type IN ('character varying','char')
                   THEN '(' || tut.CHARACTER_MAXIMUM_LENGTH::VARCHAR(10) || ')'
              WHEN tut.data_type IN ('date', 'time') THEN '(3)'
              WHEN tut.data_type = 'datetime' THEN '(8)'
              WHEN tut.data_type = 'timestamp' THEN '(4)'
              WHEN tut.data_type IN ('bigint','integer','smallint')
                   THEN '(' || tut.NUMERIC_PRECISION::VARCHAR(10) || ')'
              WHEN tut.data_type IN ('decimal','numeric')
                   THEN '(' || tut.NUMERIC_PRECISION::VARCHAR(10) ||
                        ',' || tut.NUMERIC_SCALE::VARCHAR(10) || ')'
              ELSE ''
         END AS data_typ  
       , CASE WHEN tut.IS_NULLABLE = 'YES'
             THEN 'NULL'
             ELSE 'NOT NULL'
         END AS nullable
       , CASE WHEN LEFT(tut.column_default,8) = 'nextval('
              THEN 'seq_id'
              ELSE tut.column_default
         END AS def_val  
   FROM INFORMATION_SCHEMA.COLUMNS AS tut
  INNER JOIN baseTbl bt
     ON bt.table_catalog = tut.table_catalog
    AND bt.table_name = tut.table_name         
)
,cat_tables
AS (
  SELECT oid, relkind, relname
    FROM pg_catalog.pg_class
   WHERE relkind IN ('r','v')
)
SELECT m.*,
       CASE WHEN typ.typcategory = 'A' THEN 'Array'
            WHEN typ.typcategory = 'B' THEN 'Boolean'
            WHEN typ.typcategory = 'D' THEN 'Composite'
            WHEN typ.typcategory = 'E' THEN 'Enum'
            WHEN typ.typcategory = 'G' THEN 'Geometric'
            WHEN typ.typcategory = 'I' THEN 'Network address'
            WHEN typ.typcategory = 'N' THEN 'Numeric'
            WHEN typ.typcategory = 'P' THEN 'Pseudo-types'
            WHEN typ.typcategory = 'R' THEN 'Range'
            WHEN typ.typcategory = 'S' THEN 'String'
            WHEN typ.typcategory = 'T' THEN 'Timespan'
            WHEN typ.typcategory = 'U' THEN 'User-defined'
            WHEN typ.typcategory = 'V' THEN 'Bit-string'
            WHEN typ.typcategory = 'X' THEN 'unknown'
       END AS type_ctg
  FROM cat_tables AS t
 INNER JOIN pg_catalog.pg_attribute AS c
    ON t.oid = c.attrelid
 INNER JOIN pg_catalog.pg_type AS typ
    ON typ.oid = c.atttypid
  LEFT JOIN pg_catalog.pg_attrdef AS pgadf
    ON t.oid = pgadf.adrelid AND c.attnum = pgadf.adnum
 INNER JOIN metadata AS m
    ON t.relname  = m.table_nm AND c.attnum = m.ord_pos
 WHERE c.attnum > 0
 ORDER BY 3,2,4;
```

```console
schema_nm |          table_nm          | obj_typ | ord_pos |    column_nm     |          data_typ           | nullable |       def_val       |   type_ctg
-----------+----------------------------+---------+---------+------------------+-----------------------------+----------+---------------------+--------------
public    | actor                      | TBL     |       1 | actor_id         | integer(32)                 | NOT NULL | seq_id              | Numeric
public    | actor                      | TBL     |       2 | first_name       | character varying(45)       | NOT NULL |                     | String
public    | actor                      | TBL     |       3 | last_name        | character varying(45)       | NOT NULL |                     | String
public    | actor                      | TBL     |       4 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite
public    | address                    | TBL     |       1 | address_id       | integer(32)                 | NOT NULL | seq_id              | Numeric
public    | address                    | TBL     |       2 | address          | character varying(50)       | NOT NULL |                     | String
public    | address                    | TBL     |       3 | address2         | character varying(50)       | NULL     |                     | String
public    | address                    | TBL     |       4 | district         | character varying(20)       | NOT NULL |                     | String
public    | address                    | TBL     |       5 | city_id          | smallint(16)                | NOT NULL |                     | Numeric
public    | address                    | TBL     |       6 | postal_code      | character varying(10)       | NULL     |                     | String
public    | address                    | TBL     |       7 | phone            | character varying(20)       | NOT NULL |                     | String
public    | address                    | TBL     |       8 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite
```



```SQL
WITH vars
AS (
  SELECT
    'public'  AS v_SchemaName -- Set to the schema whose tables you want in the Data Dictionary
    ,'NO'      AS v_TablesOnly -- 'YES'=> Limit To Tables only; 'NO' => Include views too
)

,baseTbl
AS (
  SELECT table_schema AS SchemaName
       , table_catalog
       , table_type
       , table_name
       , table_schema
    FROM INFORMATION_SCHEMA.TABLES
   WHERE table_schema = (SELECT v_SchemaName FROM vars)
     AND ( ( table_type = 'BASE TABLE')
            OR ((SELECT v_TablesOnly FROM vars) = 'NO')
         )
)
,metadata
AS (
  SELECT bt.SchemaName AS schema_nm
       , bt.table_name AS table_nm
       , CASE WHEN bt.table_type = 'BASE TABLE' THEN 'TBL'
              WHEN bt.table_type = 'VIEW' THEN 'VW'
              ELSE 'UK'
         END AS obj_typ
       , tut.ordinal_position AS ord_pos
       , tut.column_name AS column_nm
       , COALESCE(tut.data_type,'unknown') ||
         CASE WHEN tut.data_type IN ('character varying','character')
                   THEN '(' || tut.CHARACTER_MAXIMUM_LENGTH::VARCHAR(10) || ')'
              WHEN tut.data_type IN ('date', 'time') THEN '(3)'
              WHEN tut.data_type = 'datetime' THEN '(8)'
              WHEN tut.data_type = 'timestamp' THEN '(4)'
              WHEN tut.data_type IN ('bigint','integer','smallint')
                   THEN '(' || tut.NUMERIC_PRECISION::VARCHAR(10) || ')'
              WHEN tut.data_type IN ('decimal','numeric')
                   THEN '(' || tut.NUMERIC_PRECISION::VARCHAR(10) ||
                        ',' || tut.NUMERIC_SCALE::VARCHAR(10) || ')'
              ELSE ''
         END AS data_typ  
       , CASE WHEN tut.IS_NULLABLE = 'YES'
             THEN 'NULL'
             ELSE 'NOT NULL'
         END AS nullable
       , CASE WHEN LEFT(tut.column_default,8) = 'nextval('
              THEN 'seq_id'
              ELSE tut.column_default
         END AS def_val  
   FROM INFORMATION_SCHEMA.COLUMNS AS tut
  INNER JOIN baseTbl bt
     ON bt.table_catalog = tut.table_catalog
    AND bt.table_name = tut.table_name         
)
,cat_tables
AS (
  SELECT oid, relkind, relname
    FROM pg_catalog.pg_class
   WHERE relkind IN ('r','v')
)
,metadata_col
AS (
  SELECT m.*,
         CASE WHEN typ.typcategory = 'A' THEN 'Array'
              WHEN typ.typcategory = 'B' THEN 'Boolean'
              WHEN typ.typcategory = 'D' THEN 'Composite'
              WHEN typ.typcategory = 'E' THEN 'Enum'
              WHEN typ.typcategory = 'G' THEN 'Geometric'
              WHEN typ.typcategory = 'I' THEN 'Network address'
              WHEN typ.typcategory = 'N' THEN 'Numeric'
              WHEN typ.typcategory = 'P' THEN 'Pseudo-types'
              WHEN typ.typcategory = 'R' THEN 'Range'
              WHEN typ.typcategory = 'S' THEN 'String'
              WHEN typ.typcategory = 'T' THEN 'Timespan'
              WHEN typ.typcategory = 'U' THEN 'User-defined'
              WHEN typ.typcategory = 'V' THEN 'Bit-string'
              WHEN typ.typcategory = 'X' THEN 'unknown'
         END AS type_ctg
    FROM cat_tables AS t
   INNER JOIN pg_catalog.pg_attribute AS c
      ON t.oid = c.attrelid
   INNER JOIN pg_catalog.pg_type AS typ
      ON typ.oid = c.atttypid
    LEFT JOIN pg_catalog.pg_attrdef AS pgadf
      ON t.oid = pgadf.adrelid AND c.attnum = pgadf.adnum
   INNER JOIN metadata AS m
      ON t.relname  = m.table_nm AND c.attnum = m.ord_pos
   WHERE c.attnum > 0
)
,t
AS (
  SELECT  cons.table_schema AS schema_nm
        , cons.table_name AS table_nm
        , kcu.column_name AS column_nm
        , CASE WHEN cons.constraint_type = 'PRIMARY KEY' THEN 'PK'
               WHEN cons.constraint_type = 'FOREIGN KEY' THEN 'FK'
               WHEN cons.constraint_type = 'UNIQUE' THEN 'UK'
               ELSE 'X'
          END AS is_key
    FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS cons
   INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu
           ON  cons.table_schema = kcu.table_schema
          AND cons.constraint_name = kcu.constraint_name
          AND cons.table_name = kcu.table_name
   WHERE cons.table_schema = (SELECT v_SchemaName FROM vars)
     AND cons.table_name IN (SELECT DISTINCT table_name FROM baseTbl)
     AND cons.constraint_type IN ('PRIMARY KEY','FOREIGN KEY','UNIQUE')
   GROUP BY cons.table_schema,
            cons.table_name,
            kcu.column_name,
            cons.constraint_type
)

, meta_for_keys
AS (
  SELECT schema_nm
        , table_nm
        , column_nm
        , STRING_AGG(is_key, ',' ORDER BY is_key) AS is_key
    FROM t
   GROUP BY schema_nm, table_nm, column_nm
)

SELECT mc.*, mk.is_key
  FROM metadata_col mc
  LEFT JOIN meta_for_keys mk
    ON mc.table_nm = mk.table_nm AND mc.column_nm = mk.column_nm
 ORDER BY 3,2,4;
```

```console
schema_nm |          table_nm          | obj_typ | ord_pos |    column_nm     |          data_typ           | nullable |       def_val       |   type_ctg   | is_key
-----------+----------------------------+---------+---------+------------------+-----------------------------+----------+---------------------+--------------+--------
public    | actor                      | TBL     |       1 | actor_id         | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK
public    | actor                      | TBL     |       2 | first_name       | character varying(45)       | NOT NULL |                     | String       |
public    | actor                      | TBL     |       3 | last_name        | character varying(45)       | NOT NULL |                     | String       |
public    | actor                      | TBL     |       4 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |
public    | address                    | TBL     |       1 | address_id       | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK
public    | address                    | TBL     |       2 | address          | character varying(50)       | NOT NULL |                     | String       |
public    | address                    | TBL     |       3 | address2         | character varying(50)       | NULL     |                     | String       |
public    | address                    | TBL     |       4 | district         | character varying(20)       | NOT NULL |                     | String       |
public    | address                    | TBL     |       5 | city_id          | smallint(16)                | NOT NULL |                     | Numeric      | FK
public    | address                    | TBL     |       6 | postal_code      | character varying(10)       | NULL     |                     | String       |
public    | address                    | TBL     |       7 | phone            | character varying(20)       | NOT NULL |                     | String       |
public    | address                    | TBL     |       8 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |
public    | category                   | TBL     |       1 | category_id      | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK
public    | category                   | TBL     |       2 | name             | character varying(25)       | NOT NULL |                     | String       |
public    | category                   | TBL     |       3 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |
public    | city                       | TBL     |       1 | city_id          | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK
public    | city                       | TBL     |       2 | city             | character varying(50)       | NOT NULL |                     | String       |
public    | city                       | TBL     |       3 | country_id       | smallint(16)                | NOT NULL |                     | Numeric      | FK
public    | city                       | TBL     |       4 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |
public    | country                    | TBL     |       1 | country_id       | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK
public    | country                    | TBL     |       2 | country          | character varying(50)       | NOT NULL |                     | String       |
public    | country                    | TBL     |       3 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |
public    | customer                   | TBL     |       1 | customer_id      | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK
public    | customer                   | TBL     |       2 | store_id         | smallint(16)                | NOT NULL |                     | Numeric      |
public    | customer                   | TBL     |       3 | first_name       | character varying(45)       | NOT NULL |                     | String       |
public    | customer                   | TBL     |       4 | last_name        | character varying(45)       | NOT NULL |                     | String       |
public    | customer                   | TBL     |       5 | email            | character varying(50)       | NULL     |                     | String       |
public    | customer                   | TBL     |       6 | address_id       | smallint(16)                | NOT NULL |                     | Numeric      | FK
public    | customer                   | TBL     |       7 | activebool       | boolean                     | NOT NULL | true                | Boolean      |
public    | customer                   | TBL     |       8 | create_date      | date(3)                     | NOT NULL | ('now'::text)::date | Composite    |
public    | customer                   | TBL     |       9 | last_update      | timestamp without time zone | NULL     | now()               | Composite    |
public    | customer                   | TBL     |      10 | active           | integer(32)                 | NULL     |                     | Numeric      |
public    | film                       | TBL     |       1 | film_id          | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK
public    | film                       | TBL     |       2 | title            | character varying(255)      | NOT NULL |                     | String       |
public    | film                       | TBL     |       3 | description      | text                        | NULL     |                     | String       |
public    | film                       | TBL     |       4 | release_year     | integer(32)                 | NULL     |                     | Numeric      |
public    | film                       | TBL     |       5 | language_id      | smallint(16)                | NOT NULL |                     | Numeric      | FK
public    | film                       | TBL     |       6 | rental_duration  | smallint(16)                | NOT NULL | 3                   | Numeric      |
public    | film                       | TBL     |       7 | rental_rate      | numeric(4,2)                | NOT NULL | 4.99                | Numeric      |
public    | film                       | TBL     |       8 | length           | smallint(16)                | NULL     |                     | Numeric      |
public    | film                       | TBL     |       9 | replacement_cost | numeric(5,2)                | NOT NULL | 19.99               | Numeric      |
public    | film                       | TBL     |      10 | rating           | USER-DEFINED                | NULL     | 'G'::mpaa_rating    | Enum         |
public    | film                       | TBL     |      11 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |
public    | film                       | TBL     |      12 | special_features | ARRAY                       | NULL     |                     | Array        |
public    | film                       | TBL     |      13 | fulltext         | tsvector                    | NOT NULL |                     | User-defined |
public    | film_actor                 | TBL     |       1 | actor_id         | smallint(16)                | NOT NULL |                     | Numeric      | FK,PK
public    | film_actor                 | TBL     |       2 | film_id          | smallint(16)                | NOT NULL |                     | Numeric      | FK,PK
public    | film_actor                 | TBL     |       3 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |
public    | film_category              | TBL     |       1 | film_id          | smallint(16)                | NOT NULL |                     | Numeric      | FK,PK
public    | film_category              | TBL     |       2 | category_id      | smallint(16)                | NOT NULL |                     | Numeric      | FK,PK
public    | film_category              | TBL     |       3 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |
public    | inventory                  | TBL     |       1 | inventory_id     | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK
public    | inventory                  | TBL     |       2 | film_id          | smallint(16)                | NOT NULL |                     | Numeric      | FK
public    | inventory                  | TBL     |       3 | store_id         | smallint(16)                | NOT NULL |                     | Numeric      |
public    | inventory                  | TBL     |       4 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |
public    | language                   | TBL     |       1 | language_id      | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK
public    | language                   | TBL     |       2 | name             | character(20)               | NOT NULL |                     | String       |
public    | language                   | TBL     |       3 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |
public    | payment                    | TBL     |       1 | payment_id       | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK
public    | payment                    | TBL     |       2 | customer_id      | smallint(16)                | NOT NULL |                     | Numeric      | FK
public    | payment                    | TBL     |       3 | staff_id         | smallint(16)                | NOT NULL |                     | Numeric      | FK
public    | payment                    | TBL     |       4 | rental_id        | integer(32)                 | NOT NULL |                     | Numeric      | FK
public    | payment                    | TBL     |       5 | amount           | numeric(5,2)                | NOT NULL |                     | Numeric      |
public    | payment                    | TBL     |       6 | payment_date     | timestamp without time zone | NOT NULL |                     | Composite    |
public    | rental                     | TBL     |       1 | rental_id        | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK
public    | rental                     | TBL     |       2 | rental_date      | timestamp without time zone | NOT NULL |                     | Composite    |
public    | rental                     | TBL     |       3 | inventory_id     | integer(32)                 | NOT NULL |                     | Numeric      | FK
public    | rental                     | TBL     |       4 | customer_id      | smallint(16)                | NOT NULL |                     | Numeric      | FK
public    | rental                     | TBL     |       5 | return_date      | timestamp without time zone | NULL     |                     | Composite    |
public    | rental                     | TBL     |       6 | staff_id         | smallint(16)                | NOT NULL |                     | Numeric      | FK
public    | rental                     | TBL     |       7 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |
public    | staff                      | TBL     |       1 | staff_id         | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK
public    | staff                      | TBL     |       2 | first_name       | character varying(45)       | NOT NULL |                     | String       |
public    | staff                      | TBL     |       3 | last_name        | character varying(45)       | NOT NULL |                     | String       |
public    | staff                      | TBL     |       4 | address_id       | smallint(16)                | NOT NULL |                     | Numeric      | FK
public    | staff                      | TBL     |       5 | email            | character varying(50)       | NULL     |                     | String       |
public    | staff                      | TBL     |       6 | store_id         | smallint(16)                | NOT NULL |                     | Numeric      |
public    | staff                      | TBL     |       7 | active           | boolean                     | NOT NULL | true                | Boolean      |
public    | staff                      | TBL     |       8 | username         | character varying(16)       | NOT NULL |                     | String       |
public    | staff                      | TBL     |       9 | password         | character varying(40)       | NULL     |                     | String       |
public    | staff                      | TBL     |      10 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |
public    | staff                      | TBL     |      11 | picture          | bytea                       | NULL     |                     | User-defined |
public    | store                      | TBL     |       1 | store_id         | integer(32)                 | NOT NULL | seq_id              | Numeric      | PK
public    | store                      | TBL     |       2 | manager_staff_id | smallint(16)                | NOT NULL |                     | Numeric      | FK
public    | store                      | TBL     |       3 | address_id       | smallint(16)                | NOT NULL |                     | Numeric      | FK
public    | store                      | TBL     |       4 | last_update      | timestamp without time zone | NOT NULL | now()               | Composite    |
public    | actor_info                 | VW      |       1 | actor_id         | integer(32)                 | NULL     |                     | Numeric      |
public    | actor_info                 | VW      |       2 | first_name       | character varying(45)       | NULL     |                     | String       |
public    | actor_info                 | VW      |       3 | last_name        | character varying(45)       | NULL     |                     | String       |
public    | actor_info                 | VW      |       4 | film_info        | text                        | NULL     |                     | String       |
public    | customer_list              | VW      |       1 | id               | integer(32)                 | NULL     |                     | Numeric      |
public    | customer_list              | VW      |       2 | name             | text                        | NULL     |                     | String       |
public    | customer_list              | VW      |       3 | address          | character varying(50)       | NULL     |                     | String       |
public    | customer_list              | VW      |       4 | zip code         | character varying(10)       | NULL     |                     | String       |
public    | customer_list              | VW      |       5 | phone            | character varying(20)       | NULL     |                     | String       |
public    | customer_list              | VW      |       6 | city             | character varying(50)       | NULL     |                     | String       |
public    | customer_list              | VW      |       7 | country          | character varying(50)       | NULL     |                     | String       |
public    | customer_list              | VW      |       8 | notes            | text                        | NULL     |                     | String       |
public    | customer_list              | VW      |       9 | sid              | smallint(16)                | NULL     |                     | Numeric      |
public    | film_list                  | VW      |       1 | fid              | integer(32)                 | NULL     |                     | Numeric      |
public    | film_list                  | VW      |       2 | title            | character varying(255)      | NULL     |                     | String       |
public    | film_list                  | VW      |       3 | description      | text                        | NULL     |                     | String       |
public    | film_list                  | VW      |       4 | category         | character varying(25)       | NULL     |                     | String       |
public    | film_list                  | VW      |       5 | price            | numeric(4,2)                | NULL     |                     | Numeric      |
public    | film_list                  | VW      |       6 | length           | smallint(16)                | NULL     |                     | Numeric      |
public    | film_list                  | VW      |       7 | rating           | USER-DEFINED                | NULL     |                     | Enum         |
public    | film_list                  | VW      |       8 | actors           | text                        | NULL     |                     | String       |
public    | nicer_but_slower_film_list | VW      |       1 | fid              | integer(32)                 | NULL     |                     | Numeric      |
public    | nicer_but_slower_film_list | VW      |       2 | title            | character varying(255)      | NULL     |                     | String       |
public    | nicer_but_slower_film_list | VW      |       3 | description      | text                        | NULL     |                     | String       |
public    | nicer_but_slower_film_list | VW      |       4 | category         | character varying(25)       | NULL     |                     | String       |
public    | nicer_but_slower_film_list | VW      |       5 | price            | numeric(4,2)                | NULL     |                     | Numeric      |
public    | nicer_but_slower_film_list | VW      |       6 | length           | smallint(16)                | NULL     |                     | Numeric      |
public    | nicer_but_slower_film_list | VW      |       7 | rating           | USER-DEFINED                | NULL     |                     | Enum         |
public    | nicer_but_slower_film_list | VW      |       8 | actors           | text                        | NULL     |                     | String       |
public    | sales_by_film_category     | VW      |       1 | category         | character varying(25)       | NULL     |                     | String       |
public    | sales_by_film_category     | VW      |       2 | total_sales      |                             | NULL     |                     | Numeric      |
public    | sales_by_store             | VW      |       1 | store            | text                        | NULL     |                     | String       |
public    | sales_by_store             | VW      |       2 | manager          | text                        | NULL     |                     | String       |
public    | sales_by_store             | VW      |       3 | total_sales      |                             | NULL     |                     | Numeric      |
public    | staff_list                 | VW      |       1 | id               | integer(32)                 | NULL     |                     | Numeric      |
public    | staff_list                 | VW      |       2 | name             | text                        | NULL     |                     | String       |
public    | staff_list                 | VW      |       3 | address          | character varying(50)       | NULL     |                     | String       |
public    | staff_list                 | VW      |       4 | zip code         | character varying(10)       | NULL     |                     | String       |
public    | staff_list                 | VW      |       5 | phone            | character varying(20)       | NULL     |                     | String       |
public    | staff_list                 | VW      |       6 | city             | character varying(50)       | NULL     |                     | String       |
public    | staff_list                 | VW      |       7 | country          | character varying(50)       | NULL     |                     | String       |
public    | staff_list                 | VW      |       8 | sid              | smallint(16)                | NULL     |                     | Numeric      |
public    | usa_cities                 | VW      |       1 | city             | character varying(50)       | NULL     |                     | String       |
public    | usa_cities                 | VW      |       2 | country_id       | smallint(16)                | NULL     |                     | Numeric      |
public    | usa_city                   | VW      |       1 | city_id          | integer(32)                 | NULL     |                     | Numeric      |
public    | usa_city                   | VW      |       2 | city             | character varying(50)       | NULL     |                     | String       |
public    | usa_city                   | VW      |       3 | country_id       | smallint(16)                | NULL     |                     | Numeric      |
(133 rows)
```





```SQL
SELECT tc.table_name
     , CASE WHEN tc.constraint_type = 'PRIMARY KEY' THEN 'PK'
            WHEN tc.constraint_type = 'FOREIGN KEY' THEN 'FK'
            WHEN tc.constraint_type = 'UNIQUE' THEN 'UK'
            ELSE 'X'
       END AS is_key
     , rc.constraint_name
     , rc.unique_constraint_name
     , tc2.table_name AS ref_table_name
     , update_rule
     , delete_rule
 FROM information_schema.referential_constraints rc
INNER JOIN information_schema.table_constraints tc
   ON rc.constraint_name = tc.constraint_name
INNER JOIN information_schema.table_constraints tc2
   ON rc.unique_constraint_name = tc2.constraint_name;
```

```console
table_name   | is_key |        constraint_name         | unique_constraint_name | ref_table_name | update_rule | delete_rule
---------------+--------+--------------------------------+------------------------+----------------+-------------+-------------
customer      | FK     | customer_address_id_fkey       | address_pkey           | address        | CASCADE     | RESTRICT
film_actor    | FK     | film_actor_actor_id_fkey       | actor_pkey             | actor          | CASCADE     | RESTRICT
film_actor    | FK     | film_actor_film_id_fkey        | film_pkey              | film           | CASCADE     | RESTRICT
film_category | FK     | film_category_category_id_fkey | category_pkey          | category       | CASCADE     | RESTRICT
film_category | FK     | film_category_film_id_fkey     | film_pkey              | film           | CASCADE     | RESTRICT
film          | FK     | film_language_id_fkey          | language_pkey          | language       | CASCADE     | RESTRICT
address       | FK     | fk_address_city                | city_pkey              | city           | NO ACTION   | NO ACTION
city          | FK     | fk_city                        | country_pkey           | country        | NO ACTION   | NO ACTION
inventory     | FK     | inventory_film_id_fkey         | film_pkey              | film           | CASCADE     | RESTRICT
payment       | FK     | payment_customer_id_fkey       | customer_pkey          | customer       | CASCADE     | RESTRICT
payment       | FK     | payment_rental_id_fkey         | rental_pkey            | rental         | CASCADE     | SET NULL
payment       | FK     | payment_staff_id_fkey          | staff_pkey             | staff          | CASCADE     | RESTRICT
rental        | FK     | rental_customer_id_fkey        | customer_pkey          | customer       | CASCADE     | RESTRICT
rental        | FK     | rental_inventory_id_fkey       | inventory_pkey         | inventory      | CASCADE     | RESTRICT
rental        | FK     | rental_staff_id_key            | staff_pkey             | staff          | NO ACTION   | NO ACTION
staff         | FK     | staff_address_id_fkey          | address_pkey           | address        | CASCADE     | RESTRICT
store         | FK     | store_address_id_fkey          | address_pkey           | address        | CASCADE     | RESTRICT
store         | FK     | store_manager_staff_id_fkey    | staff_pkey             | staff          | CASCADE     | RESTRICT
```


```SQL
SELECT tc.table_name
     , kcu.column_name AS column_name
     , c.ordinal_position AS ord_pos
     , CASE WHEN tc.constraint_type = 'PRIMARY KEY' THEN 'PK'
            WHEN tc.constraint_type = 'FOREIGN KEY' THEN 'FK'
            WHEN tc.constraint_type = 'UNIQUE' THEN 'UK'
            ELSE 'X'
       END AS is_key
     , rc.constraint_name
     , rc.unique_constraint_name
     , tc2.table_name AS ref_table_name
     , kcu2.column_name AS ref_col_name
     , update_rule
     , delete_rule
 FROM information_schema.referential_constraints rc
INNER JOIN information_schema.table_constraints tc
   ON rc.constraint_name = tc.constraint_name
INNER JOIN information_schema.table_constraints tc2
   ON rc.unique_constraint_name = tc2.constraint_name
INNER JOIN information_schema.key_column_usage kcu
   ON rc.constraint_name = kcu.constraint_name
  AND tc.table_name = kcu.table_name
INNER JOIN information_schema.key_column_usage kcu2
   ON rc.unique_constraint_name = kcu2.constraint_name
  AND tc2.table_name = kcu2.table_name
INNER JOIN information_schema.columns c
   ON tc.table_name = c.table_name
  AND kcu.column_name = c.column_name;  
```

```console
table_name   |   column_name    | ord_pos | is_key |        constraint_name         | unique_constraint_name | ref_table_name | ref_col_name | update_rule | delete_rule
---------------+------------------+---------+--------+--------------------------------+------------------------+----------------+--------------+-------------+-------------
customer      | address_id       |       6 | FK     | customer_address_id_fkey       | address_pkey           | address        | address_id   | CASCADE     | RESTRICT
film_actor    | actor_id         |       1 | FK     | film_actor_actor_id_fkey       | actor_pkey             | actor          | actor_id     | CASCADE     | RESTRICT
film_actor    | film_id          |       2 | FK     | film_actor_film_id_fkey        | film_pkey              | film           | film_id      | CASCADE     | RESTRICT
film_category | category_id      |       2 | FK     | film_category_category_id_fkey | category_pkey          | category       | category_id  | CASCADE     | RESTRICT
film_category | film_id          |       1 | FK     | film_category_film_id_fkey     | film_pkey              | film           | film_id      | CASCADE     | RESTRICT
film          | language_id      |       5 | FK     | film_language_id_fkey          | language_pkey          | language       | language_id  | CASCADE     | RESTRICT
address       | city_id          |       5 | FK     | fk_address_city                | city_pkey              | city           | city_id      | NO ACTION   | NO ACTION
city          | country_id       |       3 | FK     | fk_city                        | country_pkey           | country        | country_id   | NO ACTION   | NO ACTION
inventory     | film_id          |       2 | FK     | inventory_film_id_fkey         | film_pkey              | film           | film_id      | CASCADE     | RESTRICT
payment       | customer_id      |       2 | FK     | payment_customer_id_fkey       | customer_pkey          | customer       | customer_id  | CASCADE     | RESTRICT
payment       | rental_id        |       4 | FK     | payment_rental_id_fkey         | rental_pkey            | rental         | rental_id    | CASCADE     | SET NULL
payment       | staff_id         |       3 | FK     | payment_staff_id_fkey          | staff_pkey             | staff          | staff_id     | CASCADE     | RESTRICT
rental        | customer_id      |       4 | FK     | rental_customer_id_fkey        | customer_pkey          | customer       | customer_id  | CASCADE     | RESTRICT
rental        | inventory_id     |       3 | FK     | rental_inventory_id_fkey       | inventory_pkey         | inventory      | inventory_id | CASCADE     | RESTRICT
rental        | staff_id         |       6 | FK     | rental_staff_id_key            | staff_pkey             | staff          | staff_id     | NO ACTION   | NO ACTION
staff         | address_id       |       4 | FK     | staff_address_id_fkey          | address_pkey           | address        | address_id   | CASCADE     | RESTRICT
store         | address_id       |       3 | FK     | store_address_id_fkey          | address_pkey           | address        | address_id   | CASCADE     | RESTRICT
store         | manager_staff_id |       2 | FK     | store_manager_staff_id_fkey    | staff_pkey             | staff          | staff_id     | CASCADE     | RESTRICT
(18 rows)
```

Let's combine all the columns in the output.


```SQL
WITH vars
AS (
  SELECT
    'public'  AS v_SchemaName -- Set to the schema whose tables you want in the Data Dictionary
    ,'NO'      AS v_TablesOnly -- 'YES'=> Limit To Tables only; 'NO' => Include views too
)

,baseTbl
AS (
  SELECT table_schema AS SchemaName
       , table_catalog
       , table_type
       , table_name
       , table_schema
    FROM INFORMATION_SCHEMA.TABLES
   WHERE table_schema = (SELECT v_SchemaName FROM vars)
     AND ( ( table_type = 'BASE TABLE')
            OR ((SELECT v_TablesOnly FROM vars) = 'NO')
         )
)

,metadata
AS (
  SELECT bt.SchemaName AS schema_nm
       , bt.table_name AS table_nm
       , CASE WHEN bt.table_type = 'BASE TABLE' THEN 'TBL'
              WHEN bt.table_type = 'VIEW' THEN 'VW'
              ELSE 'UK'
         END AS obj_typ
       , tut.ordinal_position AS ord_pos
       , tut.column_name AS column_nm
       , COALESCE(tut.data_type,'unknown') ||
         CASE WHEN tut.data_type IN ('character varying','character')
                   THEN '(' || tut.CHARACTER_MAXIMUM_LENGTH::VARCHAR(10) || ')'
              WHEN tut.data_type IN ('date', 'time') THEN '(3)'
              WHEN tut.data_type = 'datetime' THEN '(8)'
              WHEN tut.data_type = 'timestamp' THEN '(4)'
              WHEN tut.data_type IN ('bigint','integer','smallint')
                   THEN '(' || tut.NUMERIC_PRECISION::VARCHAR(10) || ')'
              WHEN tut.data_type IN ('decimal','numeric')
                   THEN '(' || tut.NUMERIC_PRECISION::VARCHAR(10) ||
                        ',' || tut.NUMERIC_SCALE::VARCHAR(10) || ')'
              ELSE ''
         END AS data_typ  
       , CASE WHEN tut.IS_NULLABLE = 'YES'
             THEN 'NULL'
             ELSE 'NOT NULL'
         END AS nullable
       , CASE WHEN LEFT(tut.column_default,8) = 'nextval('
              THEN 'seq_id'
              ELSE tut.column_default
         END AS def_val  
   FROM INFORMATION_SCHEMA.COLUMNS AS tut
  INNER JOIN baseTbl bt
     ON bt.table_catalog = tut.table_catalog
    AND bt.table_name = tut.table_name         
)
,cat_tables
AS (
  SELECT oid, relkind, relname
    FROM pg_catalog.pg_class
   WHERE relkind IN ('r','v')
)
,metadata_col
AS (
  SELECT m.*,
         CASE WHEN typ.typcategory = 'A' THEN 'Array'
              WHEN typ.typcategory = 'B' THEN 'Boolean'
              WHEN typ.typcategory = 'D' THEN 'Composite'
              WHEN typ.typcategory = 'E' THEN 'Enum'
              WHEN typ.typcategory = 'G' THEN 'Geometric'
              WHEN typ.typcategory = 'I' THEN 'Network address'
              WHEN typ.typcategory = 'N' THEN 'Numeric'
              WHEN typ.typcategory = 'P' THEN 'Pseudo-types'
              WHEN typ.typcategory = 'R' THEN 'Range'
              WHEN typ.typcategory = 'S' THEN 'String'
              WHEN typ.typcategory = 'T' THEN 'Timespan'
              WHEN typ.typcategory = 'U' THEN 'User-defined'
              WHEN typ.typcategory = 'V' THEN 'Bit-string'
              WHEN typ.typcategory = 'X' THEN 'unknown'
         END AS type_ctg
    FROM cat_tables AS t
   INNER JOIN pg_catalog.pg_attribute AS c
      ON t.oid = c.attrelid
   INNER JOIN pg_catalog.pg_type AS typ
      ON typ.oid = c.atttypid
    LEFT JOIN pg_catalog.pg_attrdef AS pgadf
      ON t.oid = pgadf.adrelid AND c.attnum = pgadf.adnum
   INNER JOIN metadata AS m
      ON t.relname  = m.table_nm AND c.attnum = m.ord_pos
   WHERE c.attnum > 0
)


,t
AS (
  SELECT  cons.table_schema AS schema_nm
        , cons.table_name AS table_nm
        , kcu.column_name AS column_nm
        , CASE WHEN cons.constraint_type = 'PRIMARY KEY' THEN 'PK'
               WHEN cons.constraint_type = 'FOREIGN KEY' THEN 'FK'
               WHEN cons.constraint_type = 'UNIQUE' THEN 'UK'
               ELSE 'X'
          END AS is_key
    FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS cons
   INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu
           ON  cons.table_schema = kcu.table_schema
          AND cons.constraint_name = kcu.constraint_name
          AND cons.table_name = kcu.table_name
   WHERE cons.table_schema = (SELECT v_SchemaName FROM vars)
     AND cons.table_name IN (SELECT DISTINCT table_name FROM baseTbl)
     AND cons.constraint_type IN ('PRIMARY KEY','FOREIGN KEY','UNIQUE')
   GROUP BY cons.table_schema,
            cons.table_name,
            kcu.column_name,
            cons.constraint_type
)

, meta_for_keys
AS (
  SELECT schema_nm
        , table_nm
        , column_nm
        , STRING_AGG(is_key, ',' ORDER BY is_key) AS is_key
    FROM t
   GROUP BY schema_nm, table_nm, column_nm
)

, meta_ref_fks
AS (
  SELECT tc.table_name
       , kcu.column_name AS column_name
       , tc2.table_name AS ref_table_name
       , kcu2.column_name AS ref_col_name
       , update_rule
       , delete_rule
   FROM information_schema.referential_constraints rc
  INNER JOIN information_schema.table_constraints tc
     ON rc.constraint_name = tc.constraint_name
  INNER JOIN information_schema.table_constraints tc2
     ON rc.unique_constraint_name = tc2.constraint_name
  INNER JOIN information_schema.key_column_usage kcu
     ON rc.constraint_name = kcu.constraint_name
    AND tc.table_name = kcu.table_name
  INNER JOIN information_schema.key_column_usage kcu2
     ON rc.unique_constraint_name = kcu2.constraint_name
    AND tc2.table_name = kcu2.table_name
  INNER JOIN information_schema.columns c
     ON tc.table_name = c.table_name
    AND kcu.column_name = c.column_name
)

SELECT mc.*
     , mk.is_key
     , mfk.ref_table_name AS fk_ref_table
     , mfk.ref_col_name AS fk_ref_col_name
     , mfk.update_rule AS update_rule
     , mfk.delete_rule AS delete_rule
  FROM metadata_col mc
  LEFT JOIN meta_for_keys mk
    ON mc.table_nm = mk.table_nm AND mc.column_nm = mk.column_nm
  LEFT JOIN meta_ref_fks mfk
    ON mc.table_nm = mfk.table_name AND mc.column_nm = mfk.column_name
 ORDER BY 3, 2, 4;
```




## FURTHER Discussion


At the solution section there is a script. Let's analyse the code in the script:

```SQL
WITH vars
AS (
  SELECT
    'public'     AS v_SchemaName  -- Set to the schema whose tables you want in the Data Dictionary
  , 'NO'         AS v_TablesOnly  -- YES=Limit To Tables only; NO=Include views too
)
```

In this CTE we have two columns:

- `v_SchemaName`: here we can set the types of tables we want, in this case we set the value `public`.
- `v_TablesOnly`: Here we set a value `YES` or `NO` depending on what we want to view. `YES` means only Tables, `NO` includes view.



In the previous sections we learned how to retrieve information about the tables, columns, indexes and constraints from a database using the `information_schema` object in `PostgreSql`. We can retrieve the same information and other attributes in the `pg_catalog` system as illustrated below:


```SQL
WITH cat_tables
AS (
  SELECT oid, relkind, relname
    FROM pg_catalog.pg_class
   WHERE relkind IN ('r','v')
)
SELECT t.relkind AS table_type,
       t.relname AS table_nm,
       c.attname AS col_nm,
       c.attnum AS ordinal_pos
  FROM cat_tables AS t
 INNER JOIN pg_catalog.pg_attribute AS c
    ON t.oid = c.attrelid
 WHERE c.attnum > 0
 ORDER BY 1,2,4;
```

```console
table_type | table_nm | col_nm      | ordinal_pos|
-----------+----------+-------------+------------|
r          | actor    | actor_id    |      1     |
r          | actor    | first_name  |      2     |
r          | actor    | last_name   |      3     |
r          | actor    | last_update |      4     |
r          | address  | address_id  |      1     |
r          | address  | address     |      2     |
r          | address  | address2    |      3     |
r          | address  | district    |      4     |
r          | address  | city_id     |      5     |
r          | address  | postal_code |      6     |
r          | address  | phone       |      7     |
r          | address  | last_update |      8     |
...           ...          ...           ...
```

The table_type `r` and `v` stand for `ordinary table` and `view`, respectively.

```SQL
WITH cat_tables
AS (
  SELECT oid, relkind, relname
    FROM pg_catalog.pg_class
   WHERE relkind IN ('r','v')
)
SELECT t.relkind AS table_type,
       t.relname AS table_nm,
       c.attname AS col_nm,
       c.attnum AS ordinal_pos,
       typ.typname AS type_nm,
       CASE WHEN typ.typcategory = 'A' THEN 'Array'
            WHEN typ.typcategory = 'B' THEN 'Boolean'
            WHEN typ.typcategory = 'D' THEN 'Composite'
            WHEN typ.typcategory = 'E' THEN 'Enum'
            WHEN typ.typcategory = 'G' THEN 'Geometric'
            WHEN typ.typcategory = 'I' THEN 'Network address'
            WHEN typ.typcategory = 'N' THEN 'Numeric'
            WHEN typ.typcategory = 'P' THEN 'Pseudo-types'
            WHEN typ.typcategory = 'R' THEN 'Range'
            WHEN typ.typcategory = 'S' THEN 'String'
            WHEN typ.typcategory = 'T' THEN 'Timespan'
            WHEN typ.typcategory = 'U' THEN 'User-defined'
            WHEN typ.typcategory = 'V' THEN 'Bit-string'
            WHEN typ.typcategory = 'X' THEN 'unknown'
       END AS type_ctg
  FROM cat_tables AS t
 INNER JOIN pg_catalog.pg_attribute AS c
    ON t.oid = c.attrelid
 INNER JOIN pg_catalog.pg_type AS typ
    ON typ.oid = c.atttypid
 WHERE c.attnum > 0
 ORDER BY 1,2,4;
```

```console
table_type |               table_nm                |               col_nm                | ordinal_pos |     type_nm     |    type_ctg
------------+---------------------------------------+-------------------------------------+-------------+-----------------+-----------------
r          | actor                                 | actor_id                            |           1 | int4            | Numeric
r          | actor                                 | first_name                          |           2 | varchar         | String
r          | actor                                 | last_name                           |           3 | varchar         | String
r          | actor                                 | last_update                         |           4 | timestamp       | Composite
r          | address                               | address_id                          |           1 | int4            | Numeric
r          | address                               | address                             |           2 | varchar         | String
r          | address                               | address2                            |           3 | varchar         | String
r          | address                               | district                            |           4 | varchar         | String
r          | address                               | city_id                             |           5 | int2            | Numeric
r          | address                               | postal_code                         |           6 | varchar         | String
r          | address                               | phone                               |           7 | varchar         | String
r          | address                               | last_update                         |           8 | timestamp       | Composite
```

```SQL
WITH cat_tables
AS (
  SELECT oid, relkind, relname
    FROM pg_catalog.pg_class
   WHERE relkind IN ('r','v')
)
SELECT t.relkind AS table_type,
       t.relname AS table_nm,
       c.attname AS col_nm,
       c.attnum AS ordinal_pos,
       typ.typname AS type_nm,
       CASE WHEN typ.typcategory = 'A' THEN 'Array'
            WHEN typ.typcategory = 'B' THEN 'Boolean'
            WHEN typ.typcategory = 'D' THEN 'Composite'
            WHEN typ.typcategory = 'E' THEN 'Enum'
            WHEN typ.typcategory = 'G' THEN 'Geometric'
            WHEN typ.typcategory = 'I' THEN 'Network address'
            WHEN typ.typcategory = 'N' THEN 'Numeric'
            WHEN typ.typcategory = 'P' THEN 'Pseudo-types'
            WHEN typ.typcategory = 'R' THEN 'Range'
            WHEN typ.typcategory = 'S' THEN 'String'
            WHEN typ.typcategory = 'T' THEN 'Timespan'
            WHEN typ.typcategory = 'U' THEN 'User-defined'
            WHEN typ.typcategory = 'V' THEN 'Bit-string'
            WHEN typ.typcategory = 'X' THEN 'unknown'
       END AS type_ctg,
       pgadf.adsrc AS default_val
  FROM cat_tables AS t
 INNER JOIN pg_catalog.pg_attribute AS c
    ON t.oid = c.attrelid
 INNER JOIN pg_catalog.pg_type AS typ
    ON typ.oid = c.atttypid
  LEFT JOIN pg_catalog.pg_attrdef AS pgadf
    ON t.oid = pgadf.adrelid AND c.attnum = pgadf.adnum
 WHERE c.attnum > 0 AND t.relname = 'actor'
 ORDER BY 1,2,4;
```

```console
table_type | table_nm |   col_nm    | ordinal_pos |  type_nm  | type_ctg  |                  default_val
------------+----------+-------------+-------------+-----------+-----------+------------------------------------------------
r          | actor    | actor_id    |           1 | int4      | Numeric   | nextval('public.actor_actor_id_seq'::regclass)
r          | actor    | first_name  |           2 | varchar   | String    |
r          | actor    | last_name   |           3 | varchar   | String    |
r          | actor    | last_update |           4 | timestamp | Composite | now()
```
