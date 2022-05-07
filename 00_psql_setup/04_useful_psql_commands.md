# Useful psql Commands

You’ve installed PostgreSQL. Now what? I assume you’ve been given a task that uses psql and you want to learn the absolute minimum to get the job done.

This is both a brief tutorial and a quick reference for the absolute least you need to know about psql. I assume you’re familiar with the command line and have a rough idea about what database administration tasks, but aren’t familiar with how to use psql to do the basics.

The PostgreSQL [documentation](https://www.postgresql.org/docs/manuals/) is incredibly well written and thorough, but frankly, I didn’t know where to start reading. This is my answer to that problem.

Many administrative tasks can or should be done on your local machine, even though if database lives on the cloud. You can do some of them through a visual user interface, but that’s not covered here. Knowing how to perform these operations on the command line means you can script them, and scripting means you can automate tests, check errors, and do data entry on the command line.

This section isn’t a full cheat sheet for psql. It covers the most common operations and shows them roughly in sequence, as you’d use them in a typical work session.

- [1. Starting and quitting the psql interactive terminal](#1-starting-and-quitting-the-pasql-interactive-terminal)
  - [1.1 Command-line prompts on the operating system](#11-command-line-prompts-on-the-operating-system)
  - [1.2 Using psql](#12-using-psql)
  - [1.3 Quitting psql](#13-quitting-psql)
  - [1.4 Opening a connection locally](#14-opening-a-connection-locally)
  - [1.5 Opening a connection remotely](#15-opening-a-connection-remotely)
  - [1.6 Looking at the psql prompt](#16-looking-at-the-psql-prompt)
  - [1.7 \? Get help on psql commands](#17-get-help-on-psql-commands)
  - [1.8 Connection information](#18-connection-information)
  - [1.9 List users](#19-list-users)
  - [1.10 Changing User connection](#110-changing-user-connection)
- [2. Getting information about databases](#2-getting-information-about-databases)
  - [2.1 \h Get help on PostgreSQL commands](#21-get-help-on-postgresql-commands)
  - [2.2 \g Execute previous command](#22-execute-previous-command)
  - [2.3 Command history](#23-command-history)
  - [2.4 \l List databases](#23-list-databases)
  - [2.5 \x Expand/narrow table lists](#25-expand/narrow-table-lists)
  - [2.6 Changing Database and User connection](#26-changing-database-and-user-connection)
  - [2.7 \dt Display tables](#27-display-tables)
  - [2.8 \d Display columns of a table and size](#28-display-columns-of-a-table-and-size)
  - [2.9 \di Display indexes](#29-display-indexes)
  - [2.10 \df Display functions](#210-display-functions)
  - [2.11 \sf Show function definition](#211-show-function-definition)
  - [2.12 \dv Display views](#212-display-views)
  - [2.13 \sv Show view definition](#213-s-show-view-definition)
- [3. Maintenance and operations issues](#3-maintenance-and-operations-issues)
  - [3.1 Timing](#31-timing)
  - [3.2 Watch](#32-watch)
  - [3.3 Locate the pg_hba.conf file](#33-locate-the-pg_hba.conf-file)

## 1. Starting and quitting the psql interactive terminal

Before using this section, you’ll need:

- The user name and password for your PostgreSQL database
- The IP address of your remote instance

### 1.1 Command line prompts on the operating system

The `$` starting a command line in the examples below represents your operating system prompt. Prompts are configurable so it may well not look like this. On Windows it might look like `C:\Program Files\PostgreSQL>` but Windows prompts are also configurable.

```console
$ psql -U sampleuser -h localhost
```

By default the `-h` option value is `localhost`. If your connection is on your local computer you can omit the `-h` option.

A line starting with # represents a comment. Same for everything to the right of a #. If you accidentally type it or copy and paste it in, don’t worry. Nothing will happen.

```console
# This worked to connect to Postgres on DigitalOcean
# -U is the username (it will appear in the \l command)
# -h is the name of the machine where the server is running.
# -p is the port where the database listens to connections. Default is 5432.
# -d is the name of the database to connect to. I think DO generated this for me, or maybe PostgreSQL.
# Password when asked is csizllepewdypieiib
$ psql -U doadmin -h production-sfo-test1-do-user-4866002-0.db.ondigitalocean.com -p 25060 -d mydb

# Open a database in a remote location.
$ psql -U sampleuser -h production-sfo-test1-do-user-4866002-0.db.ondigitalocean.com -p 21334
```

### 1.2 Using psql

You’ll use psql (aka the [PostgreSQL interactive terminal](https://www.postgresql.org/docs/current/app-psql.html)) most of all because it’s used to create databases and tables, show information about tables, and even to enter information (records) into the database.

### 1.3 Quitting psql

Before we learn anything else, here’s how to quit psql and return to the operating system prompt. You type backslash, the letter q, and then you press the Enter or return key.

```console
# Press enter after typing \q
# Remember this is backslash, not forward slash
postgres=# \q
This takes you back out to the operating system prompt.
```

### 1.4 Opening a connection locally

A common case during development is opening a connection to a local database (one on your own machine). Run psql with -U (for user name) followed by the name of the database, postgres in this example:

```console
# Log into Postgres using the default database (see lesson 03) as the user named postgres
$ psql -U postgres
```
### 1.5 Opening a connection remotely

To connect your remote PostgreSQL instance from your local machine, use psql at your operating system command line. Here’s a typical connection.

```console
# -U is the username (it will appear in the \l command)
# -h is the name of the machine where the server is running.
# -p is the port where the database listens to connections. Default is 5432.
# -d is the name of the database to connect to. I think DO generated this for me, or maybe PostgreSQL.
$ psql -U doadmin -h production-sfo-test1-do-user-4866002-0.db.ondigitalocean.com -p 25060 -d defaultdb
```
Here you’d enter the password. In case someone is peering over your shoulder :smile:, the characters are hidden. After you’ve entered your information properly you’ll get this message (truncated for clarity):

### 1.6 Looking at the psql prompt

A few things appear, then the psql prompt is displayed. The name of the current database appears before the prompt.

```console
psql (12.1, server 12.0)
Type "help" for help.

postgres=#
```
At this point you’re expected to type commands and parameters into the command line.

**psql vs SQL commands**

`psql` has two different kinds of commands. Those starting with a backslash are for psql itself, as illustrated by the use of `\q` to quit.

Those starting with valid SQL are of course interactive SQL used to create and modify PostgreSQL databases.

**Warning: SQL commands end with a semicolon!**

One gotcha is that almost all SQL commands you enter into `psql` must end in a semicolon.

- For example, suppose you want to remove a table named `sample_property_5`. You’d enter this command:

```console
postgres=# DROP TABLE sample_property_5;
```

It’s easy to forget. If you do forget the semicolon, you’ll see this perplexing prompt. Note that a `[` has been inserted before the username portion of the prompt, and another prompt appears below it:

```console
postgres=# DROP TABLE sample_property_5
postgres=#
```

When you do, just remember to finish it off with that semicolon:

```console
postgres=# DROP TABLE sample_property_5
postgres=# ;
```

If you get stuck and the prompt is not responding to the semicolon than use the command `^D` to exit the `psql` prompt and log in again.

```console
postgres=# DROP TABLE `sample_property_5
postgres=#;
postgres=#^D/q
$ 
```

**Scrolling through the command history**

Use the up and down arrow keys to move backwards and forwards through the command history.

### 1.7  Get help on psql commands

To know all available psql commands (`the backslash commands`), you use the `\?` command.

```console
# Get help. Note it's a backslash, not a forward slash.
postgres=# \?
```

You’ll get a long list of commands, then output is paused:

```console
...
Help
  \? [commands]          show help on backslash commands
  \? options             show help on psql command-line options
  \? variables           show help on special variables
  \h [NAME]              help on syntax of SQL commands, * for all commands
:
```

- Press `space` to continue, or `q` to stop the output.

### 1.8 Connection information

**display information of the current connection**: `\conninfo`

```console
postgres=# \conninfo
You are connected to database "postgres" as user "ludovicopinzari" via socket in "/tmp" at port "5432".
```

We see that our current user is "ludovicopinzari" and is connected to the database "postgres".

### 1.9 List users

**list all users**: `\du`

```console
postgres=# \du
                                      List of roles
    Role name    |                         Attributes                         | Member of
-----------------+------------------------------------------------------------+-----------
 ludovicopinzari | Superuser, Create role, Create DB                          | {}
 postgres        | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
```

We see the `postgres` user , but what is that other user, `ludovicopinzari`? This is one of the things Postgres does to make your life easier when you first install it.

On most Linux-based operating systems, the username that is used by default by all processes is the one you are logged in as. You don’t have to pass your username to most programs. But if a particular program, like Postgres, doesn’t have your username configured—it will fail!

So **when Postgres is installed, it automatically creates a database** user that matches your username, in this case a database `ludovicopinzari` and the username you are logged in the system `ludovicopinzari` so that you can get started right away. It also creates a `postgres` user and a database `postgres`.

### 1.10 Changing User connection

```console
postgres=# \conninfo
You are connected to database "postgres" as user "ludovicopinzari" via socket in "/tmp" at port "5432".
```

We see that our current user is "ludovicopinzari" and is connected to the database "postgres".

**changing user with the current database**: `\c - userName`

```console
postgres=# \c - postgres
You are now connected to database "postgres" as user "postgres".
```
The `-` is substitute for current database.

We see that our current user is "postgres" and is connected to the database "postgres".

## 2. Getting information about databases

These aren’t SQL commands so just press Enter after them. Remember that:
- When there’s more output than fits the screen, it pauses. Press `space` to continue
If you want to halt the output, press `q`.

### 2.1 Get help on PostgreSQL commands

To get help on specific PostgreSQL statement you use `\h`:

```console
# Get help. Note it's a backslash, not a forward slash.
postgres=# \h
```

You’ll get a long list of commands, then output is paused:

```console
Available help:
  ABORT                            CREATE USER
  ...
  ALTER AGGREGATE                  CREATE USER MAPPING
  ALTER PROCEDURE                  DROP INDEX
:
```

- Press `space` to continue, or `q` to stop the output.

You can get help on a particular item by listing it after the `\h` command.

- For example, to get help on `DROP TABLE`:

```console
postgres=# \h drop table
```

You’ll get help on just that item:

```console
Command:     DROP TABLE
Description: remove a table
Syntax:
DROP TABLE [ IF EXISTS ] name [, ...] [ CASCADE | RESTRICT ]
```

### 2.2 Execute previous command

To retrieve the current version of PostgreSQL server, you use the version() function as follows:

```console
uniy=# SELECT version();
```

Now, you want to save time typing the previous command again, you can use \g command to execute the previous command:

```console
uniy=# \g
```

psql executes the previous command again, which is the SELECT statement,.

### 2.3 Command history

To display command history, you use the `\s` command.

```console
uniy=# \s
\q
\s
```

As you can see the output shows all the commands executed in the `psql` prompt. These commands are saved to a file named `.psql_history` located in the home directory `~`.

```console
(base) ludo /~  $  ls .psql_history
.psql_history
```

Whenever we start a session in PostgreSQL and execute new commands, new lines will be added to this file. You can see the content of the file using the `cat` command.

```console
(base) ludo /~  $ cat .psql_history
_HiStOrY_V2_
\134q
\134s
```

To clear the commands or part of the commands you can edit the file. It's important to leave the first line in the file `_HiStOrY_V2_`. Let's see what happen if we execute another command in the `psql` prompt:

```console
uniy=# \conninfo
You are connected to database "uniy" as user "ludovicopinzari" via socket in "/tmp" at port "5432".
```
Now, let's execute the `\s` command again:

```console
uniy=# \s
\q
\s
\conninfo
\s
```

We see that the last two commands `\conninfo` and `\s` have been added to the `.psql_history` file.

If you want to save the command history to a file, you need to specify the file name followed the \s command as follows:

```console
\s my_session_file
```

### 2.4 List databases

What most people think of as a database (say, a list of customers) is actually a table. A database is a set of tables, information about those tables, information about users and their permissions, and much more. Some of these databases (and the tables within) are updated automatically by PostgreSQL as you use them.

To get a list of all databases:

```console
uniy=# \l
                                                  List of databases
                Name                 |      Owner      | Encoding |   Collate   |    Ctype    |   Access privileges
-------------------------------------+-----------------+----------+-------------+-------------+-----------------------
 dvdrental                           | postgres        | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 hr                                  | usertest        | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =Tc/usertest         +
                                     |                 |          |             |             | usertest=CTc/usertest
 ludovicopinzari                     | ludovicopinzari | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 parch_posey                         | usertest        | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =Tc/usertest         +
                                     |                 |          |             |             | usertest=CTc/usertest
 postgres                            | postgres        | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 template0                           | postgres        | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
                                     |                 |          |             |             | postgres=CTc/postgres
 template1                           | postgres        | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
                                     |                 |          |             |             | postgres=CTc/postgres
 uniy                                | usertest        | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =Tc/usertest         +
                                     |                 |          |             |             | usertest=CTc/usertest
```

You can get info on a single database by following the `\l` prompt with its name.

- For example, to view information about the `template0` database:

```console
postgres=# \l template0
```
The output would be:

```console
postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
```

```console
postgres=# \list
...
ludovicopinzari
postgres
```
You will see the two default databases.

**\l+ List databases with size, tablespace, and description**

To get additional information on the space consumed by database tables and comments describing those tables, use \l+:

```console
postgres=# \l+
```

**Output**
```console
Name                 |      Owner      | Encoding |   Collate   |    Ctype    |   Access privileges   |  Size   | Tablespace |                Description
-------------------------------------+-----------------+----------+-------------+-------------+-----------------------+---------+------------+--------------------------------------------
dvdrental                           | postgres        | UTF8     | en_US.UTF-8 | en_US.UTF-8 |                       | 15 MB   | pg_default |
hr                                  | usertest        | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =Tc/usertest         +| 8213 kB | pg_default |
                     |                 |          |             |             | usertest=CTc/usertest |         |            |
ludovicopinzari                     | ludovicopinzari | UTF8     | en_US.UTF-8 | en_US.UTF-8 |                       | 7797 kB | pg_default |
parch_posey                         | usertest        | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =Tc/usertest         +| 9589 kB | pg_default |
                     |                 |          |             |             | usertest=CTc/usertest |         |            |
postgres                            | postgres        | UTF8     | en_US.UTF-8 | en_US.UTF-8 |                       | 7805 kB | pg_default | default administrative connection database
template0                           | postgres        | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +| 7797 kB | pg_default | unmodifiable empty database
                     |                 |          |             |             | postgres=CTc/postgres |         |            |
template1                           | postgres        | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +| 7657 kB | pg_default | default template for new databases
uniy                                | usertest        | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =Tc/usertest         +| 8469 kB | pg_default |
                     |                 |          |             |             | usertest=CTc/usertest |         |            |
```

We see that the wide format output it's not easy to read. We can use the `\x` command to list the rows in a more readable format. See next section.

### 2.5 Expand/narrow table lists

Use `\x` (X for eXpanded listing) to control whether table listings use a wide or narrow format.

|Command|	Effect|
|:-----:|:-----:|
|\x off |	Show table listings in wide format|
|\x on |	Show table listings in narrow format|
|\x |	Reverse the previous state|
|\x auto|	Use terminal to determine format|

```console
postgres=# \x on
Expanded display is on.
```

Let's execute the `l+` command.

```console
postgres=# \l+
List of databases
-[ RECORD 1 ]-----+-------------------------------------------
Name              | dvdrental
Owner             | postgres
Encoding          | UTF8
Collate           | en_US.UTF-8
Ctype             | en_US.UTF-8
Access privileges |
Size              | 15 MB
Tablespace        | pg_default
Description       |
-[ RECORD 2 ]-----+-------------------------------------------
Name              | hr
Owner             | usertest
Encoding          | UTF8
Collate           | en_US.UTF-8
Ctype             | en_US.UTF-8
Access privileges | =Tc/usertest                              +
                  | usertest=CTc/usertest
Size              | 8213 kB
Tablespace        | pg_default
Description       |
-[ RECORD 3 ]-----+-------------------------------------------
Name              | ludovicopinzari
Owner             | ludovicopinzari
Encoding          | UTF8
Collate           | en_US.UTF-8
Ctype             | en_US.UTF-8
Access privileges |
Size              | 7797 kB
Tablespace        | pg_default
Description       |
-[ RECORD 4 ]----+-------------------------------------------
Name              | parch_posey
Owner             | usertest
Encoding          | UTF8
Collate           | en_US.UTF-8
Ctype             | en_US.UTF-8
Access privileges | =Tc/usertest                              +
                  | usertest=CTc/usertest
Size              | 9589 kB
Tablespace        | pg_default
Description       |
...
-[ RECORD 8 ]----+-------------------------------------------
Name              | uniy
Owner             | usertest
Encoding          | UTF8
Collate           | en_US.UTF-8
Ctype             | en_US.UTF-8
Access privileges | =Tc/usertest                              +
                  | usertest=CTc/usertest
Size              | 8469 kB
Tablespace        | pg_default
Description       |
```

To disable the narrow format and return to the wide format:

```console
postgres=# \x off
Expanded display is off.
```

### 2.6 Changing Database and User connection

```console
postgres=# \conninfo
You are connected to database "postgres" as user "ludovicopinzari" via socket in "/tmp" at port "5432".
```

We see that our current user is "ludovicopinzari" and is connected to the database "postgres".

To see what’s inside a database, connect to it using `\c` followed by the database name. The prompt changes to match the name of the database you’re connecting to. (The one named postgres isn't always interesting.) Here we’re connecting to the one named `uniy`, this database is created in lesson [10 create uniy db](./10_create_uniy_db.md):

**changing database with the current user**: `\c databaseName`

```console
postgres=# \c uniy
You are now connected to database "uniy" as user "ludovicopinzari".
uniy=#
```

- **Changing Database and User connection**

**changing database and user**: `\c databaseName userName`
```console
ludovicopinzari=# \c postgres ludovicopinzari
You are now connected to database "postgres" as user "ludovicopinzari".
postgres=#
```
### 2.7 Display tables

```console
postgres=# \c dvdrental
You are now connected to database "dvdrental" as user "ludovicopinzari".
```

Use `\dt` to list all the tables (technically, relations) in the database:

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
If you choose a database such as `postgres` there could be many tables. Remember you can pause output by pressing `space` or halt it by pressing `q`.

### 2.8 Display columns of a table and size
To view the schema of a table, use \d followed by the name of the table.

To view the schema of a table named `city` in the `dvdrental` database, enter:

- `\d city`:

```console
dvdrental=# \d city
                                           Table "public.city"
   Column    |            Type             | Collation | Nullable |                Default
-------------+-----------------------------+-----------+----------+---------------------------------------
 city_id     | integer                     |           | not null | nextval('city_city_id_seq'::regclass)
 city        | character varying(50)       |           | not null |
 country_id  | smallint                    |           | not null |
 last_update | timestamp without time zone |           | not null | now()
Indexes:
    "city_pkey" PRIMARY KEY, btree (city_id)
    "idx_fk_country_id" btree (country_id)
Foreign-key constraints:
    "fk_city" FOREIGN KEY (country_id) REFERENCES country(country_id)
Referenced by:
    TABLE "address" CONSTRAINT "fk_address_city" FOREIGN KEY (city_id) REFERENCES city(city_id)
Triggers:
    last_updated BEFORE UPDATE ON city FOR EACH ROW EXECUTE PROCEDURE last_updated()
```

To view more detailed information on a table, use \d+:

- `\d+ city`:

```console
dvdrental=# \d+ city
                                                               Table "public.city"
   Column    |            Type             | Collation | Nullable |                Default                | Storage  | Stats target | Description
-------------+-----------------------------+-----------+----------+---------------------------------------+----------+--------------+-------------
 city_id     | integer                     |           | not null | nextval('city_city_id_seq'::regclass) | plain    |              |
 city        | character varying(50)       |           | not null |                                       | extended |              |
 country_id  | smallint                    |           | not null |                                       | plain    |              |
 last_update | timestamp without time zone |           | not null | now()                                 | plain    |              |
Indexes:
    "city_pkey" PRIMARY KEY, btree (city_id)
    "idx_fk_country_id" btree (country_id)
Foreign-key constraints:
    "fk_city" FOREIGN KEY (country_id) REFERENCES country(country_id)
Referenced by:
    TABLE "address" CONSTRAINT "fk_address_city" FOREIGN KEY (city_id) REFERENCES city(city_id)
Triggers:
    last_updated BEFORE UPDATE ON city FOR EACH ROW EXECUTE PROCEDURE last_updated()
```

**To get information of the table's memory size**

```console
dvdrental=# SELECT pg_size_pretty(pg_total_relation_size('city'));
 pg_size_pretty
----------------
 128 kB
(1 row)
```

**To get a summary of the table's column memory size**

```console
dvdrental=# SELECT  COUNT(*) AS total_rows,
dvdrental-#         pg_size_pretty(SUM(pg_column_size(city))) AS total_size,
dvdrental-#         pg_size_pretty(AVG(pg_column_size(city))) AS average_size,
dvdrental-#         SUM(pg_column_size(city)) * 100.0 / pg_total_relation_size('city') AS percentage
dvdrental-#   FROM  city;
 total_rows | total_size |       average_size       |     percentage
------------+------------+--------------------------+--------------------
        600 | 5618 bytes | 9.3633333333333333 bytes | 4.2861938476562500
(1 row)
```

### 2.9 Display indexes

Use `\di` to list all the indexes in the database:

```console
dvdrental=# \di
                                        List of relations
 Schema |                        Name                         | Type  |  Owner   |     Table
--------+-----------------------------------------------------+-------+----------+---------------
 public | actor_pkey                                          | index | postgres | actor
 public | address_pkey                                        | index | postgres | address
 public | category_pkey                                       | index | postgres | category
 public | city_pkey                                           | index | postgres | city
 public | country_pkey                                        | index | postgres | country
 public | customer_pkey                                       | index | postgres | customer
 public | film_actor_pkey                                     | index | postgres | film_actor
 public | film_category_pkey                                  | index | postgres | film_category
 public | film_fulltext_idx                                   | index | postgres | film
 public | film_pkey                                           | index | postgres | film
 public | idx_actor_last_name                                 | index | postgres | actor
 public | idx_fk_address_id                                   | index | postgres | customer
 public | idx_fk_city_id                                      | index | postgres | address
 public | idx_fk_country_id                                   | index | postgres | city
 public | idx_fk_customer_id                                  | index | postgres | payment
 public | idx_fk_film_id                                      | index | postgres | film_actor
 public | idx_fk_inventory_id                                 | index | postgres | rental
 public | idx_fk_language_id                                  | index | postgres | film
 public | idx_fk_rental_id                                    | index | postgres | payment
 public | idx_fk_staff_id                                     | index | postgres | payment
 public | idx_fk_store_id                                     | index | postgres | customer
 public | idx_last_name                                       | index | postgres | customer
 public | idx_store_id_film_id                                | index | postgres | inventory
 public | idx_title                                           | index | postgres | film
 public | idx_unq_manager_staff_id                            | index | postgres | store
 public | idx_unq_rental_rental_date_inventory_id_customer_id | index | postgres | rental
 public | inventory_pkey                                      | index | postgres | inventory
 public | language_pkey                                       | index | postgres | language
 public | payment_pkey                                        | index | postgres | payment
 public | rental_pkey                                         | index | postgres | rental
 public | staff_pkey                                          | index | postgres | staff
 public | store_pkey                                          | index | postgres | store
(32 rows)
```

### 2.10 Display functions


Use `\df` to list all functions in the database:

```console
dvdrental=# \df
                                                          List of functions
 Schema |            Name            | Result data type |                         Argument data types                         | Type
--------+----------------------------+------------------+---------------------------------------------------------------------+------
 public | _group_concat              | text             | text, text                                                          | func
 public | film_in_stock              | SETOF integer    | p_film_id integer, p_store_id integer, OUT p_film_count integer     | func
 public | film_not_in_stock          | SETOF integer    | p_film_id integer, p_store_id integer, OUT p_film_count integer     | func
 public | get_customer_balance       | numeric          | p_customer_id integer, p_effective_date timestamp without time zone | func
 public | group_concat               | text             | text                                                                | agg
 public | inventory_held_by_customer | integer          | p_inventory_id integer                                              | func
 public | inventory_in_stock         | boolean          | p_inventory_id integer                                              | func
 public | last_day                   | date             | timestamp without time zone                                         | func
 public | last_updated               | trigger          |                                                                     | func
 public | rewards_report             | SETOF customer   | min_monthly_purchases integer, min_dollar_amount_purchased numeric  | func
(10 rows)
```

### 2.11 Show function definition

To show the actual definition of a function, use the `\sf` command. For example, to show the view definition of `last_day` in the `dvdrental` database you could type:

- `\sf last_day`:

```console
dvdrental=# \sf last_day
CREATE OR REPLACE FUNCTION public.last_day(timestamp without time zone)
 RETURNS date
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
  SELECT CASE
    WHEN EXTRACT(MONTH FROM $1) = 12 THEN
      (((EXTRACT(YEAR FROM $1) + 1) operator(pg_catalog.||) '-01-01')::date - INTERVAL '1 day')::date
    ELSE
      ((EXTRACT(YEAR FROM $1) operator(pg_catalog.||) '-' operator(pg_catalog.||) (EXTRACT(MONTH FROM $1) + 1) operator(pg_catalog.||) '-01')::date - INTERVAL '1 day')::date
    END
$function$
```

### 2.12 Display views


Use `\dv` to list all views in the database:

```console
dvdrental=# \dv
                   List of relations
 Schema |            Name            | Type |  Owner
--------+----------------------------+------+----------
 public | actor_info                 | view | postgres
 public | customer_list              | view | postgres
 public | film_list                  | view | postgres
 public | nicer_but_slower_film_list | view | postgres
 public | sales_by_film_category     | view | postgres
 public | sales_by_store             | view | postgres
 public | staff_list                 | view | postgres
(7 rows)
```

### 2.13 Show view definition

To show the actual definition of a view, use the `\sv` command. For example, to show the view definition of `actor_info` in the `dvdrental` database you could type:

- `\sv actor_info`:

```console
dvdrental=# \sv actor_info
CREATE OR REPLACE VIEW public.actor_info AS
 SELECT a.actor_id,
    a.first_name,
    a.last_name,
    group_concat(DISTINCT (c.name::text || ': '::text) || (( SELECT group_concat(f.title::text) AS group_concat
           FROM film f
             JOIN film_category fc_1 ON f.film_id = fc_1.film_id
             JOIN film_actor fa_1 ON f.film_id = fa_1.film_id
          WHERE fc_1.category_id = c.category_id AND fa_1.actor_id = a.actor_id
          GROUP BY fa_1.actor_id))) AS film_info
   FROM actor a
     LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
     LEFT JOIN film_category fc ON fa.film_id = fc.film_id
     LEFT JOIN category c ON fc.category_id = c.category_id
  GROUP BY a.actor_id, a.first_name, a.last_name
```

## 3. Maintenance and operations issues

we give a short list of commands to control the performance and optimization tasks.

### 3.1 Timing

**Timing SQL operations**

Use `\t` to show timing for all SQL operations performed.

|Command	| Effect|
|:-------:|:-----:|
|\timing off |	Disable timing of SQL operations|
|\timing on	|Show timing after all SQL operations|
|\timing	|Toggle (reverse) the setting|


**Example of** `\t` **Timing command**

```console
dvdrental=# \timing
Timing is on.
dvdrental=# SELECT COUNT(*) AS total_rows
dvdrental-#   FROM payment;
 total_rows
------------
      14596
(1 row)

Time: 2.970 ms
dvdrental=# \timing
Timing is off.
```

### 3.2 Watch

The `\watch` command repeats the previous command at the specified interval. To use it, enter the SQL command you want repeated, then use `\watch` followed by the **number of seconds you want for the interval between repeats**, for rexample, `\watch 1` to repeat it every second.

**Example of the** `\Watch` **command**

Here’s an example of using `\watch` to see if any records have been inserted within the last 5 seconds.

```console
tom=# select count(*);
  count
--------
    726
(726 rows)

tom=# \watch 5
Mon Nov 16 13:50:36 2020 (every 2s)

  count
--------
    726
(726 rows)

Mon Nov 16 13:50:38 2020 (every 2s)

  count
--------
    726
(726 rows)

Mon Nov 16 13:50:40 2020 (every 2s)

  count
--------
    726
(726 rows)
```

### 3.3 Locate the pg_hba.conf file

Postgres configuration is stored in a file named `pg_hba.conf` somewhere in the file system, but that location varies widely. The way to find it is to use show hba_file like this:

```console
show  hba_file;
```

See below for hot reloading this file while Postgres is running.

**Reload the configuration file while Postgres is running**

If you make changes to the `pg_hba.conf` Postgres configuration sometimes you need to restart. But you may just choose to reload the `pg_hba.conf` configuration file like this:

```console
SELECT pg_reload_conf();
```
