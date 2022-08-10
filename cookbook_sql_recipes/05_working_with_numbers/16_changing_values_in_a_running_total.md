# Changing Values in a Running Total


You want to **modify the values in a running total** `depending on` **the values in another column**.

## Problem

Consider a scenario where you want to **display** the `transaction history of a credit card account` along **with** the `current balance` **after each transaction**. The following view, `v`, will be used in this example:

```SQL
CREATE VIEW v (id,amt,trx) AS
       SELECT 1, 100, 'PR' UNION ALL
       SELECT 2, 100, 'PR' UNION ALL  
       SELECT 3,  50, 'PY' UNION ALL  
       SELECT 4, 100, 'PR' UNION ALL  
       SELECT 5, 100, 'PY' UNION ALL  
       SELECT 6,  50, 'PY' ;

SELECT * FROM v;
```

|id | amt | trx|
|:--:|:--:|:--:|
| 1 | 100 | PR|
| 2 | 100 | PR|
| 3 |  50 | PY|
| 4 | 100 | PR|
| 5 | 100 | PY|
| 6 |  50 | PY|

- The `ID` column uniquely identifies each transaction.
- The `AMT` column represents the **amount of money involved in each transaction (either a purchase or a payment)**.
- The `TRX` column defines the **type of transaction**;
  - a payment is “`PY`” and
  - a purchase is “`PR`.”

- If the value for `TRX` is `PY`, you want **the current value** for `AMT` subtracted from the running total;

- if the value for `TRX` is `PR`, you want the current value for `AMT` added to the running total.

Ultimately you want to return the following result set:

|trx_type | amt | balance|
|:-------:|:---:|:-----:|
|PURCHASE | 100 |    100|
|PURCHASE | 100 |    200|
|PAYMENT  |  50 |    150|
|PURCHASE | 100 |    250|
|PAYMENT  | 100 |    150|
|PAYMENT  |  50 |    100|


## Solution

Use the window function `SUM OVER` to create the running total along with a `CASE` expression to determine the type of transaction:

```SQL
SELECT CASE WHEN trx = 'PY'
            THEN 'PAYMENT'
            ELSE 'PURCHASE'
       END AS trx_type,
       amt,
       SUM(
           CASE WHEN trx = 'PY'
                THEN -amt
                ELSE amt
           END
         ) OVER (ORDER BY id, amt) AS balance
  FROM v;    
```

## DISCUSSION

The `CASE` expression determines whether the current `AMT` is added or deducted from the running total. If the transaction is a payment, the `AMT` is changed to a neg‐ ative value, thus reducing the amount of the running total. The result of the `CASE` expression is shown here:


```SQL
SELECT amt,
       CASE WHEN trx = 'PY'
            THEN 'PAYMENT'
            ELSE 'PURCHASE'
       END AS trx_type,
       CASE WHEN trx = 'PY'
            THEN -amt
            ELSE amt
       END AS trx_amt
  FROM v;
```

|amt | trx_type | trx_amt|
|:--:|:--------:|:------:|
|100 | PURCHASE |     100|
|100 | PURCHASE |     100|
| 50 | PAYMENT  |     -50|
|100 | PURCHASE |     100|
|100 | PAYMENT  |    -100|
| 50 | PAYMENT  |     -50|


```SQL
SELECT amt,
       CASE WHEN trx = 'PY'
            THEN 'PAYMENT'
            ELSE 'PURCHASE'
       END AS trx_type,
       CASE WHEN trx = 'PY'
            THEN -amt
            ELSE amt
       END AS trx_amt,
       SUM(
           CASE WHEN trx = 'PY'
                THEN -amt
                ELSE amt
           END
         ) OVER (ORDER BY id, amt) AS balance
  FROM v;
```


After evaluating the transaction type, the values for AMT are then added to or subtracted from the running total.

|amt | trx_type | trx_amt | balance|
|:--:|:--------:|:-------:|:------:|
|100 | PURCHASE |     100 |     100|
|100 | PURCHASE |     100 |     200|
| 50 | PAYMENT  |     -50 |     150|
|100 | PURCHASE |     100 |     250|
|100 | PAYMENT  |    -100 |     150|
| 50 | PAYMENT  |     -50 |     100|
