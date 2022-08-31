# Entity Relationship Graph

In the previous lesson we introduced the  `INFORMATION_SCHEMA` and `pg_catalog` objects to describe the tables in the `dvdrental` database.

This collection of tables constitutes the `DEFINITION_SCHEMA` that contains the descriptions of all structures in the database, (also known as **data dictionary**).

The data dictionary typically includes:

- tables and views, their column properties such as name, ordinal position, data type/length/size/precision, allows nulls, and of course the column description.

A good data dictionary also indicates `which columns are a part of` a **primary key** and **foreign key**.

The **primary** and **foreign** `keys` are used to create **relationships** between tables.

- A **primary key** uniquely identifies each record in a table.

- A **foreign key** is a column or a group of columns in a table that `reference the` **primary key** of `another table`.

The table that contains the `foreign key` is called the `referencing table` or **child table**.

And the table `referenced by` the `foreign key` is called the `referenced table` or **parent table**.

The relationships between table can be easily visualize with an oriented graph, where each node represents a table and the edge connecting two nodes indicates the **parent-child** `relationship`.

This is a typical example of **hierarchical** data, (`tree-like` structure), where the `roots` are the tables with no foreign keys or a self-referencing keys and the `leaves` are tables with no `referencing` tables, (children).

Given the data dictionary table generated in the previous lesson, create a hierarchical view of the `parent-child` **relationship**.

## Problem  

The picture below illustrate the `ERD` of the `dvdrental` database.

![dvdrental erd](./images/16_dvdrental.png)


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


The following table describes the `parent-child` **relationship** between tables in the `dvdrental` sample database.


```console
dvdrental=# SELECT table_nm, column_nm, is_key, fk_ref_table, fk_ref_col_name
dvdrental-#   FROM dictionary_db
dvdrental-#  WHERE is_key IS NOT NULL;
```

The output table is given below:


```console
+--------------------------------------------------------------------------+
|table_nm      |    column_nm     | is_key | fk_ref_table | fk_ref_col_name|
|--------------+------------------+--------+--------------+----------------|
|actor         | actor_id         | PK     |              |                |
|address       | address_id       | PK     |              |                |
|address       | city_id          | FK     | city         | city_id        |
|category      | category_id      | PK     |              |                |
|city          | city_id          | PK     |              |                |
|city          | country_id       | FK     | country      | country_id     |
|country       | country_id       | PK     |              |                |
|customer      | customer_id      | PK     |              |                |
|customer      | address_id       | FK     | address      | address_id     |
|film          | film_id          | PK     |              |                |
|film          | language_id      | FK     | language     | language_id    |
|film_actor    | actor_id         | FK,PK  | actor        | actor_id       |
|film_actor    | film_id          | FK,PK  | film         | film_id        |
|film_category | film_id          | FK,PK  | film         | film_id        |
|film_category | category_id      | FK,PK  | category     | category_id    |
|inventory     | inventory_id     | PK     |              |                |
|inventory     | film_id          | FK     | film         | film_id        |
|language      | language_id      | PK     |              |                |
|payment       | payment_id       | PK     |              |                |
|payment       | customer_id      | FK     | customer     | customer_id    |
|payment       | staff_id         | FK     | staff        | staff_id       |
|payment       | rental_id        | FK     | rental       | rental_id      |
|rental        | rental_id        | PK     |              |                |
|rental        | inventory_id     | FK     | inventory    | inventory_id   |
|rental        | customer_id      | FK     | customer     | customer_id    |
|rental        | staff_id         | FK     | staff        | staff_id       |
|staff         | staff_id         | PK     |              |                |
|staff         | address_id       | FK     | address      | address_id     |
|store         | store_id         | PK     |              |                |
|store         | manager_staff_id | FK     | staff        | staff_id       |
|store         | address_id       | FK     | address      | address_id     |
+--------------------------------------------------------------------------+
```

The **parent-child** graph is illustrated below:


