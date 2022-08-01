# 15 Days Learning SQL

Julia conducted a `15` days of learning SQL contest. The **start date** of the contest was `March 01, 2016` and the **end date** was `March 15, 2016`.

Write a query to print

- `total number of unique hackers` who **made at least** `1` **submission each day** (starting on the first day of the contest), and
- find the `hacker_id` and `name` of the hacker who **made maximum number of submissions each day**. If more than one such hacker has a maximum number of submissions, print the `lowest` **hacker_id**.

The query should print this information for **each day of the contest**, **sorted by the date**.

## Input Format

The following tables hold contest data:

- **Hackers**: The `hacker_id` is the id of the hacker, and `name` is the name of the hacker.


|Column|type|
|:-----:|:--:|
|hacker_id|Integer|
|name|String|

- **Submissions**: The `submission_date` is the date of the submission, `submission_id` is the id of the submission, `hacker_id` is the id of the hacker who made the submission, and `score` is the score of the submission.

|Column|Type|
|:-----:|:--:|
|submission_date|Date|
|submission_id|Integr|
|hacker_id |Integer|
|score|Integer|


## Sample Input

For the following sample input, assume that the end date of the contest was March 06, 2016.

**Hackers** Table:

|hacker_id|name|
|:-------:|:--:|
|15758|Rose    |
|20703|Angela |
|36396|Frank|
|38289|Patrick |
|44065|Lisa |
|53473|Kimberly|
|62529|Bonnie |
|70722|Michael|


**Submissions** Table:

|submission_date|submission_id|hacker_id|score|
|:-------------:|:------------:|:------:|:---:|
|2016-03-01|8494 |20703|0 |
|2016-03-01|22403|53473|15|
|2016-03-01|23965|79722|60|
|2016-03-01|30173|36396|70|
|2016-03-02|34928|20703|0  |
|2016-03-02|38740|15758|60|
|2016-03-02|42769|79722|25|
|2016-03-02|44364|79722|60|
|2016-03-03|45440|20703|0  |
|2016-03-03|49050|36396|70|
|2016-03-03|50273|70722|5|
|2016-03-04|50344|20703|0|
|2016-03-04|51360|44065|90|
|2016-03-04|54404|53473|65|
|2016-03-04|61533|79722|45|
|2016-03-05|72852|20703|0  |
|2016-03-05|74546|38289|0|
|2016-03-05|76487|62529|0|
|2016-03-05|82439|36396|10|
|2016-03-05|90006|36396|40|
|2016-03-06|90404|20703|0|

## Sample Output

```console
2016-03-01 4 20703 Angela
2016-03-02 2 79722 Michael
2016-03-03 2 20703 Angela
2016-03-04 2 20703 Angela
2016-03-05 1 36396 Frank
2016-03-06 1 20703 Angela
```

## Explanation

On **March 01, 2016** hackers `20703`,`36396`,`53473`, and `79722`  made submissions. There are `4` unique hackers who made at least one submission each day. As each hacker made one submission, `20703` is considered to be the hacker who made maximum number of submissions on this day. The name of the hacker is `Angela`.

On **March 02, 2016** hackers `15758`,`20703` ,and `79722` made submissions. Now `20703` and `79722` were the only ones to submit every day, so there are `2` unique hackers who made at least one submission each day. `79722` made `2` submissions, and name of the hacker is `Michael`.

On **March 03, 2016** hackers `20703`,`36396` ,and `79722` made submissions. Now `20703` and `79722`  were the only ones, so there are `2` unique hackers who made at least one submission each day. As each hacker made one submission so `20703` is considered to be the hacker who made maximum number of submissions on this day. The name of the hacker is `Angela`.

On **March 04, 2016** hackers `20703`,`44065` ,`53473` and `79722` made submissions. Now `20703` and `79722`  only submitted each day, so there are  unique hackers who made at least one submission each day. As each hacker made one submission so `20703` is considered to be the hacker who made maximum number of submissions on this day. The name of the hacker is `Angela`.

On **March 05, 2016** hackers `20703`,`36396` ,`38289`  and `62529`  made submissions. Now `20703` only submitted each day, so there is only `1` unique hacker who made at least one submission each day. `36396` made `2`  submissions and name of the hacker is `Frank`.

On **March 06, 2016** only `20703`  made submission, so there is only `1` unique hacker who made at least one submission each day.`20703`  made `1` submission and name of the hacker is `Angela`.

## Solution


```SQL
SELECT DISTINCT(submission_date)
  FROM Submissions;
```
The output of this query will be all the `dates` of the contest.

**Output**

|submission_date|
|:-------------:|
|2016-03-01|
|2016-03-02|
|2016-03-03|
|2016-03-04|
|2016-03-05|
|2016-03-06|
|2016-03-07|
|2016-03-08|
|2016-03-09|
|2016-03-10|
|2016-03-11|
|2016-03-12|
|2016-03-13|
|2016-03-14|
|2016-03-15|

