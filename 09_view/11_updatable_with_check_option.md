# Creating Updatable Views Using the WITH CHECK OPTION Clause

In the creating updatable view lesson, you have learned how to create an updatable view that allows you to change the data of the base table through the view.

Let’s take a look at the `city` and `country` tables in the `dvdrental` sample database.

The following statement creates an **updatable view** named `usa_city` that returns all cities in the Untied States.

```SQL
CREATE VIEW usa_city AS
       SELECT city_id,
              city,
              country_id
         FROM city
        WHERE country_id = 103
        ORDER BY city;
```

The following statement inserts a new row into the `city` table through the `usa_city`.

```SQL
INSERT INTO usa_city (city, country_id)
VALUES ('Birmingham', 102);

INSERT INTO usa_city (city, country_id)
VALUES ('Cambridge', 102);
```

The issue is that the **new row inserted is not visible in the view**. It may pose a `security issue` because **we may grant the permission to the users to update the cities in** the `United States`, **not the United Kingdom**.

To prevent users from the insert or update a row that not visible through the view, you use the `WITH CHECK OPTION` clause when creating the view.

Let’s change the `usa_city` view to include the `WITH CHECK OPTION` clause:

```SQL
CREATE OR REPLACE VIEW usa_city AS
   SELECT city_id,
	        city,
	        country_id
     FROM city
    WHERE country_id = 103
    ORDER BY city
    WITH CHECK OPTION;
```

Now, run the following statement to insert another city for the `United Kingdom` country.

```SQL
INSERT INTO usa_city (city, country_id)
VALUES ('Cambridge', 102);
```

PostgreSQL rejected the insert and issued an error.

```console
ERROR:  new row violates check option for view "usa_city"
DETAIL:  Failing row contains (604, Cambridge, 102, 2016-07-02 08:41:01.828561).
```

It works as expected.

The following statement updates the country of the city id `135` to the United Kingdom.

```SQL
UPDATE usa_city
   SET country_id = 102
 WHERE city_id = 135;
```

PostgreSQL rejected the update and issued an error.

```console
ERROR:  new row violates check option for view "usa_city"
DETAIL:  Failing row contains (135, Dallas, 102, 2016-07-02 10:37:27.466176).
```

This is because the `UPDATE` statement causes the row that is being updated not visible through the `usa_city` view.

## The scope of check with LOCAL and CASCADED

First, create a view that returns **all cities with the name starting with the letter** `A`.

```SQL
CREATE VIEW city_a AS
       SELECT city_id,
	            city,
	            country_id
         FROM city
        WHERE city LIKE 'A%';
```

The `city_a` view **does not have** the `WITH CHECK OPTION` clause.

Second, create another view that returns the cities whose name starts with the letter `A` and **locate in the United States**. This `city_a_usa` view is based on the `city_a` view.

```SQL
CREATE OR REPLACE VIEW city_a_usa AS
       SELECT city_id,
	            city,
	            country_id
         FROM city_a
        WHERE country_id = 103
         WITH CASCADED CHECK OPTION;
```

The `city_a_usa` view has the `WITH CASCADED CHECK OPTION` clause. Notice the `CASCADED` option.

The following statement inserts a row into the city table through the `city_a_usa` table.

```SQL
INSERT INTO city_a_usa (city, country_id)
VALUES
	('Houston', 103);
```

PostgreSQL rejected the insert and issued the following error:

```console
ERROR: new row violates check option for view "city_a"
SQL state: 44000
Detail: Failing row contains (605, Houston, 103, 2016-07-02 09:51:40.916855).
```

The error message indicates that the view-defining condition for the `city_a` view was violated **even though the** `city_a` **view does not have the** `WITH CHECK OPTION` clause.

This is because when we used the `WITH CASCADED CHECK OPTION` for the `city_a_usa` view, PostgreSQL checked the view-defining condition of the `city_a_usa` view and also all the underlying views, in this case, it is the `city_a` view. In other words, the `WITH CASCADE CHECK OPTION` is implicitly applied to the `city_a` view.

To check the view-defining condition of the view that you insert or update, you use the `WITH LOCAL CHECK OPTION` as follows:

```SQL
CREATE OR REPLACE VIEW city_a_usa AS
       SELECT city_id,
	            city,
	            country_id
         FROM city_a
        WHERE country_id = 103
         WITH LOCAL CHECK OPTION;
```

Let’s insert a new row into city table via the `city_a_usa` view again.

```SQL
INSERT INTO city_a_usa (city, country_id)
VALUES
	('Houston', 103);
```

It succeeded this time because the new row satisfies the view-defining condition of the `city_a_usa` view. **PostgreSQL did not check the view-defining conditions of the base views**. The record is inserted in the `city` base table.
