## Configuring PostgreSQL

Postgres works pretty hard to make itself usable right out of the box without you having to do anything. By default, it automatically creates the user `postgres`. Let’s see what other users it has created. Let’s start by using the `psql` utility, which is a **utility installed with Postgres that lets you carry out administrative functions** without needing to know their actual SQL commands.

Start by entering the following on the command line:

```console
(base) ludo /practice2  $  psql postgres
psql (11.4)
Type "help" for help.

postgres=#
```

We'll type in "`psql postgres`" and we're in. That’s the **psql command line** `postgres=#`. We can now enter a command to see what users are installed


## List users

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


## List Databases

**list all the databases**: `\list`

```console
postgres=# \list
...
ludovicopinzari
postgres
```
To list all the databases in the postgres database management system type `\list`. You will see the two default databases.

## Connection Information

**display information of the current connection**: `\conninfo`

```console
postgres=# \conninfo
You are connected to database "postgres" as user "ludovicopinzari" via socket in "/tmp" at port "5432".
```

We see that our current user is "ludovicopinzari" and is connected to the database "postgres".

## Changing Database connection

**changing database with the current user**: `\c databaseName`

```console
postgres=# \c ludovicopinzari
You are now connected to database "ludovicopinzari" as user "ludovicopinzari".
```

## Changing User connection

**changing user with the current database**: `\c - userName`

```console
ludovicopinzari=# \c - postgres
You are now connected to database "ludovicopinzari" as user "postgres".
```
The `-` is substitute for current database.

## Changing Database and User connection

**changing database and user**: `\c databaseName userName`
```console
ludovicopinzari=# \c postgres ludovicopinzari
You are now connected to database "postgres" as user "ludovicopinzari".
```