## SECOND PROBLEM

Find the `hacker_id` and `name` of the hacker who **made maximum number of submissions each day**. If more than one such hacker has a maximum number of submissions, print the `lowest` **hacker_id**.


```SQL
SELECT submission_date, hacker_id,
       COUNT(submission_id) AS tot_submissions
  FROM submissions
 WHERE submission_date = '2016-03-01'
 GROUP BY submission_date, hacker_id
 ORDER BY tot_submissions DESC, hacker_id
 LIMIT 1;
```


|submission_date|hacker_id|tot_submissions|
|:-------------:|:-------:|:--------------:|
|**2016-03-01**| **81314**| **3**  |  

```SQL
SELECT name
  FROM Hackers
 WHERE hacker_id = 81314;
```

|name|
|:--:|
|Denise|

On **March 01, 2016**,  `81314` is considered to be the hacker who made maximum number of submissions on this day, `3` submissions. The name of the hacker is `Denise`.


```SQL
SELECT submission_date, hacker_id,
       COUNT(submission_id) AS tot_submissions
  FROM submissions
 WHERE submission_date = '2016-03-01'
 GROUP BY submission_date, hacker_id
 ORDER BY tot_submissions DESC, hacker_id
 LIMIT 1;
```


|submission_date|hacker_id|tot_submissions|
|:-------------:|:-------:|:--------------:|
|2016-03-02| 39091| 3|

```SQL
SELECT name
  FROM Hackers
 WHERE hacker_id = 39091;
```

|name|
|:--:|
|Ruby|

On **March 02, 2016**,  `39091` is considered to be the hacker who made maximum number of submissions on this day, `3` submissions. The name of the hacker is `Ruby`.

Let's combine the results of the previous queries into a single query statement for each date.

```SQL
SELECT submission_date,
       (SELECT hacker_id
          FROM Submissions SUB4
         WHERE SUB4.submission_date = SUB1.submission_date
         GROUP BY hacker_id
         ORDER BY COUNT(submission_id) DESC, hacker_id LIMIT 1) AS HID,
       (SELECT name
          FROM Hackers
         WHERE hacker_id = HID) AS name
  FROM (SELECT DISTINCT(submission_date)
         FROM Submissions) AS SUB1;
```

|submission_date|HID|name|
|:--------------:|:--:|:---:|
|2016-03-01| 81314 |Denise   |
|2016-03-02| 39091 |Ruby |
|2016-03-03| 18105 |Roy |
|2016-03-04| 533 |Patrick |
|2016-03-05| 7891 |Stephanie |
|2016-03-06| 84307| Evelyn |
|2016-03-07| 80682| Deborah |
|2016-03-08| 10985| Timothy |
|2016-03-09| 31221| Susan |
|2016-03-10| 43192| Bobby |
|2016-03-11| 3178 |Melissa |
|2016-03-12| 54967| Kenneth |
|2016-03-13| 30061| Julia |
|2016-03-14| 32353| Rose |
|2016-03-15| 27789| Helen |

## FIRST PROBLEM

`total number of unique hackers` who **made at least** `1` **submission each day** (starting on the first day of the contest).

Let's first compute the total number of hackers for each date of the contest.


```SQL
SELECT submission_date,
       COUNT(DISTINCT hacker_id) AS tot_hackers
  FROM submissions
 GROUP BY submission_date
 ORDER BY submission_date;
```

|submission_date|tot_hackers|
|:-------------:|:---------:|
|2016-03-01| 112|
|2016-03-02| 144|
|2016-03-03| 122|
|2016-03-04| 136|
|2016-03-05| 144|
|2016-03-06| 140|
|2016-03-07| 101|
|2016-03-08| 147|
|2016-03-09| 154|
|2016-03-10| 108|
|2016-03-11| 117|
|2016-03-12| 107|
|2016-03-13| 90 |
|2016-03-14| 146|
|2016-03-15| 117|

The column `tot_hackers` includes the number of users who submitted code for each date. The problem asks, however, `total number of unique hackers` who **made at least** `1` **submission each day** (starting on the first day of the contest). The answer for the first date.

- `2016-03-01` is clearly **122**.

On `2016-03-02` we must include in the computation only the hackers who submitted the day before (`2016-03-02`) and the current day (`2016-03-02`).

```SQL
SELECT submission_date,
       COUNT(DISTINCT hacker_id) AS tot_hackers
  FROM submissions
 WHERE submission_date = '2016-03-02' AND
       hacker_id IN (SELECT DISTINCT(hacker_id)
                       FROM submissions
                      WHERE submission_date = '2016-03-01');
```

|submission_date|tot_hackers|
|:--------:|:--------------:|
|2016-03-02| 59|

So there are `59` unique hackers who made at least one submission in the first and second day of the contest.