```console  
╎
+-----------------+    +-----------------+    +--------------+    +----------------+
|    category     |    |     language    |    |     actor    |    |     country    |
+---+-------------+    +---+-------------+    +---+----------+    +---+------------+
|PK | category_id |    |PK | language_id |    |PK | actor_id |    |PK | country_id |
+---+-------------+    +---+-------------+    +---+----------+    +---+------------+
   |                       |                      |                    |
   |                       |                      |                    |
   |                       ▼                      |                    ▼
   |                   +-----------------+        |               +----------------+
   |                   |       film      |        |               |       city     |
   |                   +---+-------------+        |               +---+------------+
   |                   |PK | film_id     |        |               |PK | city_id    |
   |                   |FK | language_id |        |               |FK | country_id |
   |                   +---+-------------+        |               +---+------------+
   |                       |    |    |            |                    |
   ◯-----------------------+    |    +------------◯                    |
   |                            |                 |                    |
   ▼                            ▼                 ▼                    ▼
 +-------------------+  +-----------------+  +-----------------+  +----------------+
 |   film_category   |  |    inventory    |  |   film_actor    |  |   address      |
 +------+------------+  +---+-------------+  +------+----------+  +---+------------+
 |FK,PK | film_id    |  |PK | inventory_id|  |FK,PK | actor_id |  |PK | address_id |
 |FK,PK | category_id|  |FK | film_id     |  |FK,PK | film_id  |  |FK | city_id    |
 +------+------------+  +---+-------------+  +------+----------+  +---+------------+
                          |                                            |
                          |                                            |
                          |   +--------------------+-------------------+--------+
                          |   |                    |                            |
                          |   |                    |                            ▼
                          |   |                    |               +---------------+
                          |   |                    |               |       staff   |
                          |   |                    |               +---+-----------+
                          |   |                    |               |PK | staff_id  |
                          |   |                    |               |FK | address_id|
                          |   |                    |               +---+-----------+    
                          |   |                    |                         |
                          |   |                    ◯-------------------------+
                          |   |                    |                         |
                          |   |                    ▼                         |
                          |   |             +--------------------- +         |
                          |   |             |       store          |         |
                          |   |             +---+------------------+         |
                          |   |             |PK | store_id         |         |
                          |   |             |FK | manager_staff_id |         |
                          |   |             |FK | address_id       |         |
                          |   |             +---+------------------+         |
                          |   |                                              |
                          |   |                                              |
                          |   ▼                                              |
                          |   +-----------------+                            |
                          |   |    customer     |                            |
                          |   +---+-------------+                            |
                          |   |PK | customer_id |                            |
                          |   |FK | address_id  |                            |
                          |   +---+-------------+                            |
                          |       |                                          |
                          |       ◯-------------------------◯----------------+
                          |       |                         |
                          +-------◯                         |
                                  |                         |
                                  ▼                         |
                               +------------------+         |
                               |     rental       |         |
                               +---+--------------+         |
                               |PK | rental_id    |         |
                               |FK | inventory_id |         |
                               |FK | customer_id  |         |
                               +---+--------------+         |
                                  |                         |
                                  +-------------------------◯
                                                            |
                                                            ▼
                                                    +-----------------+
                                                    |    payment      |
                                                    +---+-------------+
                                                    |PK | payment_id  |
                                                    |FK | customer_id |
                                                    |FK | staff_id    |
                                                    |FK | rental_id   |
                                                    +---+-------------+

```

For this example,

- A `leaf` (`L`) node is a **table whit no referencing tables**.

- A `root` (`R`) node is a **table without a foreign key constraint**.     

The graph is acyclic and there are four `roots` and four `leaves`.
We want to return all the paths in the `parent-child` **pk-fk** `graph`:

```console
path_fk
-------------------------------------------------------------
actor -> film_actor
category -> film_category
language -> film -> film_actor
language -> film -> film_category
country -> city -> address -> store
country -> city -> address -> customer -> payment
country -> city -> address -> staff -> payment
country -> city -> address -> staff -> store
language -> film -> inventory -> rental -> payment
country -> city -> address -> customer -> rental -> payment
country -> city -> address -> staff -> rental -> payment
(11 rows)
```

## Solution


