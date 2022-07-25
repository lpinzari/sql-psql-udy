# Recursive Views

PostgreSQL 9.3 added a new syntax for creating recursive views specified in the standard SQL. The **CREATE RECURSIVE VIEW** statement is syntax sugar for a `standard recursive query`. See the chapter of `CTE` in this course.

The following illustrates the `CREATE RECURSIVE VIEW` syntax:

```SQL
CREATE RECURSIVE VIEW view_name(columns) AS
       SELECT columns;
```

- First, specify the name of the view that you want to create in the `CREATE RECURSIVE VIEW` clause. You can add an optional schema-qualified to the name of the view.

- Second, add the `SELECT` statement to query data from base tables. The `SELECT` statement references the `view_name` to make the view recursive.

This statement above is equivalent to the following statement:

```SQL
CREATE VIEW view_name AS
  WITH RECURSIVE cte_name (columns) AS (
       SELECT ...
)

SELECT columns FROM cte_name;
```

## Creating recursive view example

We will use the `employees` table created in the [recursive query](../05_subquery_cte/08_recursive_query.md) tutorial for the demonstration.

The following recursive query returns the `employee` and their `managers` up to the **CEO level using a common table expression or CTE**.

```SQL
WITH RECURSIVE reporting_line AS (
     SELECT employee_id,
            full_name AS subordinates
       FROM employees
      WHERE manager_id IS NULL
  UNION ALL
     SELECT e.employee_id,
            (
              rl.subordinates || ' > ' || e.full_name
            ) AS subordinates
       FROM employees e
      INNER JOIN reporting_line rl
         ON e.manager_id = rl.employee_id
)

SELECT employee_id,
       subordinates
  FROM reporting_line
 ORDER BY employee_id;
```

**Results**

|employee_id |                         subordinates|
|:----------:|-------------------------------------------------------------:|
|          1 | Michael North|
|          2 | Michael North > Megan Berry|
|          3 | Michael North > Sarah Berry|
|          4 | Michael North > Zoe Black|
|          5 | Michael North > Tim James|
|          6 | Michael North > Megan Berry > Bella Tucker|
|          7 | Michael North > Megan Berry > Ryan Metcalfe|
|          8 | Michael North > Megan Berry > Max Mills|
|          9 | Michael North > Megan Berry > Benjamin Glover|
|         10 | Michael North > Sarah Berry > Carolyn Henderson|
|         11 | Michael North > Sarah Berry > Nicola Kelly|
|         12 | Michael North > Sarah Berry > Alexandra Climo|
|         13 | Michael North > Sarah Berry > Dominic King|
|         14 | Michael North > Zoe Black > Leonard Gray|
|         15 | Michael North > Zoe Black > Eric Rampling|
|         16 | Michael North > Megan Berry > Ryan Metcalfe > Piers Paige|
|         17 | Michael North > Megan Berry > Ryan Metcalfe > Ryan Henderson|
|         18 | Michael North > Megan Berry > Max Mills > Frank Tucker|
|         19 | Michael North > Megan Berry > Max Mills > Nathan Ferguson|
|         20 | Michael North > Megan Berry > Max Mills > Kevin Rampling|

You can use the `CREATE RECURSIVE VIEW` statement to convert the query into a recursive view as follows:

```SQL
CREATE RECURSIVE VIEW reporting_line (employee_id, subordinates) AS
       SELECT employee_id,
	            full_name AS subordinates
         FROM employees
        WHERE manager_id IS NULL
    UNION ALL
	     SELECT e.employee_id,
              (
                rl.subordinates || ' > ' || e.full_name
              ) AS subordinates
	       FROM employees e
        INNER JOIN reporting_line rl
           ON e.manager_id = rl.employee_id;
```

To see the reporting line of the employee id `10`, you query directly from the view:

```SQL
SELECT subordinates
  FROM reporting_line
 WHERE employee_id = 10;
```

**Results**

|subordinates|
|:-----------------------------------------------:|
|Michael North > Sarah Berry > Carolyn Henderson|
