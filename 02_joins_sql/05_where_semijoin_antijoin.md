# Filtering Joins

In the previous [lesson](./05_where_join.md), we illustrated how to combine the information of two tables into a single table by adding a `WHERE` clause and restricting the results to the rows where the foreign and primary key values are equal.

In this way, we can **join columns from both tables** and retrieve only those columns in which we are interested. The result is a table that includes columns from both tables.

Since a **Join** is a binary operation that involves two entities or tables, the following notation is used to indicate a join of two tables `A` and `B`:

- `JOIN(A,B)`: A join of two tables `A` and `B` returns a new table that includes columns from both tables.

For the way a **Join** combines information from both tables as a concatenation of columns from `A` and `B` tables, is sometimes referred to as **Equi Join** or **Mutati Join**.

- `JOIN(A,B)` ,**Mutating Join**: A mutating join of two tables, `A` and `B`, returns a new table that adds `B` columns to table `A` columns from matching rows in table `B`.  

Later in the course we introduce the `INNER JOIN` operator to perform a `Mutating Join` query.

Sometimes, however, we might want to select rows or columns only from a single table and restrict the results to the rows that have or do not have a match in the other table. Generally, the columns we want to be in the results belong to the referenced table, `parent` table, of the primary-foreign key relationship. These types of joins are usually referred to **Filtering join**.

- **Filtering Join**: A filtering Join filters rows or observations from one table based on whether or not they match a row in the other table.

There are two types of **filtering joins**:

1. `Semi_JOIN(A,B)`: A **Semi Join** of two tables, `A` and `B`, returns a new table that **keeps** all rows in `A` that have a match in `B`.

2. `Anti_JOIN(A,B)`: An **Anti Join** of two tables, `A` and `B`, returns a new table that **drops** all rows in `A` that have a match in `B`.

## Semi-join: Keep all observations of a single table that have a match


In this section we use the **courses**, **teachers** and **sections** tables of the `uniy` sample database as a demonstration examples for the **Semi Join** operation of two tables.

![uny erd](../00_basic_intro/images/11_uniy_erd.png)

In the previous [lesson](./05_where_join.md), we solved the problem of returning the `teacher's name` and `courses` of all teachers who are currently teaching a course.

**SQL**
```SQL
SELECT teacher_name,
       course_id
  FROM teachers, sections
 WHERE teachers.teacher_id = sections.teacher_id
 ORDER BY teacher_name, course_id;
```

**Results**

|teacher_name    | course_id|
|:--------------:|:---------:|
|Dr. Cooke          |       480|
|Dr. Engle          |       290|
|Dr. Horn           |       450|
|Dr. Lowe           |       730|
|Dr. Olsen          |       450|
|Dr. Scango         |       480|

What if we wanted to see only the `names of those teachers who are currently teaching some sections?`

It seems natural to select only the `teacher_name` column in the query issued.

**SQL**
```SQL
SELECT teacher_name
  FROM teachers, sections
 WHERE teachers.teacher_id = sections.teacher_id
 ORDER BY teacher_name;
```

**Results**

|teacher_name|
|:----------:|
|Dr. Cooke|
|Dr. Engle|
|Dr. Horn|
|Dr. Lowe|
|Dr. Olsen|
|Dr. Scango|

The query, however, works fine only if each row in the **teachers** table could match with `zero` or `one` row in the sections table.

Suppose the university provides a new course,`Data Base I`, in the `Computer Science` department:

```console
uniy=# INSERT INTO courses
uniy-#        (course_id, course_name, department, num_credits)
uniy-# VALUES (750, 'Data Base I', 'Computer Science', 4);
INSERT 0 1
```

**courses**

|course_id |     course_name      |    department    | num_credits|
|:--------:|:--------------------:|:----------------:|:-----------:|
|290 | English Composition  | English          |           3|
|450 | Western Civilization | History          |           3|
|480 | Compiler Writing     | Computer Science |           3|
|550 | Art History          | History          |           3|
|730 | Calculus IV          | Math             |           4|
|**750** | **Data Base I**          | **Computer Science** |           **4**|


The university assigns to `Dr. Cooke`, (`teacher_id`:**180**), the teaching position for the course **750**.

```console
uniy=# INSERT INTO sections
uniy-#        (course_id, section_id, teacher_id, num_students)
uniy-# VALUES (750, 2, 180, 6);
INSERT 0 1
```

**sections**

|course_id | section_id | teacher_id | num_students|
|:-------:|:----------:|:----------:|:-----------:|
|290 |          1 |        430 |            3|
|450 |          1 |        303 |            2|
|450 |          2 |        560 |            2|
|**480** |          **1** |        **180** |            **3**|
|480 |          2 |        784 |            2|
|730 |          1 |        290 |            6|
|**750** |          **2** |        **180** |            **6**|

