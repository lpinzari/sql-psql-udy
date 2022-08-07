# Embedding Quotes Within String Literals Problem

You want to embed quote marks within string literals. You would like to produce results such as the following with SQL:

|qmarks|
|:--------------:|
|g'day mate|
|beavers' teeth|
|'|


## Solution

The following three `SELECTs` highlight different ways you can create quotes: in the middle of a string and by themselves:

```SQL
SELECT 'g''day mate' qmarks
  FROM t1
UNION ALL
SELECT 'beavers'' teeth'    
  FROM t1
UNION ALL
SELECT ''''                 
  FROM t1;
```

## Discussion

When working with quotes, it’s often useful to **think of them like parentheses**. When you have an opening parenthesis, you must always have a closing parenthesis. The same goes for quotes. Keep in mind that you should **always have an even number of quotes across any given string**. To embed a single quote within a string, you need to use two quotes:

```SQL
SELECT 'apples core' AS s1,
       'apple''s core' AS s2,
        CASE WHEN '' IS NULL THEN 0 ELSE 1 end AS s3
  FROM t1;
```

|s1      |      s2      | s3|
|:-------:|:-------------:|:---:|
|apples core | apple's core |  1|
