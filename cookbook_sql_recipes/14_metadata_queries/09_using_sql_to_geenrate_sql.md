# Using SQL to Generate SQL

You want to create `dynamic SQL statements`, perhaps **to automate maintenance tasks**.


# Problem

You want to accomplish the following task:

- **count the number of rows in your tables**,

The tables in the `dvdrental` sample database are listed below:

```console
dvdrental=# \dt
             List of relations
 Schema |     Name      | Type  |  Owner
--------+---------------+-------+----------
 public | actor         | table | postgres
 public | address       | table | postgres
 public | category      | table | postgres
 public | city          | table | postgres
 public | country       | table | postgres
 public | customer      | table | postgres
 public | film          | table | postgres
 public | film_actor    | table | postgres
 public | film_category | table | postgres
 public | inventory     | table | postgres
 public | language      | table | postgres
 public | payment       | table | postgres
 public | rental        | table | postgres
 public | staff         | table | postgres
 public | store         | table | postgres
(15 rows)
```

- **1**:

Generate the following script using SQL commands.

**cnt_rows.sql**

```SQL

SELECT  'actor :' || COUNT(*) AS cnt FROM actor UNION ALL       
SELECT  'address :' || COUNT(*) AS cnt FROM address UNION ALL      
SELECT  'category :' || COUNT(*) AS cnt FROM category UNION ALL     
SELECT  'city :' || COUNT(*) AS cnt FROM city UNION ALL         
SELECT  'country :' || COUNT(*) AS cnt FROM country UNION ALL      
SELECT  'customer :' || COUNT(*) AS cnt FROM customer UNION ALL     
SELECT  'film :' || COUNT(*) AS cnt FROM film UNION ALL         
SELECT  'film_actor :' || COUNT(*) AS cnt FROM film_actor UNION ALL   
SELECT  'film_category :' || COUNT(*) AS cnt FROM film_category UNION ALL
SELECT  'inventory :' || COUNT(*) AS cnt FROM inventory UNION ALL    
SELECT  'language :' || COUNT(*) AS cnt FROM language UNION ALL     
SELECT  'payment :' || COUNT(*) AS cnt FROM payment UNION ALL      
SELECT  'rental :' || COUNT(*) AS cnt FROM rental UNION ALL       
SELECT  'staff :' || COUNT(*) AS cnt FROM staff UNION ALL        
SELECT  'store :' || COUNT(*) AS cnt FROM store;        
```

The execution of the script should returns:

```console
cnt
---------------------
actor :200
address :603
category :16
city :600
country :109
customer :599
film :1000
film_actor :5462
film_category :1000
inventory :4581
language :6
payment :14596
rental :16044
staff :2
store :2
(15 rows)
```

# Solution

The concept is to use strings to build SQL statements, and the values that need to be filled in (such as the object name the command acts upon) will be supplied by data from the tables you are selecting from. Keep in mind, the queries only generate the statements; you must then run these statements via script, manually, or however you execute your SQL statements.

```SQL
CREATE VIEW my_query AS (
  WITH x AS (
    SELECT table_name, 1 AS rw
      FROM INFORMATION_SCHEMA.TABLES
     WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
  ),
  my_tables AS (
    SELECT  table_name
          , SUM(rw) OVER (ORDER BY table_name) AS rw
      FROM x
  )
  SELECT 'SELECT ' || '''' || table_name || ''' :' || ' || COUNT(*) FROM ' || table_name || ' UNION ALL' AS query
       , rw
   FROM my_tables
);

SELECT STRING_AGG(query,E'\n' ORDER BY rw) || ';' AS query
  FROM my_query;
```

Lastly export the query to a sql script:

```console
dvdrental=# COPY (SELECT STRING_AGG(query,E'\n' ORDER BY rw) || ';' AS query
  FROM my_query) TO 'your_path/cnt_rows.sql' DELIMITER ',' CSV;
```

## Discussion

```SQL
SELECT table_name
  FROM INFORMATION_SCHEMA.TABLES
 WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
 ORDER BY 1;
```
The first step is to access the tables' name in the `dvdrental` sample database.

```console
table_name
---------------
actor
address
category
city
country
customer
film
film_actor
film_category
inventory
language
payment
rental
staff
store
(15 rows)
```

```SQL
SELECT 'test line 1'||E'\n'||'test line 2'|| chr(10) || 'line 3' AS test_carrige_return;
SELECT 'O''Brian' AS test_quote;
```

```console
dvdrental=# SELECT 'test line 1'||E'\n'||'test line 2'|| chr(10) || 'line 3' AS test_carrige_return;
 test_carrige_return
---------------------
 test line 1        +
 test line 2        +
 line 3
(1 row)

dvdrental=# SELECT 'O''Brian' AS test_quote;
 test_quote
------------
 O'Brian
(1 row)
```

Next prepare the input table for a recursive query to generate the long string script.

