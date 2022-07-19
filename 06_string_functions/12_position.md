# Position Function PostgreSQL

The PostgreSQL `POSITION()` function **returns the location of a substring in a string**.

The following illustrates the syntax of the PostgreSQL POSITION() function:

```SQL
POSITION(substring in string)
```
## Arguments

The POSITION() function requires two arguments:

1. **substring**: The substring argument is the string that you want to locate.

2. **string**: The string argument is the string for which the substring is searched.

## Return Value

The `POSITION()` function **returns an integer that represents the location of the substring within the string**.

The `POSITION()` function returns zero (`0`) **if the substring is not found in the string**. It returns `null` if either substring or string argument is null.

## Examples

The following example returns the position of the '`Tutorial`' in the string '`PostgreSQL Tutorial`':

```SQL
SELECT POSITION('Tutorial' IN 'PostgreSQL Tutorial');
```

The result is as follows:

|position|
|:--------:|
|       12|

The initial letter `T` of the world `Tutorial` is in position `12`. Note that the POSITION() function searches for the substring **case-insensitively**.

See the following example:

```SQL
SELECT POSITION('tutorial' IN 'PostgreSQL Tutorial');
```

It returns zero (`0`), indicating that the string tutorial does not exist in the string '`PostgreSQL Tutorial`'.

## Remarks

The `POSITION()` function **returns the location of the first instance of the substring in the string**.

Consider the following example:

```SQL
SELECT POSITION('is' IN 'This is a cat');
```
The result is:

|position|
|:-------:|
|       3|

Even though the substring '`is`' appears **twice in the string** '`This is a cat`', the `POSITION()` function just returned the first match.
