# Modifying Records in a View

Similar difficulties arise with attempts to modify records in **views**. Some views, such as **pa_only**,

```SQL
CREATE VIEW pa_only (name, number, state) AS
       SELECT student_name, student_id, state
         FROM students
        WHERE state = 'PA'
WITH CHECK OPTION;
```

can be modified with statements like:

```SQL
UPDATE pa_only
   SET name = 'Diana Catignani'
 WHERE number = 654;
```

In this case, the appropriate record in **students**, the view's base table, is modified. But suppose the `UPDATE` looked like:

```SQL
UPDATE pa_only
   SET name = 'Diana Catignani',
       state = 'CA'
 WHERE number = 654;
```

Again, we are faced with a possible inconsistency, because the requested modifications would cause this record to no longer meet the requirements for membership in this view. Whether such an `UPDATE` is accepted or rejected by SQL depends again on whether the `CHECK` option was specified when the view was created.

Modifying records in views with derived columns, such as **monthly**, might be allowed as long as no attempt is made to change a value in a derived column. Recall that all queries on views, whether simple `SELECTs` or more invasive `INSERTs` and `UPDATEs`, must eventually be converted into SQL operations on the view's base tables. If this is not possible, as in the case of updating a value in a derived column, the query against the view must be rejected.