```SQL
CREATE VIEW my_tables AS (
  WITH x AS (
    SELECT table_name, 1 AS rw
      FROM INFORMATION_SCHEMA.TABLES
     WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
  )
  SELECT  table_name
        , SUM(rw) OVER (ORDER BY table_name) AS rw
        , COUNT(*) OVER () AS max
    FROM x
);

SELECT *
  FROM my_tables;
```

```console
table_name    | rw | max
--------------+----+-----
actor         |  1 |  15
address       |  2 |  15
category      |  3 |  15
city          |  4 |  15
country       |  5 |  15
customer      |  6 |  15
film          |  7 |  15
film_actor    |  8 |  15
film_category |  9 |  15
inventory     | 10 |  15
language      | 11 |  15
payment       | 12 |  15
rental        | 13 |  15
staff         | 14 |  15
store         | 15 |  15
(15 rows)
```

```SQL
CREATE VIEW my_query AS (
  WITH x AS (
    SELECT table_name, 1 AS rw
      FROM INFORMATION_SCHEMA.TABLES
     WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
  ),
  my_tables AS (
    SELECT  table_name
          , SUM(rw) OVER (ORDER BY table_name) AS rw
          , COUNT(*) OVER () AS max
      FROM x
  )
  SELECT 'SELECT ' || '''' || table_name || ':' || ''''  || ' || COUNT(*) AS cnt FROM ' || table_name ||  CASE WHEN rw = max
           THEN ';'
           ELSE ' UNION ALL'
      END AS query
       , rw
   FROM my_tables
);

SELECT *
  FROM my_query;
```

```console
query                                  | rw
-------------------------------------------------------------------------+----
SELECT 'actor:' || COUNT(*) AS cnt FROM actor UNION ALL                 |  1
SELECT 'address:' || COUNT(*) AS cnt FROM address UNION ALL             |  2
SELECT 'category:' || COUNT(*) AS cnt FROM category UNION ALL           |  3
SELECT 'city:' || COUNT(*) AS cnt FROM city UNION ALL                   |  4
SELECT 'country:' || COUNT(*) AS cnt FROM country UNION ALL             |  5
SELECT 'customer:' || COUNT(*) AS cnt FROM customer UNION ALL           |  6
SELECT 'film:' || COUNT(*) AS cnt FROM film UNION ALL                   |  7
SELECT 'film_actor:' || COUNT(*) AS cnt FROM film_actor UNION ALL       |  8
SELECT 'film_category:' || COUNT(*) AS cnt FROM film_category UNION ALL |  9
SELECT 'inventory:' || COUNT(*) AS cnt FROM inventory UNION ALL         | 10
SELECT 'language:' || COUNT(*) AS cnt FROM language UNION ALL           | 11
SELECT 'payment:' || COUNT(*) AS cnt FROM payment UNION ALL             | 12
SELECT 'rental:' || COUNT(*) AS cnt FROM rental UNION ALL               | 13
SELECT 'staff:' || COUNT(*) AS cnt FROM staff UNION ALL                 | 14
SELECT 'store:' || COUNT(*) AS cnt FROM store;                          | 15
(15 rows)
```

Use the `STRING_AGG` function of PostgreSql.

```SQL
SELECT STRING_AGG(query,E'\n' ORDER BY rw) AS query
  FROM my_query;
```

```console
query
-------------------------------------------------------------------------
SELECT 'actor:' || COUNT(*) AS cnt FROM actor UNION ALL                +
SELECT 'address:' || COUNT(*) AS cnt FROM address UNION ALL            +
SELECT 'category:' || COUNT(*) AS cnt FROM category UNION ALL          +
SELECT 'city:' || COUNT(*) AS cnt FROM city UNION ALL                  +
SELECT 'country:' || COUNT(*) AS cnt FROM country UNION ALL            +
SELECT 'customer:' || COUNT(*) AS cnt FROM customer UNION ALL          +
SELECT 'film:' || COUNT(*) AS cnt FROM film UNION ALL                  +
SELECT 'film_actor:' || COUNT(*) AS cnt FROM film_actor UNION ALL      +
SELECT 'film_category:' || COUNT(*) AS cnt FROM film_category UNION ALL+
SELECT 'inventory:' || COUNT(*) AS cnt FROM inventory UNION ALL        +
SELECT 'language:' || COUNT(*) AS cnt FROM language UNION ALL          +
SELECT 'payment:' || COUNT(*) AS cnt FROM payment UNION ALL            +
SELECT 'rental:' || COUNT(*) AS cnt FROM rental UNION ALL              +
SELECT 'staff:' || COUNT(*) AS cnt FROM staff UNION ALL                +
SELECT 'store:' || COUNT(*) AS cnt FROM store;
(1 row)
```

Let's drop the view `DROP VIEW my_query;` and create a new one with the last aggregation query.

