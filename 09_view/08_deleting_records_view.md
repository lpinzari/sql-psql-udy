# Deleting Records from a View

With this understanding in mind, it is not great leap to predict how SQL's **DELETE** statement will work with views.

```SQL
CREATE VIEW pa_only (name, number, state) AS
       SELECT student_name, student_id, state
         FROM students
        WHERE state = 'PA'
WITH CHECK OPTION;
```

If possible, records will be deleted from the base table to cause the desired effect in the view. For example, the statement:

```SQL
DELETE FROM pa_only
      WHERE number = 335;
```

will remove the record with the value `335` in the `student_id` filed from **students**. In turn, that record would vanish from the view **pa_only**. (Note that *all* of the record's fields are deleted, not just those included in the view). There are times, however, when this solution will not be possible. In such situations, SQL must reject the attempted deletion.

In general, when is a view **updateable** ? When can `INSERTs`, `UPDATEs` and `DELETEs` safely be executed against a view?

The answer depends to some extent on choices made by the implementers of your particular system. It is safe to say, however, that a view is probably not updateable if it relies on more than one base table or if its defining `SELECT` uses `DISTINCT` or includes a `GROUP BY` clause, a `HAVING` clause, or a subquery. Also, views with one or more derived columns will have at least some restrictions on their updatability. 
