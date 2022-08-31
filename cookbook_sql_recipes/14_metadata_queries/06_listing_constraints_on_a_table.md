# Listing Constraints on a Table

You want to list the constraints defined for a `table` in some schema and the `columns` they are defined on.


## Problem

List all the constraints in tables `film` and `actor` of the `dvdrental` sample database.


We want to retrieve the `constaints` information displayed by the commands `\d film` and `\d actor`.

**film** table:

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
    "film_fulltext_idx" gist (fulltext)
    "idx_fk_language_id" btree (language_id)
    "idx_title" btree (title)
Foreign-key constraints:
    "film_language_id_fkey" FOREIGN KEY (language_id) REFERENCES language(language_id) ON UPDATE CASCADE ON DELETE RESTRICT
Referenced by:
    TABLE "film_actor" CONSTRAINT "film_actor_film_id_fkey" FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT
    TABLE "film_category" CONSTRAINT "film_category_film_id_fkey" FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT
    TABLE "inventory" CONSTRAINT "inventory_film_id_fkey" FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT
Triggers:
    film_fulltext_trigger BEFORE INSERT OR UPDATE ON film FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('fulltext', 'pg_catalog.english', 'title', 'description')
    last_updated BEFORE UPDATE ON film FOR EACH ROW EXECUTE PROCEDURE last_updated()
```


**actor** table:

```console
dvdrental=# \d actor
                                            Table "public.actor"
   Column    |            Type             | Collation | Nullable |                 Default
-------------+-----------------------------+-----------+----------+-----------------------------------------
 actor_id    | integer                     |           | not null | nextval('actor_actor_id_seq'::regclass)
 first_name  | character varying(45)       |           | not null |
 last_name   | character varying(45)       |           | not null |
 last_update | timestamp without time zone |           | not null | now()
Indexes:
    "actor_pkey" PRIMARY KEY, btree (actor_id)
    "idx_actor_last_name" btree (last_name)
Referenced by:
    TABLE "film_actor" CONSTRAINT "film_actor_actor_id_fkey" FOREIGN KEY (actor_id) REFERENCES actor(actor_id) ON UPDATE CASCADE ON DELETE RESTRICT
Triggers:
    last_updated BEFORE UPDATE ON actor FOR EACH ROW EXECUTE PROCEDURE last_updated()
```

### Problem 1

List all the `PRIMARY KEY`, `FOREIGN KEYS`, `CHECK` constraints in both tables.

The output table is:

```console
table_name |    constraint_name     | constraint_type |                                         constraint_def
------------+------------------------+-----------------+-------------------------------------------------------------------------------------------------
actor      | 2200_27245_1_not_null  | CHECK           | actor_id IS NOT NULL
actor      | 2200_27245_4_not_null  | CHECK           | last_update IS NOT NULL
actor      | 2200_27245_3_not_null  | CHECK           | last_name IS NOT NULL
actor      | 2200_27245_2_not_null  | CHECK           | first_name IS NOT NULL
actor      | actor_pkey             | PRIMARY KEY     | PRIMARY KEY (actor_id)
film       | 2200_27259_2_not_null  | CHECK           | title IS NOT NULL
film       | 2200_27259_5_not_null  | CHECK           | language_id IS NOT NULL
film       | 2200_27259_9_not_null  | CHECK           | replacement_cost IS NOT NULL
film       | 2200_27259_1_not_null  | CHECK           | film_id IS NOT NULL
film       | 2200_27259_13_not_null | CHECK           | fulltext IS NOT NULL
film       | 2200_27259_7_not_null  | CHECK           | rental_rate IS NOT NULL
film       | 2200_27259_6_not_null  | CHECK           | rental_duration IS NOT NULL
film       | 2200_27259_11_not_null | CHECK           | last_update IS NOT NULL
film       | film_language_id_fkey  | FOREIGN KEY     | FOREIGN KEY (language_id) REFERENCES language(language_id) ON UPDATE CASCADE ON DELETE RESTRICT
film       | film_pkey              | PRIMARY KEY     | PRIMARY KEY (film_id)
```

```console
"actor_pkey" PRIMARY KEY,
   +---------+        
   |  actor  |  4 CHECK CONSTRAINTS
   |---------|        
PK |actor_id | actor_pkey
   +---------+     

   +------------+                             +------------+
   |  film      |   8 CHECK CONSTRAINTS       | language   |
   |------------|                             |------------|
