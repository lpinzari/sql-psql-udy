# DISABLE TRIGGER

To disable a trigger, you use the **ALTER TABLE DISABLE TRIGGER** statement:

```SQL
ALTER TABLE table_name
DISABLE TRIGGER trigger_name | ALL
```

In this syntax,

- First, specify the `name` of the table, which the trigger is associated with, after the `ALTER TABLE` keywords.
- Second, specify the `name` of the trigger that you want to disable after the `DISABLE TRIGGER` keywords or use the `ALL` keyword to disable all triggers associated with the table.

When you disable a trigger, the trigger still exists in the database. However, the disabled trigger will not fire when an event associated with the trigger occurs.

Suppose you want to disable the trigger associated with the `employees` table, you can use the following statement:

```SQL
ALTER TABLE employees
DISABLE TRIGGER log_last_name_changes;
```

To disable all triggers associated with the `employees` table, you use the following statement:

```SQL
ALTER TABLE employees
DISABLE TRIGGER ALL;
```
