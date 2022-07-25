# When to Create Indexes

Exactly which indexes you create should depend on what kind of queries you plan to execute. If you will often be searching for teachers by name, then the creation of the previous `names` index would speed up these queries. For some kinds of queries, it might help to build indexes using more than one column.

Suppose, for instance, that you often wished to access information about students by course number and section number. To help with this, you might create an index on **enrolls** called `cset` with:

```SQL
CREATE INDEX cset
    ON enrolls(course_id,section_id);
```

This creates an index like that described earlier, except that the index relies on two values to find each record in the indexed table. The **cset** index would speed up queries like:

```SQL
SELECT student_name,
  FROM students, enrolls
 WHERE course_id = 450 AND
       students.student_id = enrolls.students_id;
```

Note once again that the index is never explicitly mentioned in the query. SQL simply uses it whenever appropriate.

Perhaps the most important use of indexes is in speeding up the execution of joins. Joining two tables can be very time-consuming operation, especially if either or both of the tables are large. Joining more than two tables can sometimes be very slow, trying the patience of any user. If the columns being joined have previously had indexes constructed for them, execution of the join can be many, many times faster.

As we have seen, joins most often occur on columns containing keys. We have often joined **students** and **enrolls**, for instance, on the columns called `student_id`. The `student_id` column is the key to the records in **students** and therefore guarantees that each of those records  is uniquely identifiable. In **enrolls**, on the other hand, `student_id` is a foreign key containing key values from another table. A query such as:

```SQL
SELECT student_name,
       grade
  FROM students, enrolls
 WHERE students.student_id = enrolls.student_id;
```

would likely execute much faster if one or both of the join columns `students.student_id` and `enrolls.student_id` were indexed. In other words, if you plan to perform many queries that join **students** and **enrolls** on their `student_id` columns, those queries would almost certainly execute faster if you first typed:

```SQL
CREATE INDEX ss_id
    ON students(student_id);
```

and

```SQL
CREATE INDEX es_id
    ON enrolls(student_id);
```

The indexes `ss_id` and `es_id` tables will be automatically used by SQL whenever necessary.
