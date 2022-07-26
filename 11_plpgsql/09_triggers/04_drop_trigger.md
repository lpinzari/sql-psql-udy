# DROP TRIGGER

To **delete a trigger from a table**, you use the `DROP TRIGGER` statement with the following syntax:

```SQL
DROP TRIGGER [IF EXISTS] trigger_name
ON table_name [ CASCADE | RESTRICT ];
```

In this syntax:

- First, specify the `name` of the trigger which you want to delete after the `DROP TRIGGER` keywords.

- Second, use `IF EXISTS` to conditionally delete the trigger only if it exists. Attempt to delete a non-existing trigger without specifying the `IF EXISTS` statement results in an error. If you use `IF EXISTS` to delete a non-existing trigger, PostgreSQL issues a notice instead.

- Third, specify `the name of the table` to which the trigger belongs. If the table belongs to a specific schema, you can use the schema-qualified name of the table e.g., `schema_name.table_name`.

- Fourth, use the `CASCADE` option if you want to drop objects that depend on the trigger automatically. Note that `CASCADE` option will also delete objects that depend on objects that depend on the trigger.

- Fifth, use the `RESTRICT` option to refuse to drop the trigger if any objects depend on it. By default, the `DROP TRIGGER` statement uses `RESTRICT`.

## PostgreSQL DROP TRIGGER example

First, create a function that validates the username of a staff. The username of staff must not be null and its length must be at least 8.

```SQL
CREATE FUNCTION check_staff_user()
    RETURNS TRIGGER
AS $$
BEGIN
    IF length(NEW.username) < 8 OR NEW.username IS NULL THEN
        RAISE EXCEPTION 'The username cannot be less than 8 characters';
    END IF;
    IF NEW.NAME IS NULL THEN
        RAISE EXCEPTION 'Username cannot be NULL';
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;
```

Second, create a new trigger on the staff table to check the username of a staff. This trigger will fire whenever you `insert` or `update` a row in the `staff` table (from the sample database):

```SQL
CREATE TRIGGER username_check
    BEFORE INSERT OR UPDATE
ON staff
FOR EACH ROW
    EXECUTE PROCEDURE check_staff_user();
```

Third, use the `DROP TRIGGER` statement to delete the `username_check` trigger:

```SQL
DROP TRIGGER username_check
ON staff;
```
