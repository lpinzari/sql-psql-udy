# String Functions PostgreSQL

This chapter introduces the most commonly used PostgreSQL string functions that allow you to manipulate string data effectively.

|Function|	Description|	Example|	Result|
|:-------:|:----------:|:--------:|:------:|
|**ASCII**|	Return the ASCII code value of a character or Unicode code point of a UTF8 character|	`ASCII(‘A’)`|	65|
|**CHR**|	Convert an ASCII code to a character or a Unicode code point to a UTF8 character|	`CHR(65)`|	‘A’|
|**CONCAT**|	Concatenate two or more strings into one|	`CONCAT(‘A’,’B’,’C’)`|	‘ABC’|
|**CONCAT_WS**|	Concatenate strings with a separator|	`CONCAT_WS(‘,’,’A’,’B’,’C’)`|	‘A,B,C’|
|**FORMAT**|	Format arguments based on a format string|	`FORMAT(‘Hello %s’,’PostgreSQL’)`|	‘Hello PostgreSQL’|
|**INITCAP**|	Convert words in a string to title case|	`INITCAP(‘hI tHERE’)`|	Hi There|
|**LEFT**|	Return the first n character in a string|	`LEFT(‘ABC’,1)`|	‘A’|
|**LENGTH**|	Return the number of characters in a string|	`LENGTH(‘ABC’)`|	3|
|**LOWER**|	Convert a string to lowercase|`LOWER(‘hI tHERE’)`|	‘hi there’|
|**LPAD**|	Pad on the left a a string with a character to a certain length|	`LPAD(‘123′, 5, ’00’)`|	‘00123’|
|**LTRIM**|	Remove the longest string that contains specified characters from the left of the input string|	`LTRIM(‘00123’)`|	‘123’|
|**MD5**|	Return MD5 hash of a string in hexadecimal|	MD5('PostgreSQL MD5')|f78fdb18bf39b23d42313edfaf7e0a44|
|**POSITION**|	Return the location of a substring in a string|	`POSTION(‘B’ in ‘A B C’)`|	3|
|**REGEXP_MATCHES**|	Match a `POSIX` regular expression against a string and returns the matching substrings|	`SELECT REGEXP_MATCHES(‘ABC’, ‘^(A)(..)$’, ‘g’);`|	{A,BC}|
|**REGEXP_REPLACE**|	Replace substrings that match a `POSIX` regular expression by a new substring|	`REGEXP_REPLACE(‘John Doe’,'(.*) (.*)’,’\2, \1′);`|	‘Doe, John’|
|**REPEAT**|	Repeat string the specified number of times|	`REPEAT(‘*’, 5)`|	‘*****’|
|**REPLACE**|	Replace all occurrences in a string of substring from with substring to|	`REPLACE(‘ABC’,’B’,’A’)`|	‘AAC’|
|**REVERSE**|	Return reversed string.|	`REVERSE(‘ABC’)`|	‘CBA’|
|**RIGHT**|	Return last n characters in the string. When n is negative, return all but first |n| characters.|	`RIGHT(‘ABC’, 2)`|	‘BC’|
|**RPAD**|	Pad on the right of a string with a character to a certain length|	`RPAD(‘ABC’, 6, ‘xo’)`|	‘ABCxox’|
|**RTRIM**|	Remove the longest string that contains specified characters from the right of the input string|	`RTRIM(‘abcxxzx’, ‘xyz’)`|	‘abc’|
|**SPLIT_PART**|	Split a string on a specified delimiter and return nth substring|	`SPLIT_PART(‘2017-12-31′,’-‘,2)`|	’12’|
|**SUBSTRING**|	Extract a substring from a string|	`SUBSTRING(‘ABC’,1,1)`|	`A`|
|**TRIM**|	Remove the longest string that contains specified characters from the left, right or both of the input string|	TRIM(‘ ABC  ‘)|	‘ABC’|
|**UPPER**|	Convert a string to uppercase|	UPPER(‘hI tHERE’)	|‘HI THERE’|
