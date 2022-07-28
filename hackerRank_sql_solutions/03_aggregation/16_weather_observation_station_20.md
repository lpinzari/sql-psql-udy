# Weather observation station 20

A [median](https://en.wikipedia.org/wiki/Median) is defined as a number separating the higher half of a data set from the lower half. Query the median of the Northern Latitudes (LAT_N) from STATION and round your answer to `4` decimal places.

# Input Format

The **STATION** table is described as follows:

|Field|Type|
|:---:|:--:|
|ID| NUMBER|
|CITY|VARCHAR(21)|
|STATE|VARCHAR(2)|
|LAT_N|NUMBER|
|LONG_W|NUMBER|

where LAT_N is the northern latitude and LONG_W is the western longitude.

## Solution

Since the median represents the value that separates the higher half and the lower half of a data sample, you need to sort the values from the smallest to the largest.

If the data set has an even number of values the median is the average of two values in position  `(size/2, Size/2 + 1)`, otherwise is the middle value in position `size/2`.

```SQL
WITH rank_tab AS (
SELECT lat_n,
       ROW_NUMBER() OVER(ORDER BY lat_n) AS row_index
  FROM station
),
middle AS (
SELECT *
  FROM rank_tab
  WHERE row_index IN(
    CEIL((SELECT COUNT(lat_n) FROM rank_tab)/2) + 1 - MOD((SELECT COUNT(lat_n) FROM rank_tab),2),
    CEIL((SELECT COUNT(lat_n) FROM rank_tab)/2) )
)

SELECT ROUND(AVG(lat_n),4)
  FROM middle;
```
