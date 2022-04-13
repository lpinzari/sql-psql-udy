# Create UniY database

In this section we create the `uniy` database. The steps for the creation of the `uniy` database in  PostgreSql are equivalent to the steps illustrated in the creation of the `parch_posey` database. We'll follow redundant steps but it's a good way to recall the psql's commands :smile:

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

4. **create uniy database**

```console
postgres=> CREATE DATABASE uniy;
CREATE DATABASE
```

5. **check the list of databases**

```console
postgres=> \list
...
uniy               | usertest        | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
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

The Access privileges column: ` | Tc/usertest + usertest=CTc/usertest`