```SQL
CREATE VIEW parent_child_db AS
WITH x AS (
  SELECT  table_nm
        , fk_ref_table AS parent
        , CASE WHEN fk_ref_table IS NULL
               THEN 0
               ELSE 1
        END AS parent_flag
    FROM dictionary_db
   WHERE is_key IS NOT NULL
),
y AS (
  SELECT  table_nm
        , parent
        , SUM(parent_flag) OVER (PARTITION BY table_nm)AS parent_cnt
    FROM x
)
SELECT  table_nm
      , parent
  FROM y
 WHERE parent_cnt = 0  AND parent IS NULL
 GROUP BY 1,2
UNION ALL
SELECT  table_nm
      , parent
  FROM y
 WHERE parent_cnt > 0  AND parent IS NOT NULL
 GROUP BY 1,2
 ORDER BY parent DESC;


WITH RECURSIVE x (path_t, table_nm, parent, is_leaf, level) AS (
  -- Anchor Query (select the roots)
  SELECT  table_nm::VARCHAR(100) AS path_t
        , table_nm AS table_nm
        , parent AS parent
        , 0 AS is_leaf
        , 0 AS level
    FROM parent_child_db
   WHERE parent IS NULL
   UNION ALL
   --- Recursive Query
   SELECT (x.path_t || ' -> ' || t.table_nm)::VARCHAR(100)
         , t.table_nm
         , t.parent
         , CASE WHEN NOT EXISTS (SELECT NULL
                                   FROM parent_child_db pcdb
                                  WHERE pcdb.parent = t.table_nm)
                THEN 1 ELSE 0
           END AS is_leaf
         , x.level + 1 AS level
      FROM parent_child_db t, x
     WHERE t.parent = x.table_nm  AND level < 6
)
SELECT path_t AS path_fk
  FROM x
 WHERE is_leaf = 1
 ORDER BY level, path_t;
```


## Discussion

```SQL
SELECT  table_nm AS table_nm
      , fk_ref_table AS parent
      , CASE WHEN fk_ref_table IS NULL
             THEN 0
             ELSE 1
      END AS parent_flag
  FROM dictionary_db
 WHERE is_key IS NOT NULL;      
```

We want to partition the table in two groups:

- The tables that have at least a foreign key (i.e a parent table)
- The tables that do not have a foreign key (i.e the roots)



The data is logical organised as a hierarchical data structure. A solution is to traverse the graph using a `recursive` query. The first step is to pre-process the `dictionary_db` table and return an input table for the recursive query.

The solution is to create a view of the input table and then apply the recursive query on the input table. The structure of the input table is a two columns relation:

- table_nm: The table name in the `dvdrental` sample database.
- parent: The parent table of the `table_nm`.

To create the input table, we first need to distinguish the tables that have at least a foreign key (i.e. a parent table)  from the tables that do not have a foreign key (i.e. the roots in the graph). The idea is to use a flag to indicate the two groups.

```console
table_nm    |  parent   | parent_flag
---------------+-----------+-------------
actor         |           |           0
address       |           |           0
address       | city      |           1
category      |           |           0
city          |           |           0
city          | country   |           1
country       |           |           0
customer      |           |           0
customer      | address   |           1
film          |           |           0
film          | language  |           1
film_actor    | actor     |           1
film_actor    | film      |           1
film_category | film      |           1
film_category | category  |           1
inventory     |           |           0
inventory     | film      |           1
language      |           |           0
payment       |           |           0
payment       | customer  |           1
payment       | staff     |           1
payment       | rental    |           1
rental        |           |           0
rental        | inventory |           1
rental        | customer  |           1
rental        | staff     |           1
staff         |           |           0
staff         | address   |           1
store         |           |           0
store         | staff     |           1
store         | address   |           1
```

```SQL
WITH x AS (
  SELECT  table_nm
        , fk_ref_table AS parent
        , CASE WHEN fk_ref_table IS NULL
               THEN 0
               ELSE 1
        END AS parent_flag
    FROM dictionary_db
   WHERE is_key IS NOT NULL
)
SELECT  table_nm
      , parent
      , SUM(parent_flag) OVER (PARTITION BY table_nm)AS parent_cn
  FROM x;
```

