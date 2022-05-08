# Intro To Logical Operators

In the next concepts, you will be learning about Logical Operators.

A logical operator allows you to test for the truth of a condition. Similar to a `comparison operator`, a **logical operator returns a value** of
- true,
- false, or
- unknown.

The following table illustrates the SQL **logical operators**:

|Operator|	Meaning|
|:------:|:-------:|
|**ALL**|	Return true if `all` comparisons are true|
|**AND**|	Return true if `both` expressions are true|
|**ANY**|	Return true if `any` one of the comparisons is true|
|**BETWEEN**|	Return true if the operand is `within a range`|
|**EXISTS**|	Return true if a `subquery contains any rows`|
|**IN**|	Return true if the `operand is equal to one of the value in a list`|
|**LIKE**|	Return true if the `operand matches a pattern`|
|**NOT**|	`Reverse the result` of `any other Boolean operator`|
|**OR**|	Return true if `either expression is true`|
|**IS NULL**| Return true if a value is unknown|
|**IS NOT NULL**| Return true if a values is not unknown|

The `ALL`, `ANY` and `EXISTS` are often used in subquery and will be introduced in the next module.


In this module we introduce the following operators:

- **LIKE**: This allows you to perform operations similar to using `WHERE` and `=`, but for cases when **you might not know exactly what you are looking for**.
- **IN**: This allows you to perform operations similar to using `WHERE` and `=`, but for **more than one condition**.
- **NOT**: This is used with `IN` and `LIKE` to **select all of the rows** `NOT LIKE` or `NOT IN` a certain condition.
- **AND** & **BETWEEN**: These allow you to **combine operations** where **all combined conditions must be true**.
- **OR**: This allows you to **combine operations** where **at least one of the combined conditions must be true**.

Don't worry if this doesn't make total sense right now. You will get practice with each in the next sections.

First, we introduce the basic logical operators:

- `AND`
- `OR`
- `NOT`

Next, we introduce the following operators:

- `LIKE` and `NOT LIKE`
- `IN` and `NOT IN`
- `BETWEEN` and `NOT BETWEEN`, and combination of operators.

Lastly, the `IS NULL` and `IS NOT NULL` operators conclude this first introduction to logical operators.
