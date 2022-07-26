# Errors and Messages

To raise a message, you use the raise statement as follows:

```SQL
raise level format;
```

Let’s examine the raise statement in more detail.

## Level

Following the `raise` statement is the `level` option that specifies the error severity.

PostgreSQL provides the following levels:

- `debug`
- `log`
- `notice`
- `info`
- `warning`
- `exception`

If you don’t specify the level, by default, the raise statement will use exception level that raises an `error` and stops the current transaction. We will discuss the `raise exception` later in the next section.

# Format

The format is a **string that specifies the message**. The format uses percentage (`%`) **placeholders** that will be substituted by the arguments.

The **number of placeholders must be the same as the number of arguments**, otherwise, PostgreSQL will issue an error:

```SQL
[Err] ERROR:  too many parameters specified for raise
```

The following example illustrates the `raise` statement that reports different messages at the current time.

```SQL
do $$
begin
  raise info 'information message %', now() ;
  raise log 'log message %', now();
  raise debug 'debug message %', now();
  raise warning 'warning message %', now();
  raise notice 'notice message %', now();
end $$;
```

Output:

```console
info:  information message 2015-09-10 21:17:39.398+07
warning:  warning message 2015-09-10 21:17:39.398+07
notice:  notice message 2015-09-10 21:17:39.398+07
```

> Notice that not all messages are reported back to the client. PostgreSQL only reports the `info`, `warning`, and `notice` level messages back to the client. This is controlled by `client_min_messages` and `log_min_messages` configuration parameters.

## Raising errors

To **raise an error**, you use the `exception` level after the raise statement. Note that raise statement uses the `exception` level by **default**.

Besides raising an error, you can add more information by using the following additional clause:

```SQL
using option = expression
```

The `option` can be:

- `message`: set error message
- `hint`: provide the hint message so that the root cause of the error is easier to be discovered.
- `detail`:  give detailed information about the error.
- `errcode`: identify the error code, which can be either by condition name or directly five-character SQLSTATE code. Please refer to the [table of error codes and condition names](https://www.postgresql.org/docs/current/errcodes-appendix.html).

The `expression` is a string-valued expression. The following example raises a duplicate email error message:

```SQL
do $$
declare
  email varchar(255) := 'info@postgresqltutorial.com';
begin
  -- check email for duplicate
  -- ...
  -- report duplicate email
  raise exception 'duplicate email: %', email
		using hint = 'check the email again';
end $$;
```

```console
[Err] ERROR:  Duplicate email: info@postgresqltutorial.com
HINT:  Check the email again
```

The following examples illustrate how to raise an `SQLSTATE` and its corresponding condition:

```SQL
do $$
begin
	--...
	raise sqlstate '2210b';
end $$;
```

```SQL
do $$
begin
	--...
	raise invalid_regular_expression;
end $$;
```

Now you can use raise statement to either raise a message or report an error.
