# Finding Text Not Matching a Pattern

You have a text field that contains some structured text values (e.g., `phone numbers`), and you want to **find occurrences where those values are structured incorrectly**.

## Problem

For example, you have data like the following:

```SQL
CREATE TABLE temp (
  empid integer,
  info text
);

INSERT INTO temp
       (empid, info)
VALUES (7369,'126 Varnum, Edmore MI 48829, 989 313-5351'),
       (7499,'1105 McConnell Court Cedar Lake MI 48812 Home: 989-387-4321 Cell: (237) 438-3333'),
       (9999,'906-387-1698, 313-535.8886'),
       (7844,'989-387.5359')
       (6733,'(238) 438-3339'),
       (7900,'Cares for 100-year-old aunt during the day. Schedule only
                      for evening and night shifts.');
```

|empid |                                       info|
|:----:|:----------------------------------------------------:|
| 7369 | 126 Varnum, Edmore MI 48829, 989 313-5351
| 7499 | 1105 McConnell Court Cedar Lake MI 48812 Home: 989-387-4321 Cell: (237) 438-3333|
| 9999 | 906-387-1698, 313-535.8886|
| 7844 | 989-387.5359|
| 6733 | (238) 438-3339|
|7900| Cares for 100-year-old aunt during the day. Schedule only for evening and night shifts.|



and you want to **list rows having invalidly formatted phone numbers**. For example, you want to list the following rows because its phone number uses two different separator characters:

|empid |                                       info
|:----:|:---------------------------------------------------------------------------------:|
|7369 | 126 Varnum, Edmore MI 48829, **989 313-5351**|
|9999 | 906-387-1698, **313-535.8886**|
|7844 | **989-387.5359**|

The phone number displayed in the info field of the first record `989 313-5351` is composed of three groups of numbers separated by two different delimiters ` ` and `-`. Similarly, the composition of the phone numbers  `313-535.8886` and `989-387.5359` include two different separators, (`-`,`.`).

On the other hand, the phone number's composition of the record excluded (i.e. empid: `7499`, phone number: `989-387-4321`), does not have different separators.
It uses the same character `-` for both delimiters.

You want to consider valid only those **phone numbers that use the same character for both delimiters**.

## Solution

This problem has a multipart solution:

1. Find a way to describe the universe of apparent phone numbers that you want to consider. In this case a phone number is a sequence of `12` characters. The first three characters are numbers in the range `0-9` followed by any of these characters `-`,`.` or space ` `. The next three characters are digits in the range `0-9` followed by the same set of characters. The last four characters are digits in the range `0-9`.
2. Remove any validly formatted phone numbers from consideration.
3. See whether you still have any apparent phone numbers left. If you do, you know those are invalidly formatted.

```SQL
SELECT empid, info
  FROM temp
 WHERE info ~ '[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}'
       AND REGEXP_REPLACE(INFO,'[0-9]{3}([-. ])[0-9]{3}\1[0-9]{4}','***') ~ '[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}';
```

|empid |                                       info
|:----:|:---------------------------------------------------------------------------------:|
|7369 | 126 Varnum, Edmore MI 48829, 989 313-5351|
|9999 | 906-387-1698, 313-535.8886|
|7844 | 989-387.5359|

Each of these rows contains at least one apparent phone number that is not correctly formatted.

## Discussion

The key to this solution lies in the detection of an “apparent phone number.” Given that the phone numbers are stored in an `info` field, any text at all in the field could be construed to be an invalid phone number. You need a way to narrow the field to a more reasonable set of values to consider. You don’t, for example, want to see the following row in your output:

|empid |                                       info
|:----:|:---------------------------------------------------------------------------------:|
|7900| Cares for 100-year-old aunt during the day. Schedule only for evening and night shifts.|

Clearly there’s no phone number at all in this row, much less one that is invalid.

The solution uses Pattern A to define the set of “apparent” phone numbers to consider:

- **Pattern A**: `[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}`

**Pattern A** checks for **two groups** of `three digits`, (`[0-9]{3}`), followed by **one group** of `four digits`, (`[0-9]{4}`).

Any one of a dash (`-`), a period (`.`), or a space (` `) is accepted as a delimiter between groups, `[-. ]`.

You could come up with a more complex pattern. For example, you could decide that you also want to consider seven-digit phone numbers. But don’t get sidetracked. The point now is that somehow you do need to define the universe of possible phone number strings to consider, and for this problem that universe is defined by Pattern A. You can define a different Pattern A, and the general solution still applies.

