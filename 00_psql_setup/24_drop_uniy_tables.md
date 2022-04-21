# Dropping (Destroying) uniY Schema

In the previous lesson we introduced the `DROP TABLE` statement to **destroy** the tables in a database. We also introduced the `CASCADE` option to destroy a table used in other objects; such as **foreign key constraints** in other tables that reference the parent table to be deestroyed.

In this lesson we'll show you how to destroy all the tables in the uniY sample database. There is a term to describe all the objects of a database: the **database schema**. You can formally create a database schema in PostgreSQL following the lesson in the link below:
- [schema](https://www.postgresqltutorial.com/postgresql-administration/postgresql-schema/)

## uniY: Dropping all tables

In lesson [11](./11_create_uniy_tables.md), we illustrated how to create all the tables in the uniY sample database. In this lesson we'll show you a *recommended order* to **destroy all the tables in a database schema**, although you can choose any arbitrary order.

![uniY tables3](../00_basic_intro/images/07_uniY.png)

![uniY table4](./images/11_hierarchy.png)

| tables  | referenced_by    | references                 |
|:-------:|:----------------:|:--------------------------:|
|students |        enrolls   |                            |
|courses  | enrolls, sections|                            |
|teachers | sections         |                            |
|sections | enrolls          | courses,teachers           |
|enrolls  |                  | students, courses, sections|


The *recommended order* is illustrated in the picture above.

1. The picture above shows that the only `parent` tables are:
  - **students**
  - **courses**
  - **teachers**

We can destroy those tables in any order.

2. Then, the first `child` table in the tree is:
  - **sections**

The sections table does not have grand parents.

3. Lastly, the only table with `grand parents` is:
  - **enrolls**

It follows that, a possible `DROP TABLE` statement to destroy all the tables in the uniY sample database is:

```console
-- Destroy the uniY database schema
DROP TABLE IF EXISTS
           students,
           courses,
           teachers,
           sections,
           sections
CASCADE;
```
The first line is a single line comment, `--` indicates a comment.
Let's list all the tables in the uniY sample database.

```console
uniy=> \dt
          List of relations
 Schema |   Name   | Type  |  Owner
--------+----------+-------+----------
 public | courses  | table | usertest
 public | enrolls  | table | usertest
 public | sections | table | usertest
 public | students | table | usertest
 public | teachers | table | usertest
(5 rows)
```

Let's execute the `DROP TABLE` command in the `psql` prompt.

```console
uniy=> -- Destroy the uniY database schema
uniy=> DROP TABLE IF EXISTS
uniy->            students,
uniy->            courses,
uniy->            teachers,
uniy->            sections,
uniy->            enrolls
uniy-> CASCADE;
DROP TABLE
```

Let's list all the tables in the database:

```console
uniy=> \dt
Did not find any relations.
```

There are no tables in database.

In the next lesson we'll show how to write a `sql` script to destroy and create a new database schema.
