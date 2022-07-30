# Top Competitors

Julia just finished conducting a coding contest, and she needs your help assembling the leaderboard! Write a query to print the respective `hacker_id` and `name` of hackers who achieved full scores for more than one challenge.

**Order your output in descending order by** the `total number of challenges` in which the hacker earned a `full score`.

If more than `one hacker received full scores in same number of challenges`, then **sort them by ascending** `hacker_id`.

## Input Format

The following tables contain contest data:

- **Hackers**: The `hacker_id` is the `id` of the hacker, and `name` is the name of the hacker.

|Column|Type|
|:----:|:--:|
|hacker_id|Integer|
|name|String|


- **Difficulty**: The `difficult_level` is the level of difficulty of the challenge, and `score` is the score of the challenge for the difficulty level.


|Column|type|
|:----:|:---:|
|difficulty_level|Integer|
|score|Integer|

- **Challenges**: The `challenge_id` is the `id` of the challenge, the `hacker_id` is the `id` of the hacker who created the challenge, and `difficulty_level` is the level of difficulty of the challenge.

|Column|Type|
|:----:|:---:|
|challenge_id|Integer|
|hacker_id |Integer|
|difficult_level|Integer|

- **Submissions**: The `submission_id` is the id of the submission, `hacker_id` is the id of the hacker who made the submission, `challenge_id` is the id of the challenge that the submission belongs to, and `score` is the score of the submission.

|Column|Type|
|:----:|:---:|
|submission_id|Integer|
|hacker_id|Integer|
|challenge_id|Integer|
|score|Integer|

## Sample Input

**Hackers** Table:


|hacker_id|name|
|:-------:|:--:|
|5580|Rose|
|8439|Angela|
|27205|Frank|
|52243|Patrick|
|52348|Lisa|
|57645|kimberly|
|77726|Bonnie|
|83082|Michael|
|**86870**|**Todd**|
|**90411**|**Joe**|


**Difficulty** Table:

|difficult_level|score|
|:-------------:|:----:|
|1|20|
|2|30|
|3|40|
|4|60|
|5|80|
|6|100|
|7|120|


**Challenges** Table:

|challenge_id|hacker_id|difficult_level|
|:----------:|:-------:|:--------------:|
|4810|77726|4|
|21089|27205|1|
|36566|5580|7|
|66730|52243|6|
|71055|52243|2|


**Submissions** Table:

|submission_id|hacker_id|challenge_id|score|
|:-----------:|:-------:|:-----------:|:---:|
|68628|77726|36566    |30   |
|65300|77726|21089|10|
|40326|52243|36566|77|
|8941|27205|4810|4|
|83554|77726|66730|30|
|43353|52243| 66730|0|
|55385|52348|71055 |20|
|39874|27205|71055|23|
|94613|**86870**|71055|**30**|
|45788|52348|36566|0|
|93058|**86870**|36566|**30**|
|7344|8439|66730|92|
|2721|8439|4810|36|
|523|5580|71055|4|
|49150|52348 |66730|0|
|55877|57645|66730|80|
|38355|27205 |66730|35|
|3924|8439 |36566|80|
|97397 |**90411**|66730|**100**|
|84162 |83082|4810|40|
|97431|**90411**|71055|**30**|

## Sample Output

```console
90411 Joe
Explanation
```

Hacker 86870 got a score of 30 for challenge 71055 with a difficulty level of 2, so 86870 earned a full score for this challenge.

Hacker 90411 got a score of 30 for challenge 71055 with a difficulty level of 2, so 90411 earned a full score for this challenge.

Hacker 90411 got a score of 100 for challenge 66730 with a difficulty level of 6, so 90411 earned a full score for this challenge.

Only hacker 90411 managed to earn a full score for more than one challenge, so we print the their hacker_id and name as `2` space-separated values.


## Solution

```console
                        Hackers
                         |Column|Type|
                         |:----:|:--:|                      Difficulty
            *----------> |hacker_id|Integer|+                |Column|type|
            |            |name|String|+                      |:----:|:---:|
            |                                        * ----->|difficulty_level|Integer|
            |                                        |       |score|Integer|<-*
            |      *---------------------------------| -----------*            |
            |      |     Challenges                  |            |            |
            |      |       |Column|Type|             |            |            |
            |      |       |:----:|:---:|            |            |            |
            |      |       |challenge_id|Integer|<---------*      |            |
            *----------    |hacker_id |Integer|      |     |      |            |
            |      |       |difficult_level|Integer|-*     |      |            |
            |      |                                       |      |            |
            |      |       |Column|Type|                   |      |            |
            |      |       |:----:|:---:|                  |      |            |
            |      |       |submission_id|Integer|         |      |            |
            *-----------   |hacker_id|Integer|             |      |            |
                   |       |challenge_id|Integer|----------*      |            |
                   |       |score|Integer|-------------------------------------*
                   |    Submissions                              |
                   *---------------------------------------------*
```


```SQL
SELECT h.hacker_id, h.name
  FROM submissions s
  JOIN challenges c
    ON s.challenge_id = c.challenge_id
  JOIN difficulty d
    ON c.difficulty_level = d.difficulty_level AND
       s.score = d.score
  JOIN hackers h
    ON s.hacker_id = h.hacker_id
 GROUP BY h.hacker_id, h.name
HAVING COUNT(s.hacker_id) > 1
 ORDER BY COUNT(s.hacker_id) DESC,
          s.hacker_id ASC;
```
