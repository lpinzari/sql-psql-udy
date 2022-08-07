# Translate

The PostgreSQL `TRANSLATE()` function performs several single-character, one-to-one translation in one operation.

## Syntax

The following illustrates the syntax of the PostgreSQL `TRANSLATE()` function:

```SQL
TRANSLATE(string, from, to)
```

### Arguments

The PostgreSQL `TRANSLATE()` function accepts three arguments:

1. **string**
is a string subjected to translation.

2. **from**
is a set of characters in the first argument (`string`) that should be replaced.

3. **to**
is a set of characters that replaces the `from` in the string.

Notice that if `from` is longer than `to`, the `TRANSLATE()` function removes the occurrences of the extra characters in `from`.

### Return value

The PostgreSQL `TRANSLATE()` function returns a string with the characters in the one set of characters are replaced by another set of characters.

## Examples

Let’s see some examples of using the `TRANSLATE()` function to understand how it works.

- **A) Simple TRANSLATE() example**

See the following statement:

```SQL
SELECT TRANSLATE('12345', '134', 'ax');
```

In this example:

- The character '`1`' in string '`12345`' is substituted by character '`a`', The character '`3`' in the string '`12345`' is substituted by the character '`x`'.
- Because the string '`134`' has more characters than the string '`ax`', the `TRANSLATE()` function removes the extra character in the string '`134`', which is '`4`', from the string '`12345`'.

The following illustrates the result:

|translate|
|:---------:|
|a2x5|

- **B) Single character replacement**

The following example shows how to use the `TRANSLATE()` function to replace comma (`,`) by a semi-colon (`;`) in a comma-separated values list.

```SQL
SELECT TRANSLATE('apple,orange,banana', ',', ';');
```

|translate|
|:-------------------:|
|apple;orange;banana|

- **C) Encrypting and decrypting a message**

The following example shows how to use the `TRANSLATE()` function to encrypt a message:

```SQL
SELECT TRANSLATE('a secret message',
                 'abcdefghijklmnopqrstuvxyz',
                 '0123456789acwrvyuiopkjhbq');
```


|translate|
|:----------------:|
|0 o42i4p w4oo064|

You can also decrypt the message '`0 o42i4p w4oo064`' using the function:

```SQL
SELECT TRANSLATE('0 o42i4p w4oo064',
                     '0123456789acwrvyuiopkjhbq',
                     'abcdefghijklmnopqrstuvxyz');
```

|translate|
|:----------------:|
|a secret message|
