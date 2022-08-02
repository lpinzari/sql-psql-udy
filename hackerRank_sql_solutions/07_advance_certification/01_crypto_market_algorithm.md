# CRYPTO MARKET ALGORITHM

A number of algorithms are used to mine cryptocurrencies. As part of a comparison, create a query to return a list of algorithms and their volumes for each quarter of the year 2020.

The result should be in the following format: `Q1`,`Q2`,`Q3`,`Q4` transactions.

`Q1` through `Q4` contain the sums of transaction volumes for the algorithm for each calendar quarter of 2020 precise to 6 places after the decimal.

Results should be sorted ascending by algorithm `name`.

**Coins** Table:

|name|type|description|
|:--:|:---:|:--------:|
|code|VARCHAR(4)|coin code|
|name|VARCHAR(64)|coin name|
|algorithm|VARCHAR(128)|cryptocurrency algorithm name|

**Transactions** Table:

|name|type|description|
|:--:|:--:|:---------:|
|coin_code|VARCHAR(4)|coin code|
|dt|VARCHAR(19)| Transaction timestamp|
|volume|DECIMAL(11,6)|Transaction volume|


## Sample data

**Coins**

|code|name|algorithm|
|:--:|:--:|:-------:|
|BTC |Bitcoin|SHA-256|
|DOGE|Dogecoin|Scrypt|
|ETH |Etherium|Ethash|
|LTC |Litecoin|Scrypt|
|XMR|Monero|RandomX|


**Transactions**

|coin_code|dt|volume|
|:-------:|:-:|:---:|
|LTC  |2021-04-05 04:30:30|422.83041  |
|DOGE |2020-01-22 07:45:35|55.225905|
|BTC |2019-10-19 06:32:46|6906.520151|
|DOGE |2020-01-29 12:21:19|9320.519560|
|BTC|2020-04-05 12:38:54 |4775.700964|
|DOGE |2019-12-16 13:41:53|8865.966189|
|BTC |2019-12-07 02:24:27|9086.928039|
|ETH |2020-04-21 21:27:43|2273.56939|
|DOGE |2020-08-25 19:09:10|8022.924009|
|ETH |2020-06-04 03:53:39|6736.423699|
|DOGE |2019-12-23 00:13:13|6704.032765|
|LTC |2021-04-01 23:13:14|3177.003666|
|XMR |2020-10-10 17:50:52|1989.514313|
|BTC |2020-10-09 13:56:39|9776.150048|
|DOGE |2021-03-11 18:57:57|4346.517803|
|BTC |2019-12-10 11:28:31|3287.686066|
|DOGE |2019-11-28 01:05:59|7108.628739|
|BTC |2020-07-16 18:26:49|971.325293|
|BTC |2020-04-22 03:32:11|2389.737999|
|LTC|2020-08-22 22:13:59|1079.398703|


## Output

|algorithm|transactions_Q1|transactions_Q2|transactions_Q3|transactions_Q4|
|:-------:|:-------------:|:-------------:|:-------------:|:-------------:|
|Ethash |0.000000|14009.989638|0.000000|0.000000|
|RandomX|0.000000|0.000000|0.000000 |1989.574313|
|Scrypt |9425.745465|0.000000|9107.322712|0.000000|
|SHA-256|0.000000|7165.438963|971.325293|9716.150048|


## Solution

```SQL
WITH quarterly_v AS (
  SELECT algorithm,
         DATEPART(quarter,dt) AS quarters,
         SUM(volume) AS volume
    FROM coins c
   INNER JOIN transactions t ON t.coin_code = c.code
   WHERE DATEPART(year,dt) = 2020
   GROUP BY algorithm, DATEPART(quarter,dt)
)

SELECT c.algorithm,
       qv1.volume AS transactions_Q1,
       qv2.volume AS transactions_Q2,  
       qv3.volume AS transactions_Q3,
       qv4.volume AS transactions_Q4
  FROM coins c
       LEFT JOIN quarterly_v qv1
              ON c.algorithm = qv1.algorithm AND qv1.quarters = 1
       LEFT JOIN quarterly_v qv2
              ON c.algorithm = qv2.algorithm AND qv2.quarters = 2
       LEFT JOIN quarterly_v qv3
              ON c.algorithm = qv3.algorithm AND qv3.quarters = 3
       LEFT JOIN quarterly_v qv4
              ON c.algorithm = qv4.algorithm AND qv4.quarters = 4
 WHERE c.code NOT LIKE 'DOGE'
 ORDER BY algorithm;
```
