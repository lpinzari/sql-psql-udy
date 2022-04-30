# HR Sample Data Base

In this lesson we create a new database called **hr**. To create and populate the tables in the `hr` database we'll create two `sql` file named `hr-schema.sql` and `hr-data.sql`, respectively.

Next, we execute the sql script files as we did in the previous lessons to create and populate the `uniy` sample data base. However, this time we'll show you how to implement a `recursive relationship` in PostgreSQL and introduce further details about the implementation of various relationship types using column constraints definition in the `CREATE TABLE` statements. We'll be talking about the `NOT NULL`, `UNIQUE` and `CHECK` **CONSTRAINTS** to enforce the **Data base Referential Integrity**. We've already introduced the notion of **data referential integrity** when we define the primary and foreign keys constraints in a Relation Database Management System. In the next lesson, we'll provide a more systematic approach to this topic.

In the following sections we'll:

1. Create the `hr` sample database in PostgreSQL.
2. Implement the `hr`'s ERD in the `hr-schema.sql` file.
3. Introduce a review of the basic column constraints: `NOT NULL`,`UNIQUE` and `CHECK`.
4. Create the script `hr-data.sql` to populate the `hr` sample database.
5. Execute the scripts in the `psql` prompt.
