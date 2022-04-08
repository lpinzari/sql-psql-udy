# Create commands

In this lesson you'll show some basic commands to create users and databases in PostgreSQL.

## Create Users

Postgres doesn’t actually directly manage users or groups, like most standard permission models do. Instead, it directly manages what it calls **roles**.


### default users or superusers

While it is certainly convenient that Postgres sets up a set of default users for you, it is a **very bad idea to use them for anything except local development**, because they are very widely known and more importantly, they are **super user accounts**:

**Superusers**: they **can do anything**, including delete databases.

**The default users do not have passwords by default but you can always set one**.(e.g `postgres=# \password postgres`). This is not safe for a production database—we need users with limited permissions.

![roles](./images/02_roles.png)

PostgreSQL uses roles to represent user accounts. It doesn’t use the user concept like other database systems.

Typically, roles can log in are called **login roles**. They are equivalent to users in other database systems.

When roles contain other roles, they are call group roles.

So how **do we create and use new users (roles)**?

### Create ROLE with psql

The attributes of a role define privileges for that role including `login`, `superuser`, `database creation`, `role creation`, `password`, **etc**:

- `CREATE ROLE username WITH [OPTIONS]`

In this syntax, the WITH keyword is optional. And the option can be one or more attributes including SUPER, CREATEDB, CREATEROLE, etc.

- `CREATE ROLE username WITH LOGIN PASSWORD 'quoted password' [OPTIONS];`

To create a role in postgres we execute the `CREATE ROLE` SQL query on the database. Where `username` is the user you want to create, and the `password` goes at the end in quotes. We will get to the options later.

```console
postgres=# CREATE ROLE usertest WITH LOGIN PASSWORD 'usertest';
CREATE ROLE
```
*Creates a role called `usertest` that has the login privilege (**LOGIN** Role attribute) and initial PASSWORD (**PASSWORD** Role attribute).*

An equivalent statement:

```console
CREATE ROLE usertest
CREATEDB
LOGIN
PASSWORD 'usertest';
```

Before we create a database that we'll work with **we need to create a role that we'll use in our python program to access the database**.

To create a role, we'll write "**CREATE ROLE**". We are going to call our *user* "`usertest`". You can choose another name for this. We're going to write "**WITH LOGIN PASSWORD**". We're requiring a *password* for this user and I'm just going to make that password "`usertest`" but you can make it whatever you like and then a **semi-colon to close the statement**. Note, the password in single quotes.


To get all roles in the current PostgreSQL database server, you can query them from the `pg_roles` **system catalog** as follows:

- `SELECT rolname FROM pg_roles;`

```console
(base) ludo /~  $  psql postgres
psql (11.4)
Type "help" for help.

postgres=# SELECT rolname FROM pg_roles;
          rolname
---------------------------
 postgres
 pg_monitor
 pg_read_all_settings
 pg_read_all_stats
 pg_stat_scan_tables
 pg_read_server_files
 pg_write_server_files
 pg_execute_server_program
 pg_signal_backend
 ludovicopinzari
 usertest
(11 rows)

postgres=# \q
(base) ludo /~  $
```

Noice that the roles that start with with `pg_` are system roles.

If you use the **psql tool**, you can use the `\du` command to list all existing roles in the current PostgreSQL database server.

- `postgres=# \du`

```console
postgres=# \du
                                      List of roles
    Role name    |                         Attributes                         | Member of
-----------------+------------------------------------------------------------+-----------
 ludovicopinzari | Superuser, Create role, Create DB                          | {}
 postgres        | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 usertest        |                                                            | {}
```

Looks like our role is created.
Wait. The **attributes list** for the user `usertest` is **completely empty**. Why?

This is how Postgres securely manages defaults. This user can **read any database, table, or row it has permissions for**, but nothing else—it **cannot create or manage databases and has no admin powers**. This is a good thing! It helps keep your database secure.

### Login with User Role account

Now, you can use the role `usertest` to log in to the PostgreSQL database server using the psql client tool:

- `psql postgres -U usertest`