PK |film_id     | film_pkey                   |            |
FK |language_id | film_language_id_fkey --->  | language_id|
   +------------+                             +------------+

```

## Problem 2

List all the tables that references the `actor` and `film` tables and the columns referenced.

```console
table_name   |      constraint_name       |                                     constraint_def
---------------+----------------------------+----------------------------------------------------------------------------------------
film_actor    | film_actor_actor_id_fkey   | FOREIGN KEY (actor_id) REFERENCES actor(actor_id) ON UPDATE CASCADE ON DELETE RESTRICT
film_actor    | film_actor_film_id_fkey    | FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT
film_category | film_category_film_id_fkey | FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT
inventory     | inventory_film_id_fkey     | FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT
```

```console
"actor_pkey" PRIMARY KEY, btree (actor_id)
   +--------+            +----------------+
   |  actor |            |  film_actor    |      
   |--------|            |----------------|
PK |actor_id| <--------- |    actor_id    | FK  film_actor_actor_id_fkey
   +--------+            |    film_id     | FK  film_actor_film_id_fkey
                   +-----+----------------+
                   |           
                   |            
   +--------+      |     +----------------+
   |  film  |      |     |  film_category |
   |--------|      |     |----------------|
PK |film_id | <----+---- |    film_id     | FK  film_category_film_id_fkey
   +--------+      |     +----------------+
                   |
                   |     +----------------+
                   |     | inventory      |  
                   +---- |----------------|
                         |     film_id    | FK  inventory_film_id_fkey
                         +----------------+
```


## Solution


- **Problem 1**:

```SQL
WITH film_actor_con AS (
  SELECT table_name,
         constraint_name,
         constraint_type
    FROM information_schema.table_constraints
   WHERE table_name IN ('film','actor')  
),
film_actor_con_chk AS (
  SELECT facn.table_name,
         facn.constraint_name,
         facn.constraint_type,
         chk.check_clause
    FROM film_actor_con facn
    LEFT JOIN information_schema.check_constraints chk
      ON facn.constraint_name = chk.constraint_name
   ORDER BY table_name, constraint_type

),
film_actor_con_pk_fk AS (
  SELECT conrelid::regclass AS table_name
        ,conname AS constraint_name
        ,pg_get_constraintdef(c.oid) AS constraint_def
    FROM pg_constraint c
    JOIN pg_namespace n ON n.oid = c.connamespace
   WHERE contype IN ('f', 'p ')
     AND n.nspname = 'public' -- your schema here
     AND conrelid::regclass::text IN ('film','actor')
   ORDER BY conrelid::regclass::text, contype DESC

)
SELECT f_chk.table_name,
       f_chk.constraint_name,
       f_chk.constraint_type,
       CASE WHEN f_chk.constraint_type = 'CHECK' THEN check_clause
            WHEN f_chk.constraint_type IN ('PRIMARY KEY','FOREIGN KEY')
            THEN constraint_def
       END AS constraint_def
  FROM film_actor_con_chk AS f_chk
  LEFT JOIN film_actor_con_pk_fk AS f_pk_fk
    ON f_chk.constraint_name = f_pk_fk.constraint_name;
```


- **Problem 2**:


```SQL
WITH film_actor_con_pk_fk AS (
  SELECT conrelid::regclass AS table_name
        ,conname AS constraint_name
        ,pg_get_constraintdef(c.oid) AS constraint_def
    FROM pg_constraint c
    JOIN pg_namespace n ON n.oid = c.connamespace
   WHERE contype IN ('f', 'p ')
     AND n.nspname = 'public' -- your schema here
     AND conrelid::regclass::text IN ('film','actor')
   ORDER BY conrelid::regclass::text, contype DESC
), film_actor_ref_by AS (
  SELECT table_name,
         constraint_name
    FROM information_schema.constraint_column_usage
   WHERE table_name IN ('film','actor')
     AND constraint_name NOT IN (SELECT constraint_name
                                   FROM film_actor_con_pk_fk)
)
SELECT conrelid::regclass AS table_name
      ,conname AS constraint_name
      ,pg_get_constraintdef(c.oid) AS constraint_def
  FROM pg_constraint c
  JOIN pg_namespace n ON n.oid = c.connamespace
 WHERE contype IN ('f', 'p ')
   AND n.nspname = 'public' -- your schema here
   AND c.conname IN (SELECT constraint_name FROM film_actor_ref_by)
 ORDER BY conrelid::regclass::text, contype DESC;
