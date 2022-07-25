# Adding Records to a View

Updating a view - `adding, modifying`, or `deleting` its records - can be problematic. Because views are dependent on base tables and have no physical existence on their own, it is not always possible to correctly update a view. In an academic sense, updating views remains an interesting research topic. From a more pragmatic perspective, updating views can be a headache.

Consider the view **pa_only**, defined earlier, consisting the names, student numbers, and states of only those students from Pennsylvania. It was created with:

```SQL
CREATE VIEW pa_only (name, number, state) AS
       SELECT student_name, student_id, state
         FROM students
        WHERE state = 'PA';
```

Suppose that we want to add a record to this view. This task can be accomplished with:

```SQL
INSERT INTO pa_only
VALUES ('Patti Couture', 335, 'PA');
```

How is this statement handled by SQL?

Because this view relies on only a single base table, the answer is straightforward: By adding a record to the **students** table. That record will contain the value `Patti Couture` in its `student_name` field, `335` in `student_id`, and `PA` in state. All other fields in this new record - address, city, zip and gender - will be set to `NULL`.

What happens if an attempt is made to insert a record that does not conform to the requirements specified in the `CREATE VIEW` statement?

One might, for example, type:

```SQL
INSERT INTO pa_only
VALUES ('Kay Moran',442,'MN');
```

Because its value for state is `MN`, this new record violates the condition given in the `WHERE` clause when the view **pa_only** was created. What will SQL do in this case?

Should it insert the new (but in some sense illegal) record into **students**, or should it reject this `INSERT` statement?

the answer depends on how the view was created. According to the SQL standard, a view can be created with the `CHECK` option. Although not all systems implement it, this option requires SQL to check view updates for consistency with the original view definition and to reject any that violates the view's constraints. To create **pa_only** with this option, one types:

```SQL
CREATE VIEW pa_only (name, number, state) AS
       SELECT student_name, student_id, state
         FROM students
        WHERE state = 'PA'
WITH CHECK OPTION;
```

If the view were created this way, the previous attempt to `INSERT` a record with `state` equal to `MN` would have been rejected. If the `CHECK` option were not specified during the creation of the view, the erroneous record would have been added to the **students** table but would have not have been visible in the view **pa_only**.

Even worse, problem can occur with views that include derived columns. consider the view `monthly`, defined earlier:

```SQL
CREATE VIEW monthly (teacher_name, teacher_id, m_salary) AS
       SELECT teacher_name, teacher_id, salary / 12
         FROM teachers;
```

Suppose we now attempt to add a new record to this view with:

```SQL
INSERT INTO monthly
VALUES ('James Fennel',544,2995.00);
```

While our `INSERT` statement is perfectly correct, there is no way for SQL to correctly execute it. To see why, try to answer this question:

What base table should this new record be added to?

The **teachers** table, on which the view **monthly** is based, has no column containing monthly salary and thus no place to store the value `2995.00` from the new record. While one might argue that SQL should understand that `2995.00` is one-twelth of a value that could be stored in `salary` and thus calculate the appropriate amount to store in that column in **teachers**, this is not done in practice. the upshot is simple: Updates such as these will be rejected as illegal by SQL.

One other point: All the updates discussed so far involve views based only on a single table. With views such as `roster`, which are dependent on many tables, adding records again becomes a problem. In general, views based on more than one table are not updateable. Also, even though you can define views by using `SELECT` statements with `GROUPO BY` and `HAVING` clauses, such views are also not updateable.

## PosgreSQL updatable views example  

First, create a new updatable view name `usa_cities` using `CREATE VIEW` statement. This view contains all cities in the `city` table locating in the USA whose country id is `103`.

```SQL
CREATE VIEW usa_cities AS
       SELECT city,
              country_id
         FROM city
        WHERE country_id = 103;
```

Next, check the data in the `usa_cities` view by executing the following `SELECT` statement:

```SQL
SELECT *
  FROM usa_cities;
```

|          city           | country_id|
|:-----------------------:|:-----------:|
| Akron                   |        103|
| Arlington               |        103|
| Augusta-Richmond County |        103|
| Aurora                  |        103|
| Bellevue                |        103|
| Brockton                |        103|
| Cape Coral              |        103|
| Citrus Heights          |        103|
| Clarksville             |        103|
| Compton                 |        103|
| Dallas                  |        103|
| Dayton                  |        103|
| El Monte                |        103|
| Fontana                 |        103|
| Garden Grove            |        103|
| Garland                 |        103|
| Grand Prairie           |        103|
| Greensboro              |        103|
| Joliet                  |        103|
| Kansas City             |        103|
| Lancaster               |        103|
| Laredo                  |        103|
| Lincoln                 |        103|
| Manchester              |        103|
| Memphis                 |        103|
| Peoria                  |        103|
| Roanoke                 |        103|
| Rockford                |        103|
| Saint Louis             |        103|
| Salinas                 |        103|
| San Bernardino          |        103|
| Sterling Heights        |        103|
| Sunnyvale               |        103|
| Tallahassee             |        103|
| Warren                  |        103|

Then, insert a new city to the city table through the `usa_cities` view using the following `INSERT` statement:

```SQL
INSERT INTO usa_cities (city, country_id)
VALUES('San Jose', 103);
```

After that, check the contents of the `city` table:


```SQL
SELECT city,
       country_id
  FROM city
 WHERE country_id = 103
 ORDER BY last_update DESC;
```

We have a newly entry added to the `city` table.

**Results**

|city           | country_id|
|:----------------------:|:---------:|
|**San Jose**                |        **103**|
|Arlington               |        103|
|Augusta-Richmond County |        103|
|Aurora                  |        103|
|Bellevue                |        103|
|Brockton                |        103|

Finally, delete the entry that has been added through the `usa_cities` view.

```SQL
DELETE FROM usa_cities
      WHERE city = 'San Jose';
```

The entry has been deleted from the city table through the `usa_cities` view.