```SQL
SELECT submission_date,
       COUNT(DISTINCT hacker_id) AS tot_hackers
  FROM submissions
 WHERE submission_date = '2016-03-03' AND
       hacker_id IN (SELECT DISTINCT(hacker_id)
                       FROM submissions
                      WHERE submission_date = '2016-03-02' AND
                            hacker_id IN (SELECT DISTINCT(hacker_id)
                                            FROM submissions
                                           WHERE submission_date = '2016-03-01'));
```

|submission_date|tot_hackers|
|:-------------:|:---------:|
|2016-03-03| 51|

So there are `51` unique hackers who made at least one submission in the first  `3` days of the contest.

```SQL
SELECT hacker_id,
       COUNT(DISTINCT submission_date) AS days
  FROM submissions
 WHERE submission_date <= '2016-03-03' AND days >= 3;
```

|hacker_id|days|
|:-------:|:---:|
|650 |3|
|3162 |3 |
|4413 |3 |
|5478 |3 |
|5509 |3 |
|5990 |3 |
|7460 |3 |
|7865 |3 |
|7897 |3 |
|7978 |3 |
|8150 |3 |
|8878 |3 |
|9630 |3 |
|11209| 3|
|12371| 3|
|12423| 3|
|19773| 3|
|19963| 3|
|20811| 3|
|20888| 3|
|21372| 3|
|22165| 3|
|22917| 3|
|22949| 3|
|24095| 3|
|24576| 3|
|26093| 3|
|26468| 3|
|27064| 3|
|30082| 3|
|32455| 3|
|33323| 3|
|33863| 3|
|34234| 3|
|34369| 3|
|36594| 3|
|37997| 3|
|38962| 3|
|41057| 3|
|42973| 3|
|44791| 3|
|48490| 3|
|49340| 3|
|51132| 3|
|51548| 3|
|53295| 3|
|53342| 3|
|54113| 3|
|54408| 3|
|55374| 3|
|56707| 3|

As expected the number of records are `51`.

Let's combine the previous queries into a single query:

```SQL
SELECT submission_date,
      (SELECT COUNT(DISTINCT hacker_id)
         FROM Submissions AS SUB2
        WHERE SUB2.submission_date = SUB1.submission_date AND
              (SELECT COUNT(DISTINCT submission_date)
                 FROM Submissions AS SUB3
                WHERE (SUB3.hacker_id = SUB2.hacker_id) AND
                      (SUB3.submission_date < SUB1.submission_date))
                     = DATEDIFF(SUB1.submission_date, '2016-03-01' )
      ) AS tot_unique_h
  FROM (SELECT DISTINCT(submission_date)
          FROM Submissions) AS SUB1;
```

|submission_date|tot_unique_h|
|:--------------:|:----------:|
|2016-03-01| 112|
|2016-03-02| 59 |
|2016-03-03| 51 |
|2016-03-04| 49 |
|2016-03-05| 49 |
|2016-03-06| 49 |
|2016-03-07| 35 |
|2016-03-08| 35 |
|2016-03-09| 35 |
|2016-03-10| 35 |
|2016-03-11| 35 |
|2016-03-12| 35 |
|2016-03-13| 35 |
|2016-03-14| 35 |
|2016-03-15| 35 |

## SOLUTION: COMBINE RESULTS

```SQL
SELECT submission_date,
      (SELECT COUNT(DISTINCT hacker_id)
         FROM Submissions AS SUB2
        WHERE SUB2.submission_date = SUB1.submission_date AND
              (SELECT COUNT(DISTINCT submission_date)
                 FROM Submissions AS SUB3
                WHERE (SUB3.hacker_id = SUB2.hacker_id) AND
                      (SUB3.submission_date < SUB1.submission_date))
              = DATEDIFF(SUB1.submission_date, '2016-03-01' )) AS tot_unique_h,
      (SELECT hacker_id
         FROM Submissions SUB4
        WHERE SUB4.submission_date = SUB1.submission_date
        GROUP BY hacker_id
        ORDER BY COUNT(submission_id) DESC, hacker_id LIMIT 1) AS HID,
      (SELECT name
         FROM Hackers
        WHERE hacker_id = HID) name
  FROM (SELECT DISTINCT(submission_date)
          FROM Submissions) AS SUB1;
```


|submission_date|tot_unique_h|HID|name|
|:-------------:|:----------:|:----:|:---:|
|2016-03-01| 112| 81314| Denise
|2016-03-02| 59 |39091 |Ruby
|2016-03-03| 51 |18105 |Roy
|2016-03-04| 49 |533 |Patrick
|2016-03-05| 49 |7891 |Stephanie
|2016-03-06| 49 |84307| Evelyn
|2016-03-07| 35 |80682| Deborah
|2016-03-08| 35 |10985| Timothy
|2016-03-09| 35 |31221| Susan
|2016-03-10| 35 |43192| Bobby
|2016-03-11| 35 |3178| Melissa
|2016-03-12| 35 |54967| Kenneth
|2016-03-13| 35 |30061| Julia
|2016-03-14| 35 |32353| Rose
|2016-03-15| 35 |27789| Helen  