```console
table_nm    |  parent   | parent_cn
---------------+-----------+-----------
actor         |           |         0
address       |           |         1
address       | city      |         1
category      |           |         0
city          |           |         1
city          | country   |         1
country       |           |         0
customer      |           |         1
customer      | address   |         1
film          |           |         1
film          | language  |         1
film_actor    | actor     |         2
film_actor    | film      |         2
film_category | film      |         2
film_category | category  |         2
inventory     |           |         1
inventory     | film      |         1
language      |           |         0
payment       |           |         3
payment       | customer  |         3
payment       | staff     |         3
payment       | rental    |         3
rental        |           |         3
rental        | inventory |         3
rental        | customer  |         3
rental        | staff     |         3
staff         |           |         1
staff         | address   |         1
store         |           |         2
store         | staff     |         2
store         | address   |         2
```

In the resulting table the rows with the value zero in the last column indicate the `root` tables. Now it's straightforward to combine the two groups.


```SQL
WITH x AS (
  SELECT  table_nm
        , fk_ref_table AS parent
        , CASE WHEN fk_ref_table IS NULL
               THEN 0
               ELSE 1
        END AS parent_flag
    FROM dictionary_db
   WHERE is_key IS NOT NULL
),
y AS (
  SELECT  table_nm
        , parent
        , SUM(parent_flag) OVER (PARTITION BY table_nm)AS parent_cnt
    FROM x
)
SELECT  table_nm
      , parent
  FROM y
 WHERE parent_cnt = 0  AND parent IS NULL
 GROUP BY 1,2
UNION ALL
SELECT  table_nm
      , parent
  FROM y
 WHERE parent_cnt > 0  AND parent IS NOT NULL
 GROUP BY 1,2
 ORDER BY parent DESC;  
```

```console
table_nm    |  parent
---------------+-----------
actor         | <--- |
category      | <--- |
country       | <--- |  roots
language      | <--- |
----------------------
store         | staff |
payment       | staff |
rental        | staff |
-----------------------
payment       | rental|
------------------------
film          | language
------------------------
rental        | inventory
-----------------------
film_actor    | film
film_category | film
inventory     | film
------------------------
rental        | customer
payment       | customer
------------------------
city          | country
------------------------
address       | city
-----------------------
film_category | category
-----------------------
staff         | address
store         | address
customer      | address
------------------------
film_actor    | actor
```

Next we create the view as follow:

```SQL
CREATE VIEW parent_child_db AS
WITH x AS (
  SELECT  table_nm
        , fk_ref_table AS parent
        , CASE WHEN fk_ref_table IS NULL
               THEN 0
               ELSE 1
        END AS parent_flag
    FROM dictionary_db
   WHERE is_key IS NOT NULL
),
y AS (
  SELECT  table_nm
        , parent
        , SUM(parent_flag) OVER (PARTITION BY table_nm)AS parent_cnt
    FROM x
)
SELECT  table_nm
      , parent
  FROM y
 WHERE parent_cnt = 0  AND parent IS NULL
 GROUP BY 1,2
UNION ALL
SELECT  table_nm
      , parent
  FROM y
 WHERE parent_cnt > 0  AND parent IS NOT NULL
 GROUP BY 1,2
 ORDER BY parent DESC;
```


Next, apply the recursive query to the input view table `parent_child_db`.

```SQL
WITH RECURSIVE x (path_t, table_nm, parent, is_leaf) AS (
  -- Anchor Query (select the roots)
  SELECT  table_nm::VARCHAR(100) AS path_t
        , table_nm AS table_nm
        , parent AS parent
        , 0 AS is_leaf
    FROM parent_child_db
   WHERE parent IS NULL
   UNION ALL
   --- Recursive Query
   SELECT (x.path_t || ' -> ' || t.table_nm)::VARCHAR(100)
         , t.table_nm
         , t.parent
         , CASE WHEN NOT EXISTS (SELECT NULL
                                   FROM parent_child_db pcdb
                                  WHERE pcdb.parent = t.table_nm)
                THEN 1 ELSE 0
           END AS
      FROM parent_child_db t,
     INNER JOIN x
        ON t.parent = x.table_nm -- Terminal condition
)
```


