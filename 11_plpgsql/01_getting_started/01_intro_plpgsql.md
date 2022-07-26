# Overview of PostgreSQL PL/pgSQL

**PL/pgSQL** is a **procedural programming language** for the `PostgreSQL database system`.

`PL/pgSQL` allows you to extend the functionality of the PostgreSQL database server by **creating server objects with complex logic**.

`PL/pgSQL` was designed to :

- Create **user-defined functions**, **stored procedures**, and **triggers**.
- Extend standard SQL by adding control structures such as `if`, `case`, and `loop` statements.
- Inherit all **user-defined functions**, **operators**, and **types**.

Since `PostgreSQL 9.0`, PL/pgSQL is **installed by default**.

## Advantages of using PL/pgSQL

`SQL` is a query language that allows you to query data from the database easily. However, **PostgreSQL only can execute SQL statements individually**.

It means that you have multiple statements, **you need to execute them one by one like this**:

- First, send a query to the PostgreSQL database server.
- Next, wait for it to process.
- Then, process the result set.
- After that, do some calculations.
- Finally, send another query to the PostgreSQL database server and repeat this process.

This process incurs the interprocess commmunication and network overheads.

To resolve this issue, PostgreSQL uses **PL/pgSQL**.

**PL/pgSQL wraps multiple statements in an object and store it on the PostgreSQL database server**.

So instead of sending multiple statements to the server one by one, **you can send one statement to execute the object stored in the server**. This allows you to:

- Reduce the number of round trips between the application and the PostgreSQL database server.
- Avoid transferring the immediate results between the application and the server.


## PostgreSQL PL/pgSQL disadvantages

Besides the advantages of using PL/pgSQL, there are some caveats:

- Slower in software development because PL/pgSQL requires specialized skills that many developers do not possess.
- Difficult to manage versions and hard to debug.
- May not be portable to other database management systems.

In this lesson, you have a brief overview of PostgreSQL PL/pgSQL, its advantages, and disadvantages.
