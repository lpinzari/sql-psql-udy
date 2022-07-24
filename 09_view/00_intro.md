# Views

The tables that make up a relational database have a physical existence; the data stored in them actually takes up space in some computer system. Based on these actual physical tables, however, we can define other `tables` that **don't physically exist but nevertheless can be accessed as if they did**. Such tables are called **views**.

A view is a named query that provides another way to present data in the database tables. A view is defined based on one or more tables which are known as `base tables`. When you `create a view`, **you basically create a query and assign a name to the query**. Therefore, a view is useful for `wrapping a` **commonly used complex query**.

Note that `regular` views **do not store any data** `except the materialized views`.

In PostgreSQL, you can create special views called **materialized views** that `store data physically and periodically refresh data from the base tables`. The materialized views are handy in many scenarios, such as **faster data access to a remote server and caching**.

In this lesson, you will learn about the PostgreSQL views concept and how to manage views, such as creating, modifying, and removing views from the database.

- **Managing PostgreSQL views** – introduce you to the concept of the view and show you how to create, modify, and remove PostgreSQL views.
- **Drop view** – learn how to drop one or more views from the database.
- **Create updatable views** – give you examples of creating updatable views that allow you to issue `INSERT`, `UPDATE`, and `DELETE` statements to update data in the base tables through the views.
- **Materialized views**  – introduce you to materialized views and provide you with the steps of creating and refreshing data for materialized views.
- **Creating updatable views using the WITH CHECK OPTION clause** – show you how to use the `WITH CHECK OPTION` clause to check the view-defining condition when you make a change to the base table through the view.
- **Create recursive views** – introduce you to the recursive view and show you an example of creating a recursive view in PostgreSQL.