Let's look at how the result set gets built up as the query steps through the data.

## Initial query

The query begins with the Anchor, which returns all rows without an ancestor, i.e., the top of the hierarchy.

```SQL
SELECT  table_nm::VARCHAR(100) AS path_t
      , table_nm AS table_nm
      , parent AS parent
      , 0 AS is_leaf
  FROM parent_child_db
 WHERE parent IS NULL;
```

```console
path_t   | table_nm | parent | is_leaf
---------+----------+--------+---------
actor    | actor    |        |       0
category | category |        |       0
country  | country  |        |       0
language | language |        |       0
(4 rows)
```

### Recursion 1

```console  
╎       x                       x                    x                    x
+-----------------+    +-----------------+    +--------------+    +----------------+
|    category     |    |     language    |    |     actor    |    |     country    |
+---+-------------+    +---+-------------+    +---+----------+    +---+------------+
   |                       |                      |                    |
   |                       |                      |                    |
   |                       |                      |                    |
   |                       |                      |                    |
   |                       ▼      t               |                    ▼   t
   |                   +-----------------+        |               +----------------+
   |                   |       film      |        |               |       city     |
   |                   +---+-------------+        |               +---+------------+
   |                                              |         
   |                                              |               
   |                                              |
   |                                              |                    
   |                                              |                    
   |                                              |                    
   ▼        t                                     ▼      t              
 +-------------------+                     +-----------------+    
 |   film_category   |                     |   film_actor    |  
 +------+------------+                     +------+----------+  
 ```

 ```SQL
 WITH RECURSIVE x (path_t, table_nm, parent, is_leaf, level) AS (
   -- Anchor Query (select the roots)
   SELECT  table_nm::VARCHAR(100) AS path_t
         , table_nm AS table_nm
         , parent AS parent
         , 0 AS is_leaf
         , 0 AS level
     FROM parent_child_db
    WHERE parent IS NULL
    UNION ALL
    --- Recursive Query
    SELECT (x.path_t || ' -> ' || t.table_nm)::VARCHAR(100)
          , t.table_nm
          , t.parent
          , CASE WHEN NOT EXISTS (SELECT NULL
                                    FROM parent_child_db pcdb
                                   WHERE pcdb.parent = t.table_nm)
                 THEN 1 ELSE 0
            END AS is_leaf
          , x.level + 1 AS level
       FROM parent_child_db t, x
      WHERE t.parent = x.table_nm  AND level < 1
 )
 SELECT *
   FROM x;
 ```

```console
path_t                    |   table_nm    |  parent  | is_leaf | level
--------------------------+---------------+----------+---------+-------
actor -> film_actor       | film_actor    | actor    |       1 |     1
category -> film_category | film_category | category |       1 |     1
country -> city           | city          | country  |       0 |     1
language -> film          | film          | language |       0 |     1
```

### Recursion 2

```console
                      x                                          x
                   +-----------------+                       +----------------+
                   |       film      |                       |       city     |
                   +---+-------------+                       +---+------------+
                            |    |                                 |
                            |    +------------◯                    |
                            |                 |                    |
    x                       ▼    t            ▼      x,t           ▼   t
+-------------------+  +-----------------+  +-----------------+  +----------------+
|   film_category   |  |    inventory    |  |   film_actor    |  |   address      |
+------+------------+  +---+-------------+  +------+----------+  +---+------------+

```

