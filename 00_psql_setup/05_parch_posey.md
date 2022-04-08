# Parch & Posey sample Data Base

In this section we create a new database called `parch_posey`. To create and populate the tables in the `parch_posey` database we'll execute an external sql script `parch-and-posey.sql`. You can fine the file [here](../data).

## Create a Database with a new user

1. **login with the usertest account**

```console
(base) ludo /~  $  psql postgres -U usertest
psql (11.4)
Type "help" for help.

postgres=>
```

2. **check your connection info**

```console
postgres=> \conninfo
You are connected to database "postgres" as user "usertest" via socket in "/tmp" at port "5432".
```

3. **check role attributes for usertest account**

```console
postgres=> \du
                                      List of roles
    Role name    |                         Attributes                         | Member of
-----------------+------------------------------------------------------------+-----------
 ludovicopinzari | Superuser, Create role, Create DB                          | {}
 postgres        | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 usertest        | Create DB                                                  | {}
```

The output shows that `usertest` can create Databases.

4. **create parch_posey database**

```console
postgres=> CREATE DATABASE parch_posey;
CREATE DATABASE
```

5. **check the list of databases**

```console
postgres=> \list
...
parch_posey   | usertest        | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
```

6. **Grant privileges to the usertest account**

```console
postgres=> GRANT ALL PRIVILEGES ON DATABASE parch_posey to usertest;
GRANT
```

7. **check the list of databases**

```console
postgres=> \list     
```

The Access privileges column: ` | usertest=CTc/usertest`

## Create and populate tables in the parch and posey database

Now, the next step is to create and populate the tables of the parch and posey database. In order to do that, we'll execute the sql script `parch-and-posey.sql`.

1. **List files of your current working directory**

```console
(base) ludo /~  $  ls parch-and-posey.sql
parch-and-posey.sql
```
The `parch-and-posey.sql` file is in the current working directory. First, let's give a look to the first 10 lines of the `parch-and-posey.sql` file.

```console
(base) ludo /~  $  ls parch-and-posey.sql
parch-and-posey.sql
(base) ludo /~  $  head -10 parch-and-posey.sql
BEGIN TRANSACTION;
CREATE TABLE web_events (
	id integer,
	account_id integer,
	occurred_at timestamp,
	channel bpchar
);
INSERT INTO web_events VALUES (1,1001,'2015-10-06 17:13:58','direct');
INSERT INTO web_events VALUES (2,1001,'2015-11-05 03:08:26','direct');
INSERT INTO web_events VALUES (3,1001,'2015-12-04 03:57:24','direct');
```
The output shows that the file contains sql statements to create and populate tables. However, this file contains many sql statements and it would be very painful to execute all the statements from the postgresql prompt. So, next we'll log back in the `parch_posey` database as `usertest` acoount. Then we execute these psql commands from the file.

2. **login in the parch_posey database**

```console
(base) ludo /~  $  psql parch_posey -U usertest
psql (11.4)
Type "help" for help.
```

3. **Execute psql commands from external file**

```console
parch_posey=> \i parch-and-posey.sql
```
For an absolute path use `\ir [PATH]`.

4. **list the tables in the database**

```console
parch_posey=> \dt
           List of relations
 Schema |    Name    | Type  |  Owner
--------+------------+-------+----------
 public | accounts   | table | usertest
 public | orders     | table | usertest
 public | region     | table | usertest
 public | sales_reps | table | usertest
 public | web_events | table | usertest
(5 rows)
```

The script created 5 tables.

- **accounts**
- **orders**
- **region**
- **sales_reps**
- **web_events**

5. **list the tables columns**

- `accounts`

```console
parch_posey=> \d accounts
                    Table "public.accounts"
    Column    |     Type      | Collation | Nullable | Default
--------------+---------------+-----------+----------+---------
 id           | integer       |           |          |
 name         | bpchar        |           |          |
 website      | bpchar        |           |          |
 lat          | numeric(11,8) |           |          |
 long         | numeric(11,8) |           |          |
 primary_poc  | bpchar        |           |          |
 sales_rep_id | integer       |           |          |
```

- `orders`

```console
parch_posey=> \d orders
                              Table "public.orders"
      Column      |            Type             | Collation | Nullable | Default
------------------+-----------------------------+-----------+----------+---------
 id               | integer                     |           |          |
 account_id       | integer                     |           |          |
 occurred_at      | timestamp without time zone |           |          |
 standard_qty     | integer                     |           |          |
 gloss_qty        | integer                     |           |          |
 poster_qty       | integer                     |           |          |
 total            | integer                     |           |          |
 standard_amt_usd | numeric(10,2)               |           |          |
 gloss_amt_usd    | numeric(10,2)               |           |          |
 poster_amt_usd   | numeric(10,2)               |           |          |
 total_amt_usd    | numeric(10,2)               |           |          |
```

- `region`

```console
parch_posey=> \d region
               Table "public.region"
 Column |  Type   | Collation | Nullable | Default
--------+---------+-----------+----------+---------
 id     | integer |           |          |
 name   | bpchar  |           |          |
```

- `sales_reps`

```console
parch_posey=> \d sales_reps
              Table "public.sales_reps"
  Column   |  Type   | Collation | Nullable | Default
-----------+---------+-----------+----------+---------
 id        | integer |           |          |
 name      | bpchar  |           |          |
 region_id | integer |           |          |
```

- `web_events`

```console
parch_posey=> \d web_events
                         Table "public.web_events"
   Column    |            Type             | Collation | Nullable | Default
-------------+-----------------------------+-----------+----------+---------
 id          | integer                     |           |          |
 account_id  | integer                     |           |          |
 occurred_at | timestamp without time zone |           |          |
 channel     | bpchar                      |           |          |
```

## Primary Keys and Foreign Keys?

The `\d` command should also return **indexes**, **foreign key constraints**, and **triggers**. However, the `parch-and-posey.sql` script didn't include these informations. Therefore, the tables in this database are 'isolated'
and there is no information about the **primary key** and **foreign keys**. In the next chapter we'll show how to set the **primary key** and **link the tables** with **Foreign Keys**.
