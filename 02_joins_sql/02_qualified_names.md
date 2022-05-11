# Qualified Names

Before tackling joins, we need to first describe the notion of **qualified names**.

As we've already described, every `SELECT` statement must indicate the names of the columns that should be returned. So far, all of those columns have been from the same table. With **joins**, however, **we will be selecting columns from two or more tables simultaneously**.

Although all of the columns in a single table must have unique names, `columns in different tables can have the same name`. To identify a column in the database uniquely, then, we must use its **qualified name**.

A **qualified name** consists of the `name of a table` followed by a period, (**.**), and the `name of a column in that table`:
- **table_name** . `column_name`


## Uniy qualified names examples

![uny erd](../00_basic_intro/images/11_uniy_erd.png)


For example, the qualified name for the `teacher_id` column in the **sections** table is
- **sections** . `teacher_id`

while the qualified name for the `teacher_id` column in the **teachers** table is
- **teachers** . `teacher_id`


Because `every column in a table must have a different name`, and because SQL requires `every table in a database to have a different name`, **->** a **qualified name** is **guaranteed to identify exactly one column in exactly one table**.

To see how qualified names are used in a query, suppose that we wished to see each value for `teacher_name` from **teachers** along with each possible value for `teacher_id` and `course_id` from **sections**.

|teachers| sections|
|:------:|:-------:|
|**teacher_id**|`course_id`|
|`teacher_name`| section_id|
|phone |`teacher_id`|
|salary|num_students|

Requesting `teacher_name` from **teachers** along with `course_id` from **sections** is easy: Both column names are unique in the teachers and sections tables.

But selecting `teacher_id` from **sections** requires using the **qualified name** for `teacher_id`, **because a column with that name appears in both tables**. A query with only the `teacher_id` column name would be **ambiguous**. To demonstrate this, for yourself, try the following query:

```SQL
SELECT teacher_name,
       teacher_id,
       course_id
  FROM teachers, sections;
```

**Query**
```console
uniy=# SELECT teacher_name,
uniy-#        teacher_id,
uniy-#        course_id
uniy-#   FROM teachers, sections;
```

**Output**

```console
ERROR:  column reference "teacher_id" is ambiguous
LINE 2:        teacher_id,
               ^
```

The Output displays an `ERROR`, `column reference "teacher_id" is ambiguous`. It follows that we must reference the `teacher_id` column using the qualified name
- **sections** . `teacher_id` as requested in the problem.

Naturally, the query should be working with the other option **teachers** . `teacher_id`, but it is not requested in the problem.

- **Tables**: **teachers**, **sections**
- **columns**: `teacher_name`**,**  **sections** .`teacher_id` **,** `course_id`

A formulation of this query might be:

**SQL**
```SQL
SELECT teacher_name,
       sections.teacher_id, -- qualified name
       course_id -- table sections
  FROM teachers, sections;
```

What are the results of this query ? Probably not what you would expect ! For now, the output can be ignored or if you are curious try the query in your `psql` prompt and see what happens. We'll discuss the answer to this question in the next section.

## Summary

As we have already seen, **qualified names** are not required when there is no possibility of ambiguity. In the previous query, for instance, just the column name was required for `course_id` because **teachers** and **sections** have only one column with this name between them.

Despite the fact that a column called `course_id` also appears in the **courses** table, the list of tables in the previous query's `FROM` clause `limits its scope to` **teachers** and **sections**.

We have been taking advantage of this automatic limitation all along. For instance, in the query:

```SQL
SELECT student_id
  FROM students;
```

The column `student_id` must refer to the column of that name in the **students** table. Similarly, in the query:

```SQL
SELECT teacher_id
  FROM teachers;
```

There is still no ambiguity because the `FROM` clause specifies from which table the values for `teacher_id` are to be drawn. Even simple queries can use qualified names if desired, such as:

```SQL
SELECT students.student_name
  FROM students;
```

although it's hard to see why this option would be useful. In the first example given previously, however, ambiguity was possible, so qualified name was required.

In fact, the `column scope` specified by the **teachers** and **sections** tables in the `FROM` clause presents the following names:



|column|teachers|sections|scope|
|:------:|:------:|:---:|:----:|
|teacher_id|:heavy_multiplication_x:|:heavy_multiplication_x:|**teachers**.`teacher_id` **,** **sections**.`teacher_id`|
|teacher_name|:heavy_multiplication_x:||`teacher_name`|
|phone|:heavy_multiplication_x:||`phone`|
|salary|:heavy_multiplication_x:||`salary`|
|course_id||:heavy_multiplication_x:|`course_id`|
|section_id||:heavy_multiplication_x:|`section_id`|
|num_students||:heavy_multiplication_x:|`num_students`|