```SQL
WITH RECURSIVE x (path_t, table_nm, parent, is_leaf, level) AS (
  -- Anchor Query (select the roots)
  SELECT  table_nm::VARCHAR(100) AS path_t
        , table_nm AS table_nm
        , parent AS parent
        , 0 AS is_leaf
        , 0 AS level
    FROM parent_child_db
   WHERE parent IS NULL
   UNION ALL
   --- Recursive Query
   SELECT (x.path_t || ' -> ' || t.table_nm)::VARCHAR(100)
         , t.table_nm
         , t.parent
         , CASE WHEN NOT EXISTS (SELECT NULL
                                   FROM parent_child_db pcdb
                                  WHERE pcdb.parent = t.table_nm)
                THEN 1 ELSE 0
           END AS is_leaf
         , x.level + 1 AS level
      FROM parent_child_db t, x
     WHERE t.parent = x.table_nm  AND level < 2
)
SELECT *
  FROM x;
```

```console
path_t                            |   table_nm    |  parent  | is_leaf | level
----------------------------------+---------------+----------+---------+-------
country -> city -> address        | address       | city     |       0 |     2
language -> film -> inventory     | inventory     | film     |       0 |     2
language -> film -> film_category | film_category | film     |       1 |     2
language -> film -> film_actor    | film_actor    | film     |       1 |     2
```

### Recursion 3

```console
        x                   x                     x                   x
+-------------------+  +-----------------+  +-----------------+  +----------------+
|   film_category   |  |    inventory    |  |   film_actor    |  |   address      |
+------+------------+  +---+-------------+  +------+----------+  +---+------------+
|FK,PK | film_id    |  |PK | inventory_id|  |FK,PK | actor_id |  |PK | address_id |
|FK,PK | category_id|  |FK | film_id     |  |FK,PK | film_id  |  |FK | city_id    |
+------+------------+  +---+-------------+  +------+----------+  +---+------------+
                         |                                            |
                         |                                            |
                         |   +--------------------+-------------------+--------+
                         |   |                    |                            |
                         |   |                    |                      t     ▼
                         |   |                    |               +---------------+
                         |   |                    |               |       staff   |
                         |   |                    |               +---+-----------+
                         |   |                    |               |PK | staff_id  |
                         |   |                    |               |FK | address_id|
                         |   |                    |               +---+-----------+    
                         |   |                    |                         
                         |   |                    |
                         |   |                    |                 
                         |   |                    ▼      t           
                         |   |             +--------------------- +
                         |   |             |       store          |
                         |   |             +---+------------------+
                         |   |             |PK | store_id         |
                         |   |             |FK | manager_staff_id |
                         |   |             |FK | address_id       |
                         |   |             +---+------------------+
                         |   |                                      
                         |   |                                      
                         |   ▼         t                             
                         |   +-----------------+                    
                         |   |    customer     |                    
                         |   +---+-------------+                    
                         |   |PK | customer_id |                    
                         |   |FK | address_id  |                    
                         |   +---+-------------+                    
                         |                                         
                         |       
                         |                               
                         +-------◯                         
                                 |                         
                                 ▼       t                  
                              +------------------+         
                              |     rental       |         
                              +---+--------------+         
                              |PK | rental_id    |         
                              |FK | inventory_id |         
                              |FK | customer_id  |         
                              +---+--------------+          
```

```SQL
WITH RECURSIVE x (path_t, table_nm, parent, is_leaf, level) AS (
  -- Anchor Query (select the roots)
  SELECT  table_nm::VARCHAR(100) AS path_t
        , table_nm AS table_nm
        , parent AS parent
        , 0 AS is_leaf
        , 0 AS level
    FROM parent_child_db
   WHERE parent IS NULL
   UNION ALL
   --- Recursive Query
   SELECT (x.path_t || ' -> ' || t.table_nm)::VARCHAR(100)
         , t.table_nm
         , t.parent
         , CASE WHEN NOT EXISTS (SELECT NULL
                                   FROM parent_child_db pcdb
                                  WHERE pcdb.parent = t.table_nm)
                THEN 1 ELSE 0
           END AS is_leaf
         , x.level + 1 AS level
      FROM parent_child_db t, x
     WHERE t.parent = x.table_nm  AND level < 3
)
SELECT *
  FROM x;
```

