# Normal Quantile Numerical examples


1. Find the value of z such that F(z1) = 0.9147 or  P(z <= z1) = 0.9147. `z = 1.37`
2. Find the value of z such that P(-z <= Z <= z) = 0.7372. `z = 1.12`
3. Find the value of z such that P(-z <= Z <= z) = **0.6826**. `z = 1`
4. Find the value of z such that P(-z <= Z <= z) = **0.9544**. `z = 2`
5. Find the value of z such that P(-z <= Z <= z) = **0.9974**. `z = 3`

Problems 3,4 and 5 show that:

- `P(mu - sigma <= Z <= mu + sigma)` = P(-1 <= Z <= 1) =  **0.6826**
- `P(mu - 2*sigma <= Z <= mu + 2*sigma)` = P(-2 <= Z <= 2) = **0.9544**
- `P(mu - 3*sigma <= Z <= mu + 3*sigma)` = P(-3 <= Z <= 3) = **0.9974**

The probability that a normal random variable belongs to a symmetric interval `(mu - c*sigma, mu + c*sigma)`, depends only on the value of `c`.

6. Find the percentage of values that belongs to the following intervals

- `P(mu - 0.8*sigma <= Z <= mu + 0.8*sigma)` = P(-0.8 <= Z <= 0.8) = 0.5763

7. Find the value of `c` such that

- `P(mu - c*sigma <= Z <= mu + c*sigma)` = 0.9876


## Problem 1

```SQL
SELECT ROUND(qnorm(0.9147)::NUMERIC,2) AS z;
```

```console
z
------
1.37
```

## Problem 2

```console
P(-z <= Z <= z) = F(z) - F(-z)  ,    F(-z) = 1 - F(z)
                = F(z) - (1 - F(z))
                = F(z) - 1 + F(z)
                = 2*F(z) - 1

2*F(z) - 1 = 0.7372
2*F(z) = 1 + 0.7372
F(z) = (1 + 0.7372)/2   
```

```SQL
SELECT ROUND(qnorm((1 + 0.7372)/2)::NUMERIC,2) AS z;
```

```console
z
------
1.12
```

## Problem 3

```SQL
SELECT ROUND(qnorm((1 + 0.6826)/2)::NUMERIC,2) AS z;
```

```console
z
------
1.00
```

## Problem 4

```SQL
SELECT ROUND(qnorm((1 + 0.9544)/2)::NUMERIC,2) AS z;
```

```console
z
------
2.00
```

## Problem 5

```SQL
SELECT ROUND(qnorm((1 + 0.9974)/2)::NUMERIC,2) AS z;
```

```console
z
------
3.00
```

## Problem 6

```SQL
SELECT ROUND((pnorm(0.8) - pnorm(-0.8))::NUMERIC,4) AS p;
```

```console
p
--------
0.5763
```

## Problem 7

```console
P(mu - c*sigma <= Z <= mu + c*sigma) = P( -c <= Z <= c)
                                     = F(c) - (1 - F(c))
                                     = F(c) - 1 + F(c)
                                     = 2F(c) - 1
2F(c) - 1 = 0.9876
F(c) = (1 + 0.9876)/2
```

```SQL
SELECT ROUND(qnorm((1 + 0.9876)/2)::NUMERIC,2) AS c;
```

```console
c
------
2.50
```
