# Extracting Initials from a Name

You want **convert a full name into initials**.

## Problem

Consider the following name:

- **S**tewie **G**riffin

You would like to return:

- **S**`.`**G**`.`

## Solution

The solutions presented here expect the names to be either first and last name, or first, middle name/middle initial, and last name.

**Oracle and PostgreSQL**

Use the built-in functions `REPLACE`, `TRANSLATE`, and `RPAD` to extract the initials:

```SQL
SELECT REPLACE(
          REPLACE(
            TRANSLATE(REPLACE('Stewie Griffin.', '.', ''),
                      'abcdefghijklmnopqrstuvwxyz',
                      rpad('#',26,'#') ),
                 '#','' ),
              ' ','.' ) || '.' AS initials;
```

|initials|
|----------|
|S.G.|

## Discussion

By isolating the capital letters, you can extract the initials from a name.

The `REPLACE` function will remove any periods in the name (to handle middle ini‐ tials).

```SQL
SELECT REPLACE('Stewie Griffin.', '.', '');
```

|replace|
|:--------------:|
|Stewie Griffin|

 the `TRANSLATE` function will convert all non-uppercase letters to `#`.

 ```SQL
SELECT TRANSLATE(REPLACE('Stewie Griffin.', '.', ''),
                'abcdefghijklmnopqrstuvwxyz',
                 rpad('#',26,'#') );
```

|translate|
|:--------------:|
|S##### G######|

At this point, the initials are the characters that are not `#`. The function `REPLACE` is then used **to remove all the** `#` characters:

```SQL
SELECT REPLACE(
       TRANSLATE(REPLACE('Stewie Griffin.', '.', ''),
                'abcdefghijklmnopqrstuvwxyz',
                 rpad('#',26,'#') ),
               '#','' );
```

|replace|
|:-------:|
|S G|

The next step is to replace the white space with a period by using `REPLACE` again:

```SQL
SELECT REPLACE(
          REPLACE(
            TRANSLATE(REPLACE('Stewie Griffin.', '.', ''),
                      'abcdefghijklmnopqrstuvwxyz',
                      rpad('#',26,'#') ),
                 '#','' ),
              ' ','.' );
```

|replace|
|:-------:|
|S.G|

The final step is to append a decimal to the end of the initials.

```SQL
SELECT REPLACE(
          REPLACE(
            TRANSLATE(REPLACE('Stewie Griffin.', '.', ''),
                      'abcdefghijklmnopqrstuvwxyz',
                      rpad('#',26,'#') ),
                 '#','' ),
              ' ','.' ) || '.' AS initials;
```

|initials|
|----------|
|S.G.|
