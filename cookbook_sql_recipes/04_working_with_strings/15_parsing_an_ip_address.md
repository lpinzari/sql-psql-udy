# Parsing an IP Address

**You want to parse an IP address’s fields into columns**.

Consider the following IP address:

- `111.22.3.4`

You would like the result of your query to be:

|A|B|C|D|
|:-:|:-:|:-:|:-:|
|111|22|3|4|

## Solution

The solution depends on the built-in functions provided by your DBMS. Regardless of your DBMS, being able to locate periods and the numbers immediately surround‐ ing them are the keys to the solution.

**PostgreSQL**

Use the built-in function `SPLIT_PART` to parse an IP address:

```SQL
SELECT SPLIT_PART(y.ip,'.',1) AS a,
       SPLIT_PART(y.ip,'.',2) AS b,
       SPLIT_PART(y.ip,'.',3) AS c,
       SPLIT_PART(y.ip,'.',4) AS d
  FROM (SELECT cast('92.111.0.2' AS TEXT) AS ip) AS y;
```

|a  |  b  | c | d|
|:--:|:---:|:---:|:--:|
|92 | 111 | 0 | 2|

## Pattern Matching IP-4 ADDRESS

To match IPv4 address format, you need to check for numbers `[0-9]{1,3}` three times `{3}` separated by periods `\.` and ending with another number.


- `^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$`

This regular expression is too simple - if you want to it to be accurate, you need to check that the numbers are between `0` and `255`, with the regex above accepting 444 in any position. You want to check for `250-255` with **25[0-5]**, or any other `200-249` value `2[0-4][0-9]`, or any `100` value or less with `[01]?[0-9][0-9]?`. You want to check that it is followed by a period `\.` three times `{3}` and then **once without a period**.

- `^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$`

The `?` symbol means that the number is optional. Thus, the expression `[01]?[0-9][0-9]?` means that `[01]?` is optional and could be a `1` or `0`, `[0-9]` there must be at least a number in the range 0 to 9, and `[0-9]?` optional number in the range 0 to 9.

```SQL
SELECT '250' ~ '25[0-5]'; -- true
SELECT '251' ~ '25[0-5]'; -- true
SELECT '252' ~ '25[0-5]'; -- true
SELECT '253' ~ '25[0-5]'; -- true
SELECT '254' ~ '25[0-5]'; -- true
SELECT '255' ~ '25[0-5]'; -- true
--------------------------------------
SELECT '200' ~ '2[0-4][0-9]'; -- true
SELECT '249' ~ '2[0-4][0-9]'; -- true
----------------------------------------
SELECT '100' ~ '[01]?[0-9][0-9]?'; -- true
SELECT '099' ~ '[01]?[0-9][0-9]?'; -- true
SELECT '99' ~ '[01]?[0-9][0-9]?';  -- true
SELECT '001' ~ '[01]?[0-9][0-9]?'; -- true
SELECT '01' ~ '[01]?[0-9][0-9]?'; -- true
SELECT '1' ~ '[01]?[0-9][0-9]?'; -- true
SELECT '000' ~ '[01]?[0-9][0-9]?'; -- true
SELECT '00' ~ '[01]?[0-9][0-9]?'; -- true
SELECT '0' ~ '[01]?[0-9][0-9]?'; -- true
```

```SQL
SELECT '255.255.255.255' ~ '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'; -- true
SELECT '000.000.000.000' ~ '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'; -- true
SELECT '1.1.1.1' ~ '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'; -- true
SELECT '999.1.1.1' ~ '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'; -- false
```

### Accurate regex to extract IPV4 addresses from longer text:

```SQL
WITH t AS (
  SELECT REPLACE(REPLACE(CAST(REGEXP_MATCHES('this is an ip 210.255.255.255','(?:[0-9]{1,3}\.){3}[0-9]{1,3}','g') AS text),'{',''),'}','') AS ip
  UNION ALL
  SELECT REPLACE(REPLACE(CAST(REGEXP_MATCHES('this is an ip 125.255.255.255','(?:[0-9]{1,3}\.){3}[0-9]{1,3}','g') AS text),'{',''),'}','')
  UNION ALL
  SELECT REPLACE(REPLACE(CAST(REGEXP_MATCHES('this is an ip 999.255.255.255','(?:[0-9]{1,3}\.){3}[0-9]{1,3}','g') AS text),'{',''),'}','')
)

SELECT t.ip
  FROM t
 WHERE t.ip ~ '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$';
```

|ip|
|:-------------:|
|210.255.255.255|
|125.255.255.255|
