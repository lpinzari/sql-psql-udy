# Data Types

Relational databases store data. Every element of that stored data must be of some **type**. Most generally,a

- **type** can be thought of as just a **well-defined group of values**.

A familiar example is the type *integer*, whose values are whole numbers such as 42 and -1.

In every table, each `column` (and thus every field in every record) **stores only data of a certain type**.

SQL precisely defines the data types that can be stored in its tables. As with other parts of the language, however, the types supported by different SQL systems vary. Those defined by the **ISO/ANSI** standard are listed below.

| DATA TYPE | DESCRPTION|
|:----------| :---------|
|**CHARACTER**| Fixed-length character data|
|**CHARACTER VARYING**| Variable-length character data|
|**NUMERIC**| Decimal numbers|
|**DECIMAL**| Decimal numbers|
|**INTEGER**| Integer numbers|
|**SMALLINT**| Small integer numbers|
|**BIT**| Fixed-length bit string|
|**BIT VARYING**| Variable-length bit string|
|**FLOAT**| Floating point numbers|
|**REAL**| Low-precision floating point numbers|
|**DOUBLE PRECISION**| High-precision floating point numbers|
|**DATE**| Calendar date|
|**TIME**| Clock time|
|**TIMESTAMP**| Date and time|
|**INTERVAL**| Time interval|


- **CHARACTER** (`CHAR`): Columns of this type contain strings of characters. A `CHAR` column has a length, specified when the table is created. The amount of storage required to store a string of the length specified is allocated for each record in the table, regardless of the actual length of the string.
- **CHARACTER VARYING** (`VARCHAR`): Like `CHAR` columns, `VARCHAR` columns contain strings of characters, but the length specified when the table is created specifies the maximum length of the string rather than the storage to be allocated. The system can allocate only the amount of space required for the actual string stored in each record. And rather than using this long name in its entirety, the abbreviation `VARCHAR` is allowed.
- **NUMERIC**:  As is ovious from their name, `NUMERIC` columns contain numbers. When a table is created, its creator may specify the *precision*, i.e., the number of decimal digits that must be stored, of each `NUMERIC` column. For example, numbers up to `99,999` could be stored in a `NUMERIC(5)` column. A *scale* may also be specified, indicating the number of digits to the right of the decimal point. For example, a column that must be able to store the values `1.00` to `9.99` would be defined as `NUMERIC(3,2)`,i.e., 3 digits in total, with two to the right of the decimal point.
- **DECIMAL**: `DECIMAL` is very similar to `NUMERIC`, and in fact many SQL implementations define it as synonym.
- **INTEGER** (`INT`): Yet another slight variation on the `NUMERIC` theme, `INTEGER` also has a *pecision* and a *scale*. This time, however, the *precision* is implementation-defined, and the *scale* is always 0. `INTEGER` can be abbreviated as just `INT`.
- **SMALLINT**: Like `INT`, `SMALLINT` has implementation-defined *precision* and a *scale* of 0. The only difference between the two types is that SMALLINT's *precision* may be less than INTEGER's in any given implementation. (Note that this leaves open the possibility that one system's SMALLINT is actually larger than another's INTEGER.)
- **BIT**: Columns of this type contain a specified number of bits of data. The database makes no attempt to interpret these bits, leaving that up to the application.
- **BIT VARYING**: Like `BIT` columns, columns defined as `BIT VARYING` contain bits of data that are not interpreted by the database. Like `VARCHAR` columns, only the actual number of bits required by each record can be allocated.
- **FLOAT**: Columns of this type contain floating point (real) numbers. (Actually, they contain approximations of floating point numbers. FLOAT, REAL, and DOUBLE PRECISION are all considered *approximate* numeric types, while NUMBER, DECIMAL, INTEGER, and SMALLINT are all *exact* numeric.) A table's creator may again specify a *precision* for the values kept in this type of column.
- **REAL**: another type for floating point numbers, REAL differs from FLOAT in that its *precision* is implementation-defined.
- **DOUBLE PRECISION**: Yet another type for floating point numbers, DOUBLE PRECISION has implementation-defined *precision* like REAL. As with SMALLINT and INTEGER, however, the *precision* of REAL may be less then of DOUBLE PRECISION.
- **DATE**: Not surprisingly, columns of this type contain values that represent calendar dates.
- **TIME**: Columns of type contain values representing clock times, expressed in hours, minutes and seconds. When a TIME column is created, its creator may specify a *precision*, which determines the number of fractions of a second to be stored. The maximum value for a TIME column's precision is implementation-specific, but it *must be at least 6*. If no precision is specified, the default value is 0. Additionally, TIME columns may support a WITH TIME ZONE modifier. This modifier specifies that the time values will be stored internally in *Coordinated Universal Time* (known by the not-very-intuitive acronym UTC), which corresponds to what used to be called Greenwich Mean Time (GMT). TIME values with time zone modifiers are specified with an offset from UTC. For example, -8 is the normal time zone offset of San Francisco, California.
- **TIMESTAMP**: Columns defined as a TIMESTAMP combine both a calendar date and a clock time. Like TIME columns, TIMESTAMP columns can include a WITH TIME ZONE modifier. Note that some implementations use the term DATETIME to define this data type, and restrict the use of TIMESTAMP to indicate a DATETIME column whose value is assigned by the system when a row is inserted, and updated when any column in the row is updated.
- **INTERVAL**: Columns of this type represent intervals between either year-months or day-times. INTERVAL columns are defined with a *start* modifier. Permitted modifiers are YEAR, MONTH, DAY, HOUR, MINUTE and SECOND. Optionally, these columns may also include a TO end modifier, which must be smaller than the start modifier. For example, a column defined as INTERVAL DAY could store intervals such as "3 days" or "263 days", while one defined as INTERVAL MONTH TO DAY could store intervals such as "4 months and 6 days" or "18 months and 3 days".

## NULL

One other kind of information can be stored in a record's fields - the value **NULL**. **NULL** doesn't really belong to any type, but instead **represents the lack of a value**. Any field of any type can have the value **NULL** assigned to it (unless NULLs are explicitly barred from that field when it is created). NULL is not the same thing as the INTEGER value 0, or as a CHARACTER value of a blank, or even as a CHARACTER string of zero length.

**NULL** is simply **NULL**, a unique "value" indicating the **absence of a normal value** in a particular field.
