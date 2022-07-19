# ASCII FUNCTION

The PostgreSQL `ASCII()` function returns an **ASCII code value of a character**. In the case of `UTF-8`, the `ASCII()` function returns the **Unicode code point of the character**.

The following illustrates the syntax of ASCII function:

```SQL
ASCII(char)
```

## Arguments

The **ASCII()** function requires one argument:

1. **char**: The `char` argument is a character that you want to get the ASCII code.

If you pass a `string` to the `ASCII()` function, it will return the `ASCII code of the first character`.

## Return value

The `ASCII()` function returns an **integer that represents the** `ASCII` **code value of the input character**. In the case of a UTF-8 character, it returns an integer which is corresponding to the Unicode code point.

## Examples

The following example uses the `ASCII()` function to get the ASCII code values of character `A` and `a`:

```SQL
SELECT
    ASCII( 'A' ) AS capital_a,
    ASCII( 'a' ) AS lower_a;
```

The output is:

|capital_a  | lower_a|
|:---:|:---:|
| 65 | 97|

If you pass a sequence of characters to the ASCII() function, you will get the ASCII code of the first character as shown in the following example:

```SQL
SELECT
    ASCII( 'ABC' ) As initial;
```

**Results**

|initial|
|:---:|
| 65 |

The following example illustrates how to use the `ASCII()` function to **get the Unicode code point of a** `UTF-8 character`:

```SQL
SELECT
   ASCII( 'Ω' ) AS ascii;
```

**Results**

|ascii|
|:---:|
| 937 |
