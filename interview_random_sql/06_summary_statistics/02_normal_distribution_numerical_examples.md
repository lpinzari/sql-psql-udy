# Normal Distribution Numerical examples

Let `Z` be a random standard normal variable. Compute the following probabilities

1. P(Z < 1.6) = F(1.6) = 0.9452
2. P(Z >= 0.65) = 1 - F(0.65) = 0.2578
3. P(0.6 < Z < 1.3) = F(1.3) - F(0.6) = 0.1755
4. P(Z < -1.12) = F(-1.12) = 0.1314
5. P(-0.34 < Z < 1.3) = 0.5363
6. P(-0.82 < Z < -0.13) = 0.4549


## Problem 1

```SQL
SELECT pnorm(1.6);
```

```console
pnorm
-------------------
0.945200756634471
```

```SQL
SELECT ROUND(pnorm(1.6)::NUMERIC,4);
```

```console
round
--------
0.9452
(1 row)
```

## Problem 2

The solution is based on the following formula:

```console
P(Z >= 0.65) = 1 - F(0.65) =  0.2578
```

```SQL
SELECT 1 - ROUND(pnorm(0.65)::NUMERIC,4) AS p_z_ge_65;
```

```console
p_z_ge_65
-----------
   0.2578
```

## Problem 3

```console
P(0.6 < Z < 1.3) = F(1.3) - F(0.6) =  0.1775
```

```SQL
SELECT ROUND((pnorm(1.3) - pnorm(0.6))::NUMERIC,4) AS p;
```

```console
p
--------
0.1775
```

## Problem 4

```console
P(Z < -1.12) = F(-1.12) = 0.1314
```

```SQL
SELECT ROUND(pnorm(-1.12)::NUMERIC,4) AS p;
```

```console
p
--------
0.1314
```

## Problem 5

```console
P(-0.34 < Z < 1.3) = F(1.3) - F(-0.34) = 0.5363
```

```SQL
SELECT ROUND((pnorm(1.3) - pnorm(-0.34))::NUMERIC,4) AS p;
```

```console
p
--------
0.5363
```

## Problem 6

```console
P(-0.82 < Z < 1.3) = F(1.3) - F(-0.82) =  0.4549
```

```SQL
SELECT ROUND((pnorm(1.3) - pnorm(-0.13))::NUMERIC,4) AS p;
```

```console
p
--------
0.4549
```