```console
path_t                                  |   table_nm    |  parent   | is_leaf | level
----------------------------------------+---------------+-----------+---------+-------
country -> city -> address -> customer  | customer      | address   |       0 |     3
country -> city -> address -> store     | store         | address   |       1 |     3
country -> city -> address -> staff     | staff         | address   |       0 |     3
language -> film -> inventory -> rental | rental        | inventory |       0 |     3
```

### Recursion 4

```console
                                                  x
                                         +---------------+
                                         |       staff   |
                                         +---+-----------+
                                         |PK | staff_id  |
                                         |FK | address_id|
                                         +---+-----------+    
                                                   |
                         ◯-------------------------+
                         |                         |
                         ▼      x                  |
                  +--------------------- +         |
                  |       store          |         |
                  +---+------------------+         |
                  |PK | store_id         |         |
                  |FK | manager_staff_id |         |
                  |FK | address_id       |         |
                  +---+------------------+         |
                                                   |
                                                   |
            x                                      |
    +-----------------+                            |
    |    customer     |                            |
    +---+-------------+                            |
    |PK | customer_id |                            |
    |FK | address_id  |                            |
    +---+-------------+                            |
        |                                          |
        ◯-------------------------◯----------------+
        |                         |
        |                         |
        |                         |
        ▼    x,t                  |
     +------------------+         |
     |     rental       |         |
     +---+--------------+         |
     |PK | rental_id    |         |
     |FK | inventory_id |         |
     |FK | customer_id  |         |
     +---+--------------+         |
        |                         |
        +-------------------------◯
                                  |
                                  ▼  t
                          +-----------------+
                          |    payment      |
                          +---+-------------+
                          |PK | payment_id  |
                          |FK | customer_id |
                          |FK | staff_id    |
                          |FK | rental_id   |
                          +---+-------------+
```

```SQL
WITH RECURSIVE x (path_t, table_nm, parent, is_leaf, level) AS (
  -- Anchor Query (select the roots)
  SELECT  table_nm::VARCHAR(100) AS path_t
        , table_nm AS table_nm
        , parent AS parent
        , 0 AS is_leaf
        , 0 AS level
    FROM parent_child_db
   WHERE parent IS NULL
   UNION ALL
   --- Recursive Query
   SELECT (x.path_t || ' -> ' || t.table_nm)::VARCHAR(100)
         , t.table_nm
         , t.parent
         , CASE WHEN NOT EXISTS (SELECT NULL
                                   FROM parent_child_db pcdb
                                  WHERE pcdb.parent = t.table_nm)
                THEN 1 ELSE 0
           END AS is_leaf
         , x.level + 1 AS level
      FROM parent_child_db t, x
     WHERE t.parent = x.table_nm  AND level < 4
)
SELECT *
  FROM x;
```

```console
path_t                                             | table_nm|  parent | is_leaf | level
---------------------------------------------------+---------+---------+---------+-----
country -> city -> address -> customer -> payment  | payment | customer|   1     |  4
country -> city -> address -> customer -> rental   | rental  | customer|   0     |  4
country -> city -> address -> staff -> rental      | rental  | staff   |   0     |  4
country -> city -> address -> staff -> payment     | payment | staff   |   1     |  4
country -> city -> address -> staff -> store       | store   | staff   |   1     |  4
language -> film -> inventory -> rental -> payment | payment | rental  |   1     |  4
```

### Recursion 5

```console

                                       x
                             +--------------------- +        
                             |       store          |        
                             +---+------------------+        
                             |PK | store_id         |        
                             |FK | manager_staff_id |        
                             |FK | address_id       |        
                             +---+------------------+        
       x
+------------------+         
|     rental       |         
+---+--------------+         
|PK | rental_id    |         
|FK | inventory_id |         
|FK | customer_id  |         
+---+--------------+         
   |                         
   +-------------------------◯
                             |
                             ▼  x,t
                     +-----------------+
                     |    payment      |
                     +---+-------------+
                     |PK | payment_id  |
                     |FK | customer_id |
                     |FK | staff_id    |
                     |FK | rental_id   |
                     +---+-------------+
```