```


## Discussion


Let's first identify the `PRIMARY`,`FOREIGN` keys **CONSTRAINTS** and `CHECK` constrains in both tables.

```SQL
SELECT table_name,
       constraint_name,
       constraint_type,
  FROM information_schema.table_constraints
 WHERE table_name IN ('film','actor')  
 ORDER BY table_name, constraint_type;
```

```console
table_name |    constraint_name     | constraint_type
------------+------------------------+-----------------
actor      | 2200_27245_3_not_null  | CHECK
actor      | 2200_27245_4_not_null  | CHECK
actor      | 2200_27245_1_not_null  | CHECK
actor      | 2200_27245_2_not_null  | CHECK
actor      | actor_pkey             | PRIMARY KEY
film       | 2200_27259_13_not_null | CHECK
film       | 2200_27259_9_not_null  | CHECK
film       | 2200_27259_11_not_null | CHECK
film       | 2200_27259_1_not_null  | CHECK
film       | 2200_27259_2_not_null  | CHECK
film       | 2200_27259_5_not_null  | CHECK
film       | 2200_27259_6_not_null  | CHECK
film       | 2200_27259_7_not_null  | CHECK
film       | film_language_id_fkey  | FOREIGN KEY
film       | film_pkey              | PRIMARY KEY
```

The `PRIMARY KEY` constraint in the `actor` and `film` tables are `actor_pkey` and `film_pkey`, respectively. There is only a `FOREIGN KEY` in table `film`. Lastly, there are a bunch of `CHECK` constraints in both tables.

```console
"actor_pkey" PRIMARY KEY,
   +--------+        
   |  actor |              4 CHECK CONSTRAINTS
   |--------|        
PK |   ?    | actor_pkey
   +--------+     

   +--------+       
   |  film  |              8 CHECK CONSTRAINTS
   |--------|       
PK |   ?    | film_pkey
FK |   ?    | film_language_id_fkey ---> ?
   +--------+      

```


Let's find the `CHECK` constraint clause definition first:

```SQL
WITH film_actor_con AS (
  SELECT table_name,
         constraint_name,
         constraint_type
    FROM information_schema.table_constraints
   WHERE table_name IN ('film','actor')  
)
SELECT facn.table_name,
       facn.constraint_name,
       facn.constraint_type,
       chk.check_clause
  FROM film_actor_con facn
  LEFT JOIN information_schema.check_constraints chk
    ON facn.constraint_name = chk.constraint_name
 ORDER BY table_name, constraint_type;
```

```console
table_name |    constraint_name     | constraint_type |         check_clause
------------+------------------------+-----------------+------------------------------
actor      | 2200_27245_1_not_null  | CHECK           | actor_id IS NOT NULL
actor      | 2200_27245_4_not_null  | CHECK           | last_update IS NOT NULL
actor      | 2200_27245_3_not_null  | CHECK           | last_name IS NOT NULL
actor      | 2200_27245_2_not_null  | CHECK           | first_name IS NOT NULL
actor      | actor_pkey             | PRIMARY KEY     |
film       | 2200_27259_2_not_null  | CHECK           | title IS NOT NULL
film       | 2200_27259_5_not_null  | CHECK           | language_id IS NOT NULL
film       | 2200_27259_9_not_null  | CHECK           | replacement_cost IS NOT NULL
film       | 2200_27259_1_not_null  | CHECK           | film_id IS NOT NULL
film       | 2200_27259_13_not_null | CHECK           | fulltext IS NOT NULL
film       | 2200_27259_7_not_null  | CHECK           | rental_rate IS NOT NULL
film       | 2200_27259_6_not_null  | CHECK           | rental_duration IS NOT NULL
film       | 2200_27259_11_not_null | CHECK           | last_update IS NOT NULL
film       | film_language_id_fkey  | FOREIGN KEY     |
film       | film_pkey              | PRIMARY KEY     |
```



Let's find the the `PRIMARY` and `FOREIGN` keys definitions.

```SQL
SELECT conrelid::regclass AS table_name
      ,conname AS constraint_name
      ,pg_get_constraintdef(c.oid) AS constraint_def
  FROM pg_constraint c
  JOIN pg_namespace n ON n.oid = c.connamespace
 WHERE contype IN ('f', 'p ')
   AND n.nspname = 'public' -- your schema here
   AND conrelid::regclass::text IN ('film','actor')
 ORDER BY conrelid::regclass::text, contype DESC;
