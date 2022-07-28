# CREATE PROCEDURE

So far, you have learned how to define user-defined functions using the create function statement.

A `drawback` of **user-defined functions** is that **they cannot execute transactions**. In other words, inside a user-defined function, **you cannot start a transaction, and commit or rollback it**.

PostgreSQL 11 introduced **stored procedures** that **support transactions**.

To define a new stored procedure, you use the `create procedure` statement.

The following illustrates the basic syntax of the `create procedure` statement:

```SQL
create [or replace] procedure procedure_name(parameter_list)
language plpgsql
as $$
declare
-- variable declaration
begin
-- stored procedure body
end; $$
```

In this syntax:

- First, specify the `name` of the stored procedure after the `create procedure` keywords.
- Second, define `parameters` for the stored procedure. A stored procedure can accept zero or more parameters.
- Third, specify `plpgsql` as the procedural language for the stored procedure. Note that you can use other procedural languages for the stored procedure such as SQL, C, etc.
- Finally, use the `dollar-quoted string constant syntax` to define the body of the stored procedure.

`Parameters` in stored procedures can have the `in` and `inout` modes. **They cannot have the out mode**.

A `stored procedure` **does not return a value**. You cannot use the `return` statement with a value inside a store procedure like this:

```SQL
return expression;
```

However, you can use the return statement without the expression to stop the stored procedure immediately:

```SQL
return;
```

If you want to return a value from a stored procedure, you can use parameters with the `inout` mode.

## PostgreSQL CREATE PROCEDURE statement examples

We will use the following `accounts` table for the demonstration:

```SQL
drop table if exists accounts;

create table accounts (
    id int generated by default as identity,
    name varchar(100) not null,
    balance dec(15,2) not null,
    primary key(id)
);

insert into accounts(name,balance)
values('Bob',10000);

insert into accounts(name,balance)
values('Alice',10000);
```

The following statement shows the data from the `accounts` table:

```SQL
select * from accounts;
```

|id | name  | balance|
|:--:|:----:|:-------:|
| 1 | Bob   | 10000.00|
| 2 | Alice | 10000.00|

The following example creates a stored procedure named transfer that transfers a specified amount of money from one account to another.

```SQL
create or replace procedure transfer(
   sender int,
   receiver int,
   amount dec
)
language plpgsql    
as $$
begin
    -- subtracting the amount from the sender's account
    update accounts
    set balance = balance - amount
    where id = sender;

    -- adding the amount to the receiver's account
    update accounts
    set balance = balance + amount
    where id = receiver;

    commit;
end;$$;
```

## Calling a stored procedure

To call a stored procedure, you use the CALL statement as follows:

```SQL
call stored_procedure_name(argument_list);
```

For example, this statement invokes the transfer stored procedure to transfer `$1,000` **from Bob’s account to Alice’s account**.

```SQL
call transfer(1,2,1000);
```

The following statement verifies the data in the accounts table after the transfer:

```SQL
SELECT * FROM accounts;
```

|id | name  | balance|
|:--:|:----:|:--------:|
| 1 | Bob   |  9000.00|
| 2 | Alice | 11000.00|

## Summary

- Use create procedure statement to define a new stored procedure.
- Use the call statement to invoke a stored procedure.