```SQL
WITH RECURSIVE x (path_t, table_nm, parent, is_leaf, level) AS (
  -- Anchor Query (select the roots)
  SELECT  table_nm::VARCHAR(100) AS path_t
        , table_nm AS table_nm
        , parent AS parent
        , 0 AS is_leaf
        , 0 AS level
    FROM parent_child_db
   WHERE parent IS NULL
   UNION ALL
   --- Recursive Query
   SELECT (x.path_t || ' -> ' || t.table_nm)::VARCHAR(100)
         , t.table_nm
         , t.parent
         , CASE WHEN NOT EXISTS (SELECT NULL
                                   FROM parent_child_db pcdb
                                  WHERE pcdb.parent = t.table_nm)
                THEN 1 ELSE 0
           END AS is_leaf
         , x.level + 1 AS level
      FROM parent_child_db t, x
     WHERE t.parent = x.table_nm  AND level < 5
)
SELECT *
  FROM x;
```



```console
path_t                                            | table_nm|  parent | is_leaf | level
--------------------------------------------------+---------+---------+---------+-----
country -> city -> address -> customer -> rental -> payment | payment | rental | 1 |  5
country -> city -> address -> staff -> rental -> payment   | payment  | rental | 1 |  5
```

### Recursion 6

```console
        x
+-----------------+
|    payment      |
+---+-------------+
|PK | payment_id  |
|FK | customer_id |
|FK | staff_id    |
|FK | rental_id   |
+---+-------------+
```

```SQL
WITH RECURSIVE x (path_t, table_nm, parent, is_leaf, level) AS (
  -- Anchor Query (select the roots)
  SELECT  table_nm::VARCHAR(100) AS path_t
        , table_nm AS table_nm
        , parent AS parent
        , 0 AS is_leaf
        , 0 AS level
    FROM parent_child_db
   WHERE parent IS NULL
   UNION ALL
   --- Recursive Query
   SELECT (x.path_t || ' -> ' || t.table_nm)::VARCHAR(100)
         , t.table_nm
         , t.parent
         , CASE WHEN NOT EXISTS (SELECT NULL
                                   FROM parent_child_db pcdb
                                  WHERE pcdb.parent = t.table_nm)
                THEN 1 ELSE 0
           END AS is_leaf
         , x.level + 1 AS level
      FROM parent_child_db t, x
     WHERE t.parent = x.table_nm  AND level < 6
)
SELECT *
  FROM x;
```

No matching rows.

```console
path_t                                            | table_nm|  parent | is_leaf | level
--------------------------------------------------+---------+---------+---------+-----
0 rows
```

To return all the `roots` to `leaves` paths filter the query with a `WHERE` condition.

```SQL
WITH RECURSIVE x (path_t, table_nm, parent, is_leaf, level) AS (
  -- Anchor Query (select the roots)
  SELECT  table_nm::VARCHAR(100) AS path_t
        , table_nm AS table_nm
        , parent AS parent
        , 0 AS is_leaf
        , 0 AS level
    FROM parent_child_db
   WHERE parent IS NULL
   UNION ALL
   --- Recursive Query
   SELECT (x.path_t || ' -> ' || t.table_nm)::VARCHAR(100)
         , t.table_nm
         , t.parent
         , CASE WHEN NOT EXISTS (SELECT NULL
                                   FROM parent_child_db pcdb
                                  WHERE pcdb.parent = t.table_nm)
                THEN 1 ELSE 0
           END AS is_leaf
         , x.level + 1 AS level
      FROM parent_child_db t, x
     WHERE t.parent = x.table_nm  AND level < 6
)
SELECT path_t AS path_fk
  FROM x
 WHERE is_leaf = 1
 ORDER BY level, path_t;
```

```console
path_fk
-------------------------------------------------------------
actor -> film_actor
category -> film_category
language -> film -> film_actor
language -> film -> film_category
country -> city -> address -> store
country -> city -> address -> customer -> payment
country -> city -> address -> staff -> payment
country -> city -> address -> staff -> store
language -> film -> inventory -> rental -> payment
country -> city -> address -> customer -> rental -> payment
country -> city -> address -> staff -> rental -> payment
(11 rows)
```
