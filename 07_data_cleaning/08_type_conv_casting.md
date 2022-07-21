# Type CONVERSIONS and CASTING

Every field in a database is defined with a data type, which we reviewed at the begin‐ ning of this chapter. When data is inserted into a table, values that aren’t of the field’s type are rejected by the database. Strings can’t be inserted into integer fields, and boo‐ leans are not allowed in date fields. Most of the time, we can take the data types for granted and apply string functions to strings, date functions to dates, and so on. Occasionally, however, we need to override the data type of the field and force it to be something else. This is where type conversions and casting come in.

**Type conversion functions** allow pieces of data with the appropriate format to be changed from one data type to another. The syntax comes in a few forms that are basically equivalent. One way to change the data type is with the cast function, `cast (input as data_type)`, or two colons, input `:: data_type`. Both of these are equivalent and convert the integer 1,234 to a string:

```SQL
cast (1234 as varchar)
    1234::varchar
```

Converting an integer to a string can be useful in CASE statements when categorizing numeric values with some unbounded upper or lower value. For example, in the fol‐ lowing code, leaving the values that are less than or equal to 3 as integers while returning the string “4+” for higher values would result in an error:

```SQL
case when order_items <= 3 then order_items
         else '4+'
end
```
Casting the integers to the VARCHAR type solves the problem:

```SQL
    case when order_items <= 3 then order_items::varchar
         else '4+'
end
```

Type conversions also come in handy when values that should be integers are parsed out of a string, and then we want to aggregate the values or use mathematical functions on them. Imagine we have a data set of prices, but the values include the dollar sign ($), and so the data type of the field is VARCHAR.

```SQL
SELECT replace('$19.99','$','');
    replace
    -------
    9.99
```

The result is still a VARCHAR, however, so trying to apply an aggregation will return an error. To fix this, we can cast the result as a FLOAT:

```SQL
    replace('$19.99','$','')::float
    cast(replace('$19.99','$','')) as float
```

Dates and datetimes can come in a bewildering array of formats, and understanding how to cast them to the desired format is useful.

As a simple example, imagine that transaction or event data often arrives in the database as a TIMESTAMP, but we want to summarize some value such as transac‐ tions by day. Simply grouping by the timestamp will result in more rows than necessary. Casting the TIMESTAMP to a DATE reduces the size of the results and achieves our summarization goal:

```SQL
SELECT tx_timestamp::date, count(transactions) as num_transactions
    FROM ...
    GROUP BY 1;
```

Likewise, a DATE can be cast to a TIMESTAMP when a SQL function requires a TIMESTAMP argument. Sometimes the year, month, and day are stored in separate columns, or they end up as separate elements because they’ve been parsed out of a longer string. These then need to be assembled back into a date. To do this, we use the concatenation operator || (double pipe) or concat function and then cast the result to a DATE. Any of these syntaxes works and returns the same value:

```SQL
 (year || ',' || month|| '-' || day)::date
```

Or equivalently:

```SQL
cast(concat(year, '-', month, '-', day) as date)
```

Yet another way to convert between string values and dates is by using the date func‐
tion. For example, we can construct a string value as above and convert it into a date:

```SQL
date(concat(year, '-', month, '-', day))
```

The `to_datatype` functions can take both a value and a format string and thus give you more control over how the data is converted.

|Function| Purpose|
|:-------:|:-----:|
|to_char| Converts other types to string|
|to_number| Converts other types to numeric|
|to_date| Converts other types to date, with specified date parts|
|to_timestamp| Converts other types to date, with specified date and time parts|

Sometimes the database automatically converts a data type. This is called type coer‐ cion. For example, INT and FLOAT numerics can usually be used together in mathe‐ matical functions or aggregations without explicitly changing the type. CHAR and VARCHAR values can usually be mixed. Some databases will coerce BOOLEAN fields to 0 and 1 values, where 0 is FALSE and 1 is TRUE, but some databases require you to convert the values explicitly. Some databases are pickier than others about mixing dates and datetimes in result sets and functions. You can read through the documentation, or you can do some simple query experiments to learn how the database you’re working with handles data types implicitly and explicitly. There is usually a way to accomplish what you want, though sometimes you need to get crea‐ tive in using functions in your queries.