It will prompt you for a password. You need to enter the password that you entered in the CREATE ROLE statement.

```console
postgres=# \q
(base) ludo /~  $  psql postgres -U usertest
psql (11.4)
Type "help" for help.

postgres=> \conninfo
You are connected to database "postgres" as user "usertest" via socket in "/tmp" at port "5432".
postgres=>
```

You’ll notice the prompt is slightly different – the `#` has changed to a `>`. **This indicates you’re no longer using a Super User account**.

However, This user can **read any database, table, or row it has permissions for**, but nothing else—it **cannot create or manage databases and has no admin powers**.


## ALTER ROLE

To **change attributes of a role**, you use the following form of `ALTER ROLE` statement:

- `ALTER ROLE role_name [WITH] option;`

For a complete list of Options see the documentation [here](https://www.postgresqltutorial.com/postgresql-administration/postgresql-alter-role/)

So let’s add the `CREATEDB` **permission to our new user** to allow them to create databases.

```console
postgres=# \q
(base) ludo /practice2  $  psql postgres
psql (11.4)
Type "help" for help.

postgres=# \conninfo
You are connected to database "postgres" as user "ludovicopinzari" via socket in "/tmp" at port "5432".
```

From here, we'll exit the shell with backslash "Q" and then login again with our Postgres **superuser** default account.


- `ALTER ROLE usertest WITH CREATEDB;`

```console
postgres=# ALTER ROLE usertest WITH CREATEDB;
ALTER ROLE
postgres=# \du
                                      List of roles
    Role name    |                         Attributes                         | Member of
-----------------+------------------------------------------------------------+-----------
 ludovicopinzari | Superuser, Create role, Create DB                          | {}
 postgres        | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 usertest        | Create DB                                                  | {}
```

Now I may want this role or user to create databases so I'm going to alter the role by going "alter role" the name of the role, Postgres. And then I'm going to add the "create DB" functionality. **So this user is going to be able to create and delete databases**.

Alternatively, if you want to create a role with the CREATEDB attribute directly then type the following:

```console
CREATE ROLE usertest
CREATEDB
LOGIN
PASSWORD 'usertest';
```


## Create Database with new user

```console
postgres=# \q
(base) ludo /~  $  psql postgres -U usertest
psql (11.4)
Type "help" for help.

postgres=> \conninfo
You are connected to database "postgres" as user "usertest" via socket in "/tmp" at port "5432".
postgres=>
```

From here, we'll exit the shell with backslash "Q" and then login again with our Postgres `usertest` account.

From here, we could create a database with "**CREATE DATABASE**". And we're going to call this database "`red30`".

- `CREATE DATABASE red30;`

```console
postgres=> CREATE DATABASE red30;
CREATE DATABASE
```

Let's hit enter and the database is created.

```console
postgres=> \list
...
...
red30  | usertest        | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
```

Let's go backslash "list" and we can see it in our list of databases.

The name of the database `red30`, the owner `usertest` other info and the last column is `Access privileges`.


## GRANT PRIVILIGES

```console
postgres=> GRANT ALL PRIVILEGES ON DATABASE red30 TO usertest;
GRANT
red30         usertest=CTc/usertest
```

Once this is done, you need to add at least one user who has permission to access the database (aside from the super users, who can access everything).

Find the documentation on the GRANT statement [here](https://www.postgresqltutorial.com/postgresql-administration/postgresql-grant/).

Similar to MySQL, if we want to manipulate the data in a given database we need to connect to it.

```console
postgres=> \c red30
You are now connected to database "red30" as user "usertest".
red30=> \dt
Did not find any relations.
```

We can connect to the `red30` database with backslash "C" and then the name of the database, `red30`. And now we're connected. And we're connected at user Postgres. Why is this the case? Well the second time we logged into the Postgres shell we did "psql" dash U Postgres. The dash "U" made us the Postgres user. Next, we list all the tables in the current database with `\dt`. At the moment there is no table. You can now create, read, delete and update data in the `red30` database with the user `usertest`.
