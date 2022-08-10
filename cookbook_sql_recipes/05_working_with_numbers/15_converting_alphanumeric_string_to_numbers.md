# Converting Alphanumeric Strings into Numbers

You have `alphanumeric data` and would like to **return numbers only**.

## Problem

You want to return the number **123321** from the string “`paul123f321.`”


## Solution

Use the functions [TRANSLATE](https://github.com/lpinzari/sql-psql-udy/blob/master/06_string_functions/19_translate.md) and [REPLACE](https://github.com/lpinzari/sql-psql-udy/blob/master/06_string_functions/15_replace.md) to extract numeric characters from an alphanumeric string:

**Solution 1**:

```SQL
SELECT
  CAST (
        REPLACE(
         TRANSLATE( 'paul123f321',
                    'abcdefghijklmnopqrstuvwxyz',
                    RPAD('#',26,'#')),
                '#','')
        AS INTEGER);
```

**Solution 2**:

```SQL
SELECT
   REPLACE (
            TRANSLATE('paul123f321',
                      REPLACE (
                              TRANSLATE('paul123f321',
                                        '0123456789',
                                         RPAD('#',10,'#')),
                               '#',''),
                      RPAD('#',LENGTH('paul123f321'),'#')
                    ),
            '#','');
```


|replace|
|:------:|
| 123321|


## Discussion

If you run query inside out (starting with `TRANSLATE` only), you’ll see this is simple.

```SQL
SELECT TRANSLATE( 'paul123f321',
                   'abcdefghijklmnopqrstuvwxyz',
                    RPAD('#',26,'#'));
```


First, TRANSLATE converts any nonnumeric character to an instance of #:


|translate|
|:---------:|
|####123#321|

```SQL
SELECT REPLACE(
                TRANSLATE( 'paul123f321',
                           'abcdefghijklmnopqrstuvwxyz',
                            RPAD('#',26,'#')),
              '#','');
```


Since all nonnumeric characters are now represented by `#`, simply use `REPLACE` to remove them:

|replace|
|:-----:|
|123321|

```SQL
SELECT
  CAST (
        REPLACE(
         TRANSLATE( 'paul123f321',
                    'abcdefghijklmnopqrstuvwxyz',
                    RPAD('#',26,'#')),
                '#','')
        AS INTEGER);
```

then use `CAST` the return the result as a number.

This particular example is extremely simple because the data is alphanumeric.
If additional characters can be stored, rather than fishing for those characters, it is easier to approach this problem differently: rather than finding nonnumeric characters and then removing them, find all numeric characters and remove anything that is not among them. The following example will help clarify this technique:

```SQL
SELECT
 REPLACE (
     TRANSLATE('paul123f321',
               REPLACE (
                    TRANSLATE('paul123f321',
                              '0123456789',
                               RPAD('#',10,'#')),
                        '#',''),
               RPAD('#',LENGTH('paul123f321'),'#')),
          '#','');  
```

|replace|
|:-------:|
|123321|

This solution looks a bit more convoluted than the original but is not so bad once you break it down. Observe the innermost call to `TRANSLATE`:

```SQL
SELECT  TRANSLATE('paul123f321',
                  '0123456789',
                   RPAD('#',10,'#'));
```

|translate|
|:---------:|
|paul###f###|

So, the initial approach is different; rather than replacing each nonnumeric character with an instance of `#`, you replace each numeric character with an instance of `#`.

```SQL
SELECT REPLACE (
          TRANSLATE('paul123f321',
                    '0123456789',
                     RPAD('#',10,'#')),
                '#','');
```

```SQL
SELECT REPLACE ('paul###f###','#','');
```

The next step removes all instances of `#`, thus leaving only nonnumeric characters:

|replace|
|:-------:|
|paulf|

```SQL
SELECT TRANSLATE('paul123f321',
                  REPLACE (
                          TRANSLATE('paul123f321',
                                    '0123456789',
                                     RPAD('#',10,'#')),
                           '#',''),
                  RPAD('#',LENGTH('paul123f321'),'#')
                );
```

```SQL
SELECT TRANSLATE('paul123f321',
                 'paulf',
                  RPAD('#',LENGTH('paul123f321'),'#')
                );
```

The next step is to call `TRANSLATE` again, this time to replace each of the nonnu‐ meric characters (from the previous query) with an instance of `#` in the original string. At this point, stop and examine the outermost call to `TRANSLATE`. The second parameter to `RPAD` is the length of the original string. This is convenient to use since **no character can occur enough times to be greater than the string it is part of**:

|translate|
|:-----------:|
|####123#321|

```SQL
SELECT
   REPLACE (
            TRANSLATE('paul123f321',
                      REPLACE (
                              TRANSLATE('paul123f321',
                                        '0123456789',
                                         RPAD('#',10,'#')),
                               '#',''),
                      RPAD('#',LENGTH('paul123f321'),'#')
                    ),
            '#','');
```

```SQL
SELECT REPLACE ('####123#321','#','');
```

Now that all nonnumeric characters are replaced by instances of `#`, the last step is to use `REPLACE` to remove all instances of `#`.

|replace|
|:------:|
| 123321|

Now you are left with a number.
