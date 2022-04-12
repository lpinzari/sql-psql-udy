# The Structure of SQL Statemnts

SQL's full name, Structured Query Language, is a slight misnomer. It implies that only queries are supported, and that all a SQL user can do is ask questions about information stored in a database's tables. In fact, SQL allows its user to **create tables**, **destroy tables**, **modify** their contents, **grant** and **revoke** access to them, and do several other tasks required for full use of a relational database. Although **queries** are its most common use, SQL is really much more than just a **query language**.

To allow access to the information stored in a relational database, SQL defines a number of operations, sometimes called the **verbs** of the language. Just as speakers of English rely on English verbs to indicate actions, SQL users rely on its verbs to indicate the actions to be performed on a database. Each SQL verb has a specific meaning and serves a specific purpose.

Every SQL statement, whether entered by a human being at a keyboard or embedded within some computer program, begins with a SQL verb. Following this comes further information specifying exactly what that verb should do. If the verb requests information about a table, for instance, the name of the table must appear. At the end of each statement appears a termination character. Different SQL systems define different termination characters, but the most common (and the one used throughout the course and in PostgreSql) is a semicolon `;`.

The syntax of each SQL statement, as well as a visual approach for each, is described later in the course. For now, the important thing is to note this basic `form-verb`, information specifying what the verb should do, and the termination character (e.g. a semicolon). As an example, the statement to list the names of all teachers in the `teachers` table is:

```console
SELECT teacher_name
  FROM teachers;
```

The verb is SELECT, the termination character is the semicolon `;`, and everything in between is a specification of what the verb should do. All SQL statements follow this same basic structure.

An important **NOTE**: **SQL is free-format**. In other words, blanks and the line on which various parts of a statement appear are not significant. The previous example could also have been stated as:

```console
SELECT teacher_name FROM teacher;
```

or

```console
SELECT
teacher_name FROM teachers;
```

and the results would have been the same.

Although conformance to the SQL standard requires support only of upper case letters, not implementations of SQL treat upper and lower case letters as equivalent. In most products that support SQL, therefore, typing the previous examples in all lower case letters would have produced equivalent results.