The **sections** table shows that `Dr. Crooke` is currently teaching two courses **480** and **750**.

If we issue the following query:

**SQL**
```SQL
SELECT teacher_name
  FROM teachers, sections
 WHERE teachers.teacher_id = sections.teacher_id
 ORDER BY teacher_name;
```

What would it be the results?

**Results**

|teacher_name|
|:----------:|
|**Dr. Cooke**|
|**Dr. Cooke**|
|Dr. Engle|
|Dr. Horn|
|Dr. Lowe|
|Dr. Olsen|
|Dr. Scango|

As expected, the first two rows in the results show a duplicate value for `Dr. Crooke`. Obviously, we want only a single record for each teacher.

A possible solution would be to use a subquery and the `IN` operator to filter the **teachers**'s rows table based on the list of values in the foreign key column `teacher_id` of the **sections** table.

**SQL**

```SQL
SELECT teacher_name
 FROM teachers
WHERE teacher_id IN (
      SELECT teacher_id
        FROM sections
) ORDER BY teacher_name;
```

**Results**

|    teacher_name|
|:-------------------:|
|Dr. Cooke|
|Dr. Engle|
|Dr. Horn|
|Dr. Lowe|
|Dr. Olsen|
|Dr. Scango|

This approach can be extended to composite keys using multiple `AND` conditions and subqueries in the `WHERE` clause .

```SQL
SELECT <column_list>
 FROM t1
WHERE col1_id IN (
      SELECT col1_id
        FROM t2)
      AND
      col2_id IN (
      SELECT col2_id
        FROM t2
);
```

To overcome this issue an alternative and more efficient solution (see the section at the end of this lesson `JOIN vs Subquery` for a further discussion about efficiency) is to use the `DISTINCT` operator in the `SELECT` statement as follow:

**SQL**
```SQL
SELECT DISTINCT teacher_name
  FROM teachers, sections
 WHERE teachers.teacher_id = sections.teacher_id
 ORDER BY teacher_name;
```

**Results**

|    teacher_name|
|:-------------------:|
|Dr. Cooke|
|Dr. Engle|
|Dr. Horn|
|Dr. Lowe|
|Dr. Olsen|
|Dr. Scango|

But, what if we wanted to select more than a single column. Let's say we want to include the phone and salary.

**SQL**
```SQL
SELECT DISTINCT teacher_name, phone, salary
  FROM teachers, sections
 WHERE teachers.teacher_id = sections.teacher_id
 ORDER BY teacher_name;
```

**Results**

|    teacher_name    |   phone    |  salary|
|:------------------:|:----------:|:-------:|
|Dr. Cooke          | 257-8088   | 29560.00|
|Dr. Engle          | 256-4621   | 38200.00|
|Dr. Horn           | 257-3049   | 27540.00|
|Dr. Lowe           | 257-2390   | 31450.00|
|Dr. Olsen          | 257-8086   | 31778.00|
|Dr. Scango         | 257-3046   | 32098.00|

In this example, we use the `DISTINCT` option to filter all rows with distinct values of the selected columns.

The **important thing about this example** is its `FROM` clause: Despite the fact no values from the **sections** table are selected, that table must still appear in the `FROM` clause because a value from **sections** is referenced in the `WHERE` clause.

Keep in mind that the order PostgreSQL processes the query is:

`FROM` **->** `WHERE` **->** `SELECT`

In other words, the variable scope of the `SELECT` clause is not visible in the `WHERE` clause.

Later in the course we show that a `Semi Join` query is a special case of the `LEFT OUTER JOIN` operator.

To restore the state of the `uniy` sample database just delete the last two records inserted with the following statements:

```console
uniy=# DELETE FROM sections WHERE course_id = 750;
DELETE 1
uniy=# DELETE FROM courses WHERE course_id = 750;
DELETE 1
```

## Anti-join: drop all observations of a single table that have a match

In the previous [lesson](./05_where_join.md) we discussed the case a primary key value is not paired with any foreign key value in the `child` table. In relational database theory this kind of rows are often called **dangling** rows.

In this section we show how to retrieve all records that do not have a match in the other table of a join. At the beginning of this lesson, we defined the notion of **anti-join**.

- `Anti_JOIN(A,B)`: An **Anti Join** of two tables, `A` and `B`, returns a new table that **drops** all rows in `A` that have a match in `B`.

In the **Anti Join** definition the query **drops** all rows in the table `A` that have a match in `B`. This means that this query is essentially the complementary of the **Semi Join** query type.  

In the last example of the previous section, we used the **teachers** and **sections** tables to find the `names of the university's teachers who` **are** `currently teaching some sections`.

The complementary row set, therefore, includes the `names of the university's teachers who` **are not** `currently teaching` **any courses sections**.

