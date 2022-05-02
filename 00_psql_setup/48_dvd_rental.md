# DVD Rental Sample Database

In this lesson we create a new database called `dvdrental`. To create and populate the tables in the `dvdrental` database

1. **Download** the `dvdrental.zip` backup archive file named `dvdrental.zip` and unzip the file to the folder `dvdrental`.
2. **Change directory** to the `../dvdrental` directory.
3. **Edit** `restore.sql`.
4. **Execute** `restore.sql`.


## 1: Download dvdrental.zip

The first step is to downlad the [dvdrental.zip](https://www.postgresqltutorial.com/wp-content/uploads/2019/05/dvdrental.zip).

The database file is in `.zip` format, so you need to extract the file to a folder named `dvdrental` or whatever name you want.

## 2: Change directory

Navigate to the `dvdrental` directory and list its files.

```console
(base) ludo /dvdrental  $  pwd
/Users/ludovicopinzari/dvdrental
(base) ludo /dvdrental  $  ls
3055.dat    3059.dat    3062.dat    3065.dat    3069.dat    3073.dat    3077.dat    3081.dat    toc.dat
3057.dat    3061.dat    3063.dat    3067.dat    3071.dat    3075.dat    3079.dat    restore.sql
```

The output shows the content of the `dvdrental` directory. The `restore.sql` file is in the `dvdrental` directory.

## 3: Edit restore.sql

Open the `restore.sql` file with your text editor. Make the following changes:

1. change `DROP DATABASE dvdrental` to:
  - `DROP DATABASE IF EXISTS dvdrental;`
2. change `CREATE DATABASE dvdrental WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'English_United States.1252' LC_CTYPE = 'English_United States.1252';` to:
  - `CREATE DATABASE dvdrental WITH TEMPLATE = template0 ENCODING = 'UTF8';`
3. Search for `$$PATH$$` string and replace it with the path to the directory containing the extracted data files.

The third step indicates that the File paths need to be edited. For example if the absolute path of the `dvdrental` folder is `/Users/ludovicopinzari/dvdrental` then all the `$$PATH$$` strings should be replaced with `/Users/ludovicopinzari/dvdrental`.

For instance the following `COPY` command:

- `COPY public.actor (actor_id, first_name, last_name, last_update) FROM '$$PATH$$/3057.dat';`

Must be replaced by:

- `COPY public.actor (actor_id, first_name, last_name, last_update) FROM '/Users/ludovicopinzari/dvdrental/3057.dat';`

4. Save the `restore.sql` file.

## 4. Execute the restore.sql file

Finally, to execute the `restore.sql` file, you could type:

```console
psql -U postgres -b -f restore.sql
```

- **-U postgres**: connect with the superuser account `postgres`.
- **-b**: print failed commands.
- **-f restore.sql**: specifies the name of the file to be executed.

Let's execute the command.

```console
(base) ludo /dvdrental  $  psql -U postgres -b -f restore.sql
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
DROP DATABASE
CREATE DATABASE
ALTER DATABASE
You are now connected to database "dvdrental" as user "postgres".
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
CREATE TYPE
ALTER TYPE
CREATE DOMAIN
ALTER DOMAIN
CREATE FUNCTION
ALTER FUNCTION
CREATE FUNCTION
ALTER FUNCTION
CREATE FUNCTION
ALTER FUNCTION
CREATE FUNCTION
ALTER FUNCTION
CREATE FUNCTION
ALTER FUNCTION
CREATE FUNCTION
ALTER FUNCTION
CREATE FUNCTION
ALTER FUNCTION
CREATE FUNCTION
ALTER FUNCTION
CREATE SEQUENCE
ALTER TABLE
SET
SET
CREATE TABLE
ALTER TABLE
CREATE FUNCTION
ALTER FUNCTION
CREATE AGGREGATE
ALTER AGGREGATE
CREATE SEQUENCE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE VIEW
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE VIEW
ALTER TABLE
CREATE VIEW
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE VIEW
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE VIEW
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE VIEW
ALTER TABLE
CREATE VIEW
ALTER TABLE
COPY 0
COPY 200
COPY 0
COPY 603
COPY 0
COPY 16
COPY 0
COPY 600
COPY 0
COPY 109
COPY 0
COPY 599
COPY 0
COPY 1000
COPY 0
COPY 5462
COPY 0
COPY 1000
COPY 0
COPY 4581
COPY 0
COPY 6
COPY 0
COPY 14596
COPY 0
COPY 16044
COPY 0
COPY 2
COPY 0
COPY 2
 setval
--------
    200
(1 row)

 setval
--------
    605
(1 row)

 setval
--------
     16
(1 row)

 setval
--------
    600
(1 row)

 setval
--------
    109
(1 row)

 setval
--------
    599
(1 row)

 setval
--------
   1000
(1 row)

 setval
--------
   4581
(1 row)

 setval
--------
      6
(1 row)

 setval
--------
  32098
(1 row)

 setval
--------
  16049
(1 row)

 setval
--------
      2
(1 row)

 setval
--------
      2
(1 row)

ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE TRIGGER
CREATE TRIGGER
CREATE TRIGGER
CREATE TRIGGER
CREATE TRIGGER
CREATE TRIGGER
CREATE TRIGGER
CREATE TRIGGER
CREATE TRIGGER
CREATE TRIGGER
CREATE TRIGGER
CREATE TRIGGER
CREATE TRIGGER
CREATE TRIGGER
CREATE TRIGGER
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
```

The `dvdrental` database has been created. In the next lesson, we explore the tables and objects of the `dvdrental` database.
