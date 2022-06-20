# The Visual Approach with More Than Two Tables

Deciding exactly which columns from which tables should be joined can sometimes be difficult. With the visual approach, however, the task is greatly simplified. By referring to a diagram containing all of a database's tables, it's easy to see which tables contain which columns. With the aid of this diagram, one can "navigate" through the database, determining which columns should be joined to produce the desired information. Producing the correct SQL for the query becomes almost trivial once the visual picture of the query is understood.

![uniY tables3](../00_basic_intro/images/07_uniY.png)

The figure above shows every table in our `uniy` example database. For each, a line has been drawn between the most likely "joinable" columns. By joining the various tables through the values contained in these columns, you can express a wide range of queries.

In this example, we have indicated which columns can be used for joins. In other databases, how can you learn which columns can be used for joins?

The first hint is to look at the column names. Often, joinable columns in different tables are given the same name, as we have done in the example database. To get at a more precise answer, though, notice that the connected columns in every table each contain the same *kinds* of values. The `section_id` column in the `sections` table contains the same kinds of values as the `section_id` column in the `enrolls` table - section numbers of various courses.

Similarly, the `course_id` columns in both the `sections` and `courses` tables contain the numbers of the courses themselves. In general, it makes sense to join two columns whenever they contain the same kinds of values, such as course numbers. This is true regardless of the names assigned to those columns. If the column in the `sections` table containing course numbers were called `course_number`, it would still be legal to join it with the `course_id` table in `courses`. As long as the two columns contain the same kinds of values, the join is possible.

Note also that each of the join columns indicated in the `uniy` sample database figure is a `key` or part of a key. As indicated over and over again in the previous chapters and lessons, when key values from one table are stored in a column in another table, that column is said to contain a **foreign key**. A table's own key is sometimes referred to as its **primary key** to distinguish it from any foreign keys that table might contain.  Joins usually occur between columns containing either foreign or primary keys.

A detailed discussion of the `uniy` ERD is presented in lesson: [11_create_uniy_tables](../00_psql_setup/11_create_uniy_tables.md)
