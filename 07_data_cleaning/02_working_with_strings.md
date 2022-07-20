# Working with Strings

In general, **cleaning categorical attributes** means making sure that one and only one name (string) represents each category. One does not want small, irrelevant differences (like letters being uppercase or lowercase) to interfere with tasks like grouping or searching for values.
Because strings can be used to represent many diverse values, there are no hard and fast rules about how to deal with strings. Ideally, one would like to make sure that the strings being used are `standardized`, that is, **they use a set of standard names so that no confusion can occur**. This is easy in the case of closed (enumerated) domains; for others, the best approach is to come up with a set of conventions that are followed through the analysis.

## String functions are used to put string values in an appropriate format.

There are many string functions, and unfortunately different systems may express them in slightly different ways. Instead of trying to go over each possibility, we organize the functions by what they do and give some examples of each type, focusing on commonly used functions that are present in PostgreSQL:

- Functions that **clean the string**: they change it by **getting rid of certain characters or transforming existing characters**. Among them are `TRIM()`, `LOWER()`, and `UPPER()`. The inverse of this (adding characters to a string) is called padding, expressed with `LPAD()`, `RPAD()`, and others.
- Functions that **find elements** (characters or substrings) **within a given string**. The most popular ones are `POSITION()` and `STRPOS()`.
- Functions that **extract elements of a string or split a string into parts**. This includes functions `SUBSTR()` and `SPLIT()`. The inverse of this (**putting together several strings into a single one**) is usually called concatenation, expressed by `CONCAT()`.
- **Extracting functions include** `LEFT(string, n)`, which gets n characters from the beginning (left) of the string (function `RIGHT(string, n)` does the same from the end of the string). **This function is useful when all string values follow a certain pattern and we need to extract a part of the string based on those patterns**.
- Finally, most functions include the useful function `LENGTH()`, **which returns the number of characters in a string**.

These functions are usually applied to categorical attributes in combination with `UPDATE` so that values are described in a uniform manner; this way, searches do not miss values and grouping works correctly.
