# Crypto Market transactions Monitoring

As part of a cryptocurrency trade monitoring platform create a query to return a list of suspicious transactions.

Suspicious transactions are defined as:
- a series of two or more transactions occur at intervals of an hour or less
- they are from the same sender
- the sum of transactions in a sequence is 150 or greater.

A sequence of suspicious transactions may occur over time periods greater than one hour. As an example, there are 5 transactions from one sender for 30 each. They occur at intervals of less than an hour between from 8 AM to 11 AM. These are suspicious and will all be reported as one sequence that starts at 8 AM, ends at 11 AM, with 5 transactions that sum to 150.

The result should have the following columns:`sender`, `sequence_start`,`sequence_end`,`transactions_count`,`transactions_sum`.

- `sender`: is the sender's address
- `sequence_start`: is the timestamp of the first transaction in the sequence
- `sequence_end`: is the timestamp of the last transaction in the sequence
- `transaction_count`: is the number of transactions in the sequence
- `transactions_sum`: is the sum of transaction amounts in the sequence, to 6 places after the decimal.

Order the data `ascending`, first by `sender`, then by `sequence_start` and finally by `sequence_end`.


```SQL
WITH df AS (
  SELECT *,
         DATEDIFF(minute,LAG(dt) OVER (ORDER BY sender,dt), dt) AS df_minute,
         ROW_NUMBER() OVER(ORDER BY sender, dt) AS rown
    FROM transactions
),
rn AS (
  SELECT rown
    FROM df
   WHERE rown IN (SELECT rown
                    FROM transactions
                   WHERE abs(df_minute) < 60)
),
ss AS (
  SELECT *
    FROM df
   WHERE rown IN (SELECT rown
                    FROM rn
                   UNION
                  SELECT rown - 1 AS rown
                    FROM rn)
)

SELECT sender,
       MIN(dt) AS sequence_start,
       MAX(dt) AS sequence_end,
       COUNT(rown) AS transactions_count,
       SUM(amount) AS transactions_sum
  FROM ss
 GROUP BY sender
HAVING SUM(amount) >= 150
 ORDER BY sender, MIN(dt),MAX(dt);  
```
