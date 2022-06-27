# Finding Maximum and Minimum Values

It is often interesting to ask about the limits of data values stored in a table.

- Which teacher makes the most money?
- Which student received the lowest grade?

For answering questions like these, SQL provides the `MAX` and `MIN` aggregates functions. Both `MAX` and `MIN` can be used like the name of a column in a `SELECT`. You could use, for example:

```SQL
SELECT MAX(salary)
  FROM teachers;
```

or

```SQL
SELECT MIN(grade)
  FROM enrolls;
```

The first query would select and display the maximum value from the `salary` column of the `teachers` table while the second would display the minimum value from the `grade` column of the `enrolls` table. The name of the query's result defaults to, for example, `MAX(salary)`. A different name can be assigned, if desired, though the mechanism seen earlier, such as

**SQL**

```SQL
SELECT MAX(salary) AS maximum_salary
  FROM teachers;
```

**Results**

|maximum_salary|
|:--------------:|
|      38200.00|


```console
uniy=# SELECT MAX(salary) AS maximum_salary
uniy-#   FROM teachers;
 maximum_salary
----------------
       38200.00
(1 row)
```

(It's worth noting that the default name assigned to the query's result can vary from one implementation of SQL to another.)

It is also possible to use a `WHERE` clause to select the maximum or minimum value from a group of records meeting some specified criteria. We could, for example, say

```SQL
SELECT MAX(salary)
  FROM teachers
 WHERE teacher_id > 300;
```

This query selects the largest salary only from  those records on the `teachers` table that have a `teacher_id` greater than `300`.


What if, instead of the previous query using `MAX`, you wanted to know not only what the maximum teacher salary was but also who earned it? You might have naively used:

```SQL
SELECT teacher_name, MAX(salary)
  FROM teachers;
```

Unfortunately, **you would have received an error message because this query is illegal**. It's illegal because, in simple cases such as these, SQL requires that a query return the same number of values for every column name specified. Thus far, this situation has not been a problem, because each table has the same number of values in each of its columns.

When using `MAX` and `MIN`, however, the situation changes. As mentioned previously, `MAX` and `MIN` function somewhat like column names, and yet by their nature both always return only a single value. Because of SQL's rule that queries must always return the same number of values for each specified column name, no other column names (except for those appearing within other aggregates) can be specified along with `MAX` or `MIN`. As we will see, all `SQL` aggregates share this same limitation. (There is one significant exception: Using `GROUP BY`, described at the end of this chapter, enables other column names to appear in a `SELECT` along with `MAX`,`MIN` and other aggregates.)


Although they probably make the most sense when used with numeric columns, `MAX` and `MIN` can also be used with character columns. With character columns, it is as if all the values in the column are first placed in alphabetical order, then the last value (for `MAX`) or the first value (for `MIN`) is returned.

As was the case with arithmetic operations, we must once more ask: What about `NULLs`?
Unlike the arithmetic operators, all of which return `NULL` if `any` of a column's values are `NULL`, `MAX` and `MIN` *ignore* `NULL` values. This makes some sense, since it's hard to see how `NULL` could be compared to other values in a particular column.

All aggregates, including `MAX` and `MIN`, share some other restrictions on their use.
For one thing, aggregates cannot be nested; that is, the value passed to an aggregate can't include some other aggregate. Also, aggregates cannot appear in a `WHERE` clause. To find the name of the teacher with the highest salary, for example, you **cannot** just use:

```SQL
SELECT teacher_name
  FROM teachers
 WHERE salary = MAX(salary);
```

This query is illegal. Instead, specifying conditions including aggregates requires using either `GROUP BY` and the `HAVING` clause, described at the end of this chapter, or more likely a subquery.

Another simple solution is the use of the `ORDER BY` clause:

**SQL**
```SQL
SELECT teacher_name
  FROM teachers
 ORDER BY salary DESC
 LIMIT 1;
```

**Results**

|teacher_name|
|:------------------:|
|Dr. Engle|


**Query**
```SQL
uniy=# SELECT teacher_name
uniy-#   FROM teachers
uniy-#  ORDER BY salary DESC
uniy-#  LIMIT 1;
```

**Output**
```console
    teacher_name
--------------------
 Dr. Engle
(1 row)
```

The following query confirms that `Dr. Engle` earns the highest salary.

```console
uniy=# SELECT *
uniy-#   FROM teachers
uniy-#  ORDER BY salary DESC;
 teacher_id |    teacher_name    |   phone    |  salary
------------+--------------------+------------+----------
        430 | Dr. Engle          | 256-4621   | 38200.00
        213 | Dr. Wright         | 257-3393   | 35000.00
        784 | Dr. Scango         | 257-3046   | 32098.00
        560 | Dr. Olsen          | 257-8086   | 31778.00
        290 | Dr. Lowe           | 257-2390   | 31450.00
        180 | Dr. Cooke          | 257-8088   | 29560.00
        303 | Dr. Horn           | 257-3049   | 27540.00
(7 rows)
```