**teachers**

|teacher_id |    teacher_name    |   phone    |  salary|
|:---------:|:------------------:|:----------:|:------:|
|180 | Dr. Cooke          | 257-8088   | 29560.00|
|**213** | **Dr. Wright**         | **257-3393**   | **35000.00**|
|290 | Dr. Lowe           | 257-2390   | 31450.00|
|303 | Dr. Horn           | 257-3049   | 27540.00|
|430 | Dr. Engle          | 256-4621   | 38200.00|
|560 | Dr. Olsen          | 257-8086   | 31778.00|
|784 | Dr. Scango         | 257-3046   | 32098.00|


**Sections**

| course_id | section_id | teacher_id | num_students|
|:---------:|:----------:|:----------:|:-----------:|
|480 |          1 |        180 |            3|
|730 |          1 |        290 |            6|
|450 |          1 |        303 |            2|
|290 |          1 |        430 |            3|
|450 |          2 |        560 |            2|
|480 |          2 |        784 |            2|

In the **teachers** table `Dr. Wright` is the only teacher with no teaching courses in the **sections** table.  

What do you think would happen if we run the following query:

**SQL**
```SQL
SELECT DISTINCT teacher_name
  FROM teachers, sections
 WHERE teachers.teacher_id != sections.teacher_id
 ORDER BY teacher_name;
```

**Results**

|    teacher_name    |
|:------------------:|
| Dr. Cooke          |
| Dr. Engle          |
| Dr. Horn           |
| Dr. Lowe           |
| Dr. Olsen          |
| Dr. Scango         |
| Dr. Wright         |

The query returns all the records in the **teachers** table, Why?

Let's run the following query:

**SQL**
```SQL
SELECT teacher_name,
       course AS non_teaching_course
  FROM teachers, sections
 WHERE teachers.teacher_id != sections.teacher_id
 ORDER BY teacher_name;
```

**Results**

|teacher_name    | no_teach_course_id|
|:--------------:|:--------------------:|
|Dr. Cooke          |                450|
|Dr. Cooke          |                730|
|Dr. Cooke          |                450|
|Dr. Cooke          |                480|
|Dr. Cooke          |                290|
|`Dr. Engle`          |                `730`|
|`Dr. Engle`          |                `480`|
|`Dr. Engle`          |                `480`|
|`Dr. Engle`          |                `450`|
|`Dr. Engle`          |                `450`|
|Dr. Horn           |                480|
|Dr. Horn           |                450|
|Dr. Horn           |                290|
|Dr. Horn           |                730|
|Dr. Horn           |                480|
|`Dr. Lowe`           |                `450`|
|`Dr. Lowe`           |                `290`|
|`Dr. Lowe`           |                `480`|
|`Dr. Lowe`           |                `450`|
|`Dr. Lowe`           |                `480`|
|Dr. Olsen          |                290|
|Dr. Olsen          |                480|
|Dr. Olsen          |                480|
|Dr. Olsen          |                730|
|Dr. Olsen          |                450|
|`Dr. Scango`         |                `450`|
|`Dr. Scango`         |                `450`|
|`Dr. Scango`         |                `480`|
|`Dr. Scango`         |                `730`|
|`Dr. Scango`         |                `290`|
|Dr. Wright         |                290|
|Dr. Wright         |                730|
|Dr. Wright         |                450|
|Dr. Wright         |                450|
|Dr. Wright         |                480|
|Dr. Wright         |                480|


The Results lists all the rows in the Cartesian Product for which the primary key is not equal to the foreign key. Consequently, a row contains information about teacher's name and a **course** that is **not taught by that teacher**.

It seems that the only way to get the record `Dr. Wright` is to use a subquery and the `NOT IN` operator in the `WHERE` clause:

**SQL**
```SQL
SELECT teacher_name
  FROM teachers
 WHERE teacher_id NOT IN (
       SELECT teacher_id
         FROM sections
)ORDER BY teacher_name;
```

**Results**

|    teacher_name|
|:--------------------:|
|Dr. Wright|


Later in the course we introduce a better solution to this problem by using the `LEFT OUTER JOIN` operator.


### Subqquery Vs Join

The previous approach, however, has the following limitations compared to the use of a JOIN.

- `JOINs` are faster than a `subquery` and it is very rare that the opposite.
- In `JOINs` the RDBMS calculates an execution plan, that can predict, what data should be loaded and how much it will take to processed and as a result this process save some times, unlike the subquery there is no pre-process calculation and run all the queries and load all their data to do the processing.
- A `JOIN` is checked conditions first and then put it into table and displays; where as a subquery take separate temp table internally and checking condition.
- When joins are using, there should be connection between two or more than two tables and each table has a relation with other while subquery means query inside another query, has no need to relation, it works on columns and conditions.
