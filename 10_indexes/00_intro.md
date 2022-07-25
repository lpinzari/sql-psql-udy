# Introduction Indexes

Recall that records stored in a table are **unordered**. When a new record is added with `INSERT`, SQL simply adds that record in some convenient place in the table. While this lack of order makes for a very simple model of how data is stored, it does not help very much in the efficient retrieval of information.

Let's consider the `uniy` sample database.

Suppose, for example, that you type:

```SQL
SELECT teacher_id
  FROM teachers
 WHERE teacher_name = 'Dr. Cooke';
```

To execute this query, SQL must potentially search the entire **teachers** table, comparing the value in each record's teacher_name filed to `Dr. Cooke`. When a record is found whose `teacher_name` field contains this value, the value stored in that record's `teacher_id` filed is returned.

In a small table like **teachers**, performing a simple search like this one is unlikely to be a problem. Computers are fast machines, so examining half a dozen records does not take long. In a real relational database, however, a single table might well contain thousands, millions, or tens of millions of records. Trying to find `Dr. Cooke's` teacher number by looking at each record could take a very long time, even with a fast machine. To help solve this problem, SQL allows us to create **indexes**.

An **index** is simply **another table in the database**. It `cannot`, however, `be directly queried`. Instead, an index is **automatically used by SQL** itself whenever possible **to speed up the execution of queries on other tables** in the database. While we, the users of SQL, `must decide when and how indexes are created`, **we need not decide when they are used**.

PostgreSQL indexes are effective tools to enhance database performance. Indexes help the database server **find specific rows much faster than it could do without indexes**.

However, indexes

- add write and storage overheads to the database system. Therefore, using them appropriately is very important.

In this lesson, we will show you how to work with indexes more effectively in PostgreSQL.

- **Create Index** – shows you how to define a new index for a table.
- **Drop Index** – guides you on how to remove an existing index.
- **List indexes** – shows you how to list all indexes in the PostgreSQL database.
- **Index Types** – discusses various types of indexes in PostgreSQL.
- **Unique Index** – provides you with steps of defining unique indexes.
- **Index on Expression** – shows you how to define an index based on expressions.
- **Partial index** – illustrates how to use partial indexes.
- **Reindex** – shows you how to use the `REINDEX` statement to rebuild one or more indices.
- **Multicolumn Indexes** – shows you how to use multicolumn indexes to speed up queries with various conditions in `WHERE` clause.
