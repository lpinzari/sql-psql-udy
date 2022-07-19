# REGEXP_REPLACE Function PostgreSQL

The PostgreSQL `REGEXP_REPLACE()` function replaces substrings that match a `POSIX` regular expression by a new substring.

>> Note that if you want to perform simple string replacement, you can use the REPLACE() function.

The syntax of the PostgreSQL REGEXP_REPLACE() function is as follows:

```SQL
REGEXP_REPLACE(source, pattern, replacement_string,[, flags])   
```

## Arguments

The `REGEXP_REPLACE()` function accepts four arguments:

1. **source**: The source is a string that replacement should be taken place.

2. **pattern**: The pattern is a `POSIX` regular expression for matching substrings that should be replaced.

3. **replacement_string**: The `replacement_string` is a string that to replace the substrings which match the regular expression pattern.

4. **flags**: The flags argument is one or more character that controls the matching behavior of the function e.g., i allows case-insensitive matching, n enables matching any character and also the newline character.

## Return value

The PostgreSQL **REGEXP_REPLACE()** function **returns a new string with the substrings, which match a regular expression pattern, replaced by a new substring**.

## Examples

Let’s see some examples to understand how the `REGEXP_REPLACE()` function works.

### A) Name rearrangement

Suppose, you have a name of a person in the following format:

```SQL
first_name last_name
```

For example, `John Doe`

And you want to **rearrange the this name** as follows for the reporting purpose.

```SQL
last_name, first_name
```

To do this , you can use the `REGEXP_REPLACE()` function as shown below:

```SQL
SELECT REGEXP_REPLACE('John Doe','(.*) (.*)','\2, \1');
```

**Results**

```console
'Doe, John'
```

### B) String removal

Imagine you have string data with mixed alphabets and digits as follows:

```SQL
ABC12345xyz
```

The following statement removes all alphabets e.g., A, B, C, etc from the source string:

```SQL
SELECT REGEXP_REPLACE('ABC12345xyz','[[:alpha:]]','','g');
```

**Results**

```SQL
'12345'
```

In this example,

 - `[[:alpha:]]` matches any alphabets
 - `''` is the replacement string
 - `'g'` instructs the function to remove all alphabets, not just the first one.

### C) Redundant spaces removal

The following example removes unwanted spaces that appear more than once in a string.

```SQL
SELECT REGEXP_REPLACE('This  is    a   test   string','( ){2,}',' ');
```

**Results**

`This is a test string`

It takes efforts and experiments to understand how the REGEXP_REPLACE() function works.

## PostgreSQL REGEXP_REPLACE() function examples

```SQL
SELECT
	regexp_replace(
		'foo bar foobar barfoo',
		'foo',
		'bar'
	);
```

**Output**

```console
bar bar foobar barfoo
```

In the following example, because we use `i` flag, it ignores case and replaces the first occurrence of `Bar` or `bar` with `foo`.

```SQL
SELECT
	regexp_replace(
		'Bar foobar bar bars',
		'Bar',
		'foo',
		'i'
	);
```

**Output**

```console
foo foobar bar bars
```

In the following example, we use both `g` and `i` flags, so all occurrences of `bar` or `Bar`, `BAR`, `etc`., are replaced by `foo`.

```SQL
SELECT
	regexp_replace(
		'Bar sheepbar bar bars barsheep',
		'bar',
		'foo',
		'gi'
	);
```

**Output**

```console
foo sheepfoo foo foos foosheep
```

`\M` means match only at the end of each word. All words, which end with `bar` in whatever cases, are replaced by `foo`. Words begin with bar will not be replaced.

```SQL
SELECT
	regexp_replace(
		'Bar sheepbar bar bars barsheep',
		'bar\M',
		'foo',
		'gi'
	);
```

**Output**

```console
foo sheepfoo foo bars barsheep
```

`\m` and `\M` mean matching at both the beginning and end of each word. All words that begin and/or end with bar in whatever cases are replaced by `foo`.

```SQL
SELECT
	regexp_replace(
		'Bar sheepbar bar bars barsheep',
		'\mbar\M',
		'foo',
		'gi'
	);
```

**Output**

```console
foo sheepbar foo bars barsheep
```