The solution uses Pattern A in the `WHERE` clause to ensure that only rows **having potential phone numbers** (as defined by the pattern!) are considered:


```SQL
SELECT empid, info
  FROM temp
 WHERE info ~ '[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}';
```

|empid |                                       info|
|:----:|:----------------------------------------------------:|
| 7369 | 126 Varnum, Edmore MI 48829, 989 313-5351
| 7499 | 1105 McConnell Court Cedar Lake MI 48812 Home: 989-387-4321 Cell: (237) 438-3333|
| 9999 | 906-387-1698, 313-535.8886|
| 7844 | 989-387.5359|

On the other hand, the following records do not have potential phone-numbers:

|empid |                                       info|
|:----:|:----------------------------------------------------:|
| 6733 | (238) 438-3339|
|7900| Cares for 100-year-old aunt during the day. Schedule only
               for evening and night shifts.|

Next, you need to define what a “**good**” phone number looks like. The solution does this using **Pattern B**:

- **Pattern B**: `[0-9]{3}([-. ])[0-9]{3}\1[0-9]{4}`

This time, the pattern uses `\1` to **reference the first subexpression**, `([-. ])`, it's just a shortcut for typing `[-. ]`. Whichever character is matched by `([-. ])` must also be matched by `\1`.

**Pattern B** describes `good phone numbers`, which must be eliminated from consideration (as they are not bad).

```SQL
SELECT '989-387-4321' AS phone_number,
       '989-387-4321' ~ '[0-9]{3}([-. ])[0-9]{3}\1[0-9]{4}' AS good_phone_number;
```

|phone_number | good_phone_number|
|:-----------:|:----------------:|
|989-387-4321 | t|

```SQL
SELECT '989-387.4321' AS phone_number,
       '989-387.4321' ~ '[0-9]{3}([-. ])[0-9]{3}\1[0-9]{4}' AS good_phone_number;
```

|phone_number | good_phone_number|
|:-----------:|:----------------:|
|989-387.4321 | f|

The solution eliminates the well-formatted phone numbers through a call to `REGEXP_ REPLACE`:

```SQL
SELECT '989-387-4321' AS phone_number,
       REGEXP_REPLACE('989-387-4321','[0-9]{3}([-. ])[0-9]{3}\1[0-9]{4}','***') AS replace_phone_number;
```

|phone_number | replace_phone_number|
|:-----------:|:-------------------:|
|989-387-4321 | ***|

```SQL
SELECT '989-387.4321' AS phone_number,
       REGEXP_REPLACE('989-387.4321','[0-9]{3}([-. ])[0-9]{3}\1[0-9]{4}','***') AS replace_phone_number;
```

|phone_number | replace_phone_number|
|:-----------:|:--------------------:|
|989-387.4321 | 989-387.4321|

Any well-formatted phone numbers are replaced by a string of three asterisks. Again, Pattern B can be any pattern that you desire. The point is that Pattern B describes the acceptable pattern that you are after.

Having replaced well-formatted phone numbers with strings of three asterisks (*), any “apparent” phone numbers that remain must, by definition, be poorly formatted.

```SQL
SELECT '989-387-4321' AS phone_number,
       REGEXP_REPLACE('989-387-4321','[0-9]{3}([-. ])[0-9]{3}\1[0-9]{4}','***') ~ '[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}' AS poorly_formatted;
```

|phone_number | poorly_formatted|
|:-----------:|:---------------:|
|989-387-4321 | f|

```SQL
SELECT '989-387.4321' AS phone_number,
       REGEXP_REPLACE('989-387.4321','[0-9]{3}([-. ])[0-9]{3}\1[0-9]{4}','***') ~ '[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}' AS poorly_formatted;
```

|phone_number | poorly_formatted|
|:-----------:|:---------------:|
|989-387.4321 | t|

This call to `REGEXP_REPLACE` occurs in the `WHERE` clause.

```SQL
SELECT empid, info
  FROM temp
 WHERE info ~ '[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}'
       AND REGEXP_REPLACE(INFO,'[0-9]{3}([-. ])[0-9]{3}\1[0-9]{4}','***') ~ '[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}';
```

|empid |                                       info
|:----:|:---------------------------------------------------------------------------------:|
|7369 | 126 Varnum, Edmore MI 48829, 989 313-5351|
|9999 | 906-387-1698, 313-535.8886|
|7844 | 989-387.5359|