```

```console
table_name |    constraint_name    |                                         constraint_def
------------+-----------------------+-------------------------------------------------------------------------------------------------
actor      | actor_pkey            | PRIMARY KEY (actor_id)
film       | film_pkey             | PRIMARY KEY (film_id)
film       | film_language_id_fkey | FOREIGN KEY (language_id) REFERENCES language(language_id) ON UPDATE CASCADE ON DELETE RESTRICT
```

Let's join the last output table with the previous output table.

```SQL
WITH film_actor_con AS (
  SELECT table_name,
         constraint_name,
         constraint_type
    FROM information_schema.table_constraints
   WHERE table_name IN ('film','actor')  
),
film_actor_con_chk AS (
  SELECT facn.table_name,
         facn.constraint_name,
         facn.constraint_type,
         chk.check_clause
    FROM film_actor_con facn
    LEFT JOIN information_schema.check_constraints chk
      ON facn.constraint_name = chk.constraint_name
   ORDER BY table_name, constraint_type

),
film_actor_con_pk_fk AS (
  SELECT conrelid::regclass AS table_name
        ,conname AS constraint_name
        ,pg_get_constraintdef(c.oid) AS constraint_def
    FROM pg_constraint c
    JOIN pg_namespace n ON n.oid = c.connamespace
   WHERE contype IN ('f', 'p ')
     AND n.nspname = 'public' -- your schema here
     AND conrelid::regclass::text IN ('film','actor')
   ORDER BY conrelid::regclass::text, contype DESC

)
SELECT f_chk.table_name,
       f_chk.constraint_name,
       f_chk.constraint_type,
       CASE WHEN f_chk.constraint_type = 'CHECK' THEN check_clause
            WHEN f_chk.constraint_type IN ('PRIMARY KEY','FOREIGN KEY')
            THEN constraint_def
       END AS constraint_def
  FROM film_actor_con_chk AS f_chk
  LEFT JOIN film_actor_con_pk_fk AS f_pk_fk
    ON f_chk.constraint_name = f_pk_fk.constraint_name;
```


```console
table_name |    constraint_name     | constraint_type |                                         constraint_def
------------+------------------------+-----------------+-------------------------------------------------------------------------------------------------
actor      | 2200_27245_1_not_null  | CHECK           | actor_id IS NOT NULL
actor      | 2200_27245_4_not_null  | CHECK           | last_update IS NOT NULL
actor      | 2200_27245_3_not_null  | CHECK           | last_name IS NOT NULL
actor      | 2200_27245_2_not_null  | CHECK           | first_name IS NOT NULL
actor      | actor_pkey             | PRIMARY KEY     | PRIMARY KEY (actor_id)
film       | 2200_27259_2_not_null  | CHECK           | title IS NOT NULL
film       | 2200_27259_5_not_null  | CHECK           | language_id IS NOT NULL
film       | 2200_27259_9_not_null  | CHECK           | replacement_cost IS NOT NULL
film       | 2200_27259_1_not_null  | CHECK           | film_id IS NOT NULL
film       | 2200_27259_13_not_null | CHECK           | fulltext IS NOT NULL
film       | 2200_27259_7_not_null  | CHECK           | rental_rate IS NOT NULL
film       | 2200_27259_6_not_null  | CHECK           | rental_duration IS NOT NULL
film       | 2200_27259_11_not_null | CHECK           | last_update IS NOT NULL
film       | film_language_id_fkey  | FOREIGN KEY     | FOREIGN KEY (language_id) REFERENCES language(language_id) ON UPDATE CASCADE ON DELETE RESTRICT
film       | film_pkey              | PRIMARY KEY     | PRIMARY KEY (film_id)
```

## Problem 2

```SQL
SELECT table_name,
       column_name,
       constraint_name
  FROM information_schema.constraint_column_usage
 WHERE table_name IN ('film','actor')
 ORDER BY table_name;
