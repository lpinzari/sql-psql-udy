# Modifying PostgreSQL VIEW

To modify a view, either adding new columns to the view or removing columns from a view, you use the same **CREATE OR REPLACE VIEW** statement.

```SQL
CREATE OR REPLACE view_name AS
SELECT-statement;
```

PostgreSQL **does not support removing an existing column in the view**, at least up to version `9.4`. If you try to do it, you will get an error message: “[Err] ERROR:  cannot drop columns from view”. The query must generate the same columns that were generated when the view was created. To be more specific, the new columns must have the same names, same data types, and in the same order as they were created. However, PostgreSQL **allows you to append additional columns at the end of the column list**.

For example, the following statement changes the `payroll` **view**:

```SQL  
CREATE VIEW payroll (first_name , last_name , job, compensation) AS
       SELECT first_name, last_name, job_title, salary
         FROM employees e
        INNER JOIN jobs j
           ON j.job_id= e.job_id
     ORDER BY first_name;
```

by `adding the department column` and `rename` **the compensation column to salary column**.

```SQL
CREATE OR REPLACE VIEW payroll (first_name , last_name , job , department , salary) AS
       SELECT first_name, last_name, job_title, department_name, salary
         FROM employees e
        INNER JOIN jobs j
           ON j.job_id = e.job_id
        INNER JOIN departments d
           ON d.department_id = e.department_id
     ORDER BY first_name;
```

For example, you can add an `email` to the **customer_master**  view

```SQL
CREATE VIEW customer_master AS
       SELECT cu.customer_id AS id,
              cu.first_name || ' ' || cu.last_name AS name,
              a.address,
              a.postal_code AS "zip code",
              a.phone,
              city.city,
              country.country,
              CASE
                   WHEN cu.activebool THEN 'active'
                   ELSE ''
              END AS notes,
              cu.store_id AS sid
        FROM customer cu
       INNER JOIN address a USING (address_id)
       INNER JOIN city USING (city_id)
       INNER JOIN country USING (country_id);
```
as follows:

```SQL
CREATE OR REPLACE VIEW customer_master AS
       SELECT cu.customer_id AS id,
              cu.first_name || ' ' || cu.last_name AS name,
              a.address,
              a.postal_code AS "zip code",
              a.phone,
              city.city,
              country.country,
              CASE
                   WHEN cu.activebool THEN 'active'
                   ELSE ''
              END AS notes,
              cu.store_id AS sid
              cu.email
        FROM customer cu
       INNER JOIN address a USING (address_id)
       INNER JOIN city USING (city_id)
       INNER JOIN country USING (country_id);
```

To change the definition of a view, you use the `ALTER VIEW` statement. For example, you can **change the name of the view** from `customer_master` to `customer_info` by using the following statement:

```SQL
ALTER VIEW customer_master RENAME TO customer_info;
```
PostgreSQL allows you to set a default value for a column name, change the view’s schema, set or reset options of a view. For detailed information on the altering view’s definition, check it out the [PostgreSQL ALTER VIEW](https://www.postgresqltutorial.com/postgresql-views/managing-postgresql-views/) statement.
