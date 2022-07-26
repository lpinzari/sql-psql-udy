# ENABLE TRIGGEER

To enable a trigger or all triggers associated with a table, you use the **ALTER TABLE ENABLE TRIGGER** statement:

```SQL
ALTER TABLE table_name
ENABLE TRIGGER trigger_name |  ALL;
```

In this syntax:

- First, specify the name of the table of the trigger that you want to enable.
- Second, specify the name of the trigger that you want to enable or use `ALL` option if you want to enable all triggers associated with the table.

A disabled trigger doesn’t fire when the triggering event occurs. To make it fired, you need to enable it.

## Enabling trigger example

The following statement enables the `salary_before_update` trigger on the `employees` table:

```SQL
ALTER TABLE employees
ENABLE TRIGGER salary_before_update;
```

The following example enables all triggers that belong to the `employees` table:

```SQL
ALTER TABLE employees
ENABLE TRIGGER ALL;
```