```

```console
table_name | column_name |      constraint_name
-----------+-------------+----------------------------
actor      | actor_id    | actor_pkey
actor      | actor_id    | film_actor_actor_id_fkey
film       | film_id     | film_pkey
film       | film_id     | film_actor_film_id_fkey
film       | film_id     | film_category_film_id_fkey
film       | film_id     | inventory_film_id_fkey
```

```console
"actor_pkey" PRIMARY KEY, btree (actor_id)
   +--------+            +----------------+
   |  actor |            |  film_actor    |      
   |--------|            |----------------|
PK |actor_id| <--------- |                | FK ? film_actor_actor_id_fkey
   +--------+      +-----+----------------+
                   |           
                   |            
   +--------+      |     +----------------+
   |  film  |      |     |  film_category |
   |--------|      |     |----------------|
PK |film_id | <----+---- |                | FK ? film_category_film_id_fkey
   +--------+      |     +----------------+
                   |
                   |     +----------------+
                   |     | inventory      |  
                   +---- |----------------|
                         |                | FK ? inventory_film_id_fkey
                         +----------------+
```

Let's find the definition of the following constraints `film_category_film_id_fkey` and `inventory_film_id_fkey`.


```SQL
WITH film_actor_con_pk_fk AS (
  SELECT conrelid::regclass AS table_name
        ,conname AS constraint_name
        ,pg_get_constraintdef(c.oid) AS constraint_def
    FROM pg_constraint c
    JOIN pg_namespace n ON n.oid = c.connamespace
   WHERE contype IN ('f', 'p ')
     AND n.nspname = 'public' -- your schema here
     AND conrelid::regclass::text IN ('film','actor')
   ORDER BY conrelid::regclass::text, contype DESC
)
SELECT table_name,
       constraint_name
  FROM information_schema.constraint_column_usage
 WHERE table_name IN ('film','actor')
   AND constraint_name NOT IN (SELECT constraint_name
                                 FROM film_actor_con_pk_fk)
 ORDER BY table_name;
```

```console
table_name |      constraint_name
-----------+----------------------------
actor      | film_actor_actor_id_fkey
film       | film_actor_film_id_fkey
film       | film_category_film_id_fkey
film       | inventory_film_id_fkey
```

```SQL
WITH film_actor_con_pk_fk AS (
  SELECT conrelid::regclass AS table_name
        ,conname AS constraint_name
        ,pg_get_constraintdef(c.oid) AS constraint_def
    FROM pg_constraint c
    JOIN pg_namespace n ON n.oid = c.connamespace
   WHERE contype IN ('f', 'p ')
     AND n.nspname = 'public' -- your schema here
     AND conrelid::regclass::text IN ('film','actor')
   ORDER BY conrelid::regclass::text, contype DESC
), film_actor_ref_by AS (
  SELECT table_name,
         constraint_name
    FROM information_schema.constraint_column_usage
   WHERE table_name IN ('film','actor')
     AND constraint_name NOT IN (SELECT constraint_name
                                   FROM film_actor_con_pk_fk)
)
SELECT conrelid::regclass AS table_name
      ,conname AS constraint_name
      ,pg_get_constraintdef(c.oid) AS constraint_def
  FROM pg_constraint c
  JOIN pg_namespace n ON n.oid = c.connamespace
 WHERE contype IN ('f', 'p ')
   AND n.nspname = 'public' -- your schema here
   AND c.conname IN (SELECT constraint_name FROM film_actor_ref_by)
 ORDER BY conrelid::regclass::text, contype DESC;
```

```console
table_name   |      constraint_name       |                                     constraint_def
---------------+----------------------------+----------------------------------------------------------------------------------------
film_actor    | film_actor_actor_id_fkey   | FOREIGN KEY (actor_id) REFERENCES actor(actor_id) ON UPDATE CASCADE ON DELETE RESTRICT
film_actor    | film_actor_film_id_fkey    | FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT
film_category | film_category_film_id_fkey | FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT
inventory     | inventory_film_id_fkey     | FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT
```


## LINKS

```console
information_schema
     |
     +-- constraint_column_usage
     +-- table_constraints
```

Documentation available :
- [information_schema](https://www.postgresql.org/docs/current/information-schema.html)
- [information_schema.constraint_column_usage](https://www.postgresql.org/docs/current/infoschema-constraint-column-usage.html).
- [information_schema.table_constrains](https://www.postgresql.org/docs/current/infoschema-table-constraints.html)