```SQL
CREATE VIEW my_query AS (
  WITH x AS (
    SELECT table_name, 1 AS rw
      FROM INFORMATION_SCHEMA.TABLES
     WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
  ),
  my_tables AS (
    SELECT  table_name
          , SUM(rw) OVER (ORDER BY table_name) AS rw
          , COUNT(*) OVER () AS max
      FROM x
  ),
  my_rows AS (
    SELECT 'SELECT ' || '''' || table_name || ':' || ''''  || ' || COUNT(*) AS cnt FROM ' || table_name ||  CASE WHEN rw = max
             THEN ';'
             ELSE ' UNION ALL'
        END AS query
         , rw
     FROM my_tables
  )
  SELECT STRING_AGG(query,E'\n' ORDER BY rw) AS query
    FROM my_rows
);

SELECT query
  FROM my_query;
```


Next export the query with the `COPY` command.

If you don’t want to export the header, which contains the column names of the table, just remove the HEADER flag in the `COPY` statement. Specifies the quoting character, `QUOTE`, to be used when a data value is quoted. The default is double-quote, `"yor string "`. This must be a single one-byte character. This option is allowed only when using `CSV` format. In this case we want to remove the double quotes enclosing the string in the column, (i.e our long query statement). so the option is `QUOTE ' '`.

- `COPY (`**sql query** `) TO` `'`**your_path/cnt_rows.sql**`' DELIMITER '`**,**`' QUOTE ' ' CSV`;

I just remind you to write the **sql query** without the semicolon in the enclosing parentheses.


```console
dvdrental=# COPY (SELECT query FROM my_query) TO 'your_path/cnt_rows.sql' DELIMITER ',' QUOTE ' ' CSV;
COPY 1
```

Now if your file is in the current working directory:

```console
$  ls cnt_rows.sql
cnt_rows.sql
```

You can open the file using the `cat` command in the shell to the view the content of the file.

```console
$  cat cnt_rows.sql
 SELECT  'actor:'  ||  COUNT(*)  AS  cnt  FROM  actor  UNION  ALL
SELECT  'address:'  ||  COUNT(*)  AS  cnt  FROM  address  UNION  ALL
SELECT  'category:'  ||  COUNT(*)  AS  cnt  FROM  category  UNION  ALL
SELECT  'city:'  ||  COUNT(*)  AS  cnt  FROM  city  UNION  ALL
SELECT  'country:'  ||  COUNT(*)  AS  cnt  FROM  country  UNION  ALL
SELECT  'customer:'  ||  COUNT(*)  AS  cnt  FROM  customer  UNION  ALL
SELECT  'film:'  ||  COUNT(*)  AS  cnt  FROM  film  UNION  ALL
SELECT  'film_actor:'  ||  COUNT(*)  AS  cnt  FROM  film_actor  UNION  ALL
SELECT  'film_category:'  ||  COUNT(*)  AS  cnt  FROM  film_category  UNION  ALL
SELECT  'inventory:'  ||  COUNT(*)  AS  cnt  FROM  inventory  UNION  ALL
SELECT  'language:'  ||  COUNT(*)  AS  cnt  FROM  language  UNION  ALL
SELECT  'payment:'  ||  COUNT(*)  AS  cnt  FROM  payment  UNION  ALL
SELECT  'rental:'  ||  COUNT(*)  AS  cnt  FROM  rental  UNION  ALL
SELECT  'staff:'  ||  COUNT(*)  AS  cnt  FROM  staff  UNION  ALL
SELECT  'store:'  ||  COUNT(*)  AS  cnt  FROM  store;
```

Lastly, you can connect to the `dvdrental` database using the `psql` command.

```console
$  psql dvdrental
psql (11.4)
Type "help" for help.

dvdrental=#
```

Finally, execute the external file. Your file must be located in the current working directory. If you want to execute the file from a different directory you must use the `\ir` command to specify the absolute path.

```console
dvdrental=# \i cnt_rows.sql
        cnt
--------------------
 actor:200
 address:603
 category:16
 city:600
 country:109
 customer:599
 film:1000
 film_actor:5462
 film_category:1000
 inventory:4581
 language:6
 payment:14596
 rental:16044
 staff:2
 store:2
(15 rows)
```

## Further exercises

```SQL
/* disable foreign keys from all tables */
select 'alter table '||table_name||
       ' disable constraint '||constraint_name||';' cons
  from user_constraints
 where constraint_type = 'R';
```

```console
CONS
------------------------------------------------
alter table ANT disable constraint ANT_FK;
alter table BONUS disable constraint BONUS_FK;
alter table DEMO1 disable constraint DEMO1_FK;
alter table DEMO2 disable constraint DEMO2_FK;
alter table DEPT disable constraint DEPT_FK;
alter table DUMMY disable constraint DUMMY_FK;
alter table EMP disable constraint EMP_FK;
alter table EMP_SALES disable constraint EMP_SALES_FK;
alter table EMP_SCORE disable constraint EMP_SCORE_FK;
alter table PROFESSOR disable constraint PROFESSOR_FK;
```
