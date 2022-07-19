# CHR FUNCTION

The PostgreSQL **CHR()** function **converts an integer** `ASCII` **code to a character or a Unicode code point to a** `UTF8` **character**.

The following shows the syntax of the `CHR()` function:

```SQL
CHR(num)
```

## Arguments

The `CHR()` function requires one argument:

1. **num**: The `num` argument is an **integer that is converted to the corresponding ASCII code**.

It could be a Unicode code point which is converted to a `UTF8` **character**.

## Return Value

The **CHR()** function **returns a character which is corresponding the the ASCII code value or Unicode code point**.

## Examples

The following example shows how to use the `CHR()` function to get the characters whose **ASCII code** value is `65` and `97`:

```SQL
SELECT
    CHR(65) AS six_five,
    CHR(97) AS nine_seven;
```

**Results**

|six_five | nine_seven|
|:-------:|:-----------:|
|A        | a|

The query returns character `A` for **65** and `a` for **97**.

Here is an example of getting the `UTF8` character based on the `Unicode code point` **937**:

```SQL
SELECT
    CHR(937) AS nine_three_seven;
```

**Results**

|nine_three_seven|
|:----------------:|
|Ω|

The output for the `Unicode code point` **937** is **Ω**, which is what we expected.
