# Type of Triangle

[Problem](https://www.hackerrank.com/challenges/what-type-of-triangle/problem?isFullScreen=true)

Write a query identifying the type of each record in the **TRIANGLES** table using its `three side lengths`. Output one of the following statements for each record in the table:

- `Equilateral`: It's a triangle with `3`  sides of equal length.
- `Isosceles`: It's a triangle with `2` sides of equal length.
- `Scalene`: It's a triangle with `3` sides of differing lengths.
- `Not A Triangle`: The given values of A, B, and C don't form a triangle.

## Input Format

The **TRIANGLES** table is described as follows:

|Column|Type|
|:----:|:--:|
|A|Integer|
|B|Integer|
|C|Integer|

Each row in the table denotes the lengths of each of a triangle's three sides.

## Sample Input

|A|B|C|
|:-:|:-:|:-:|
|20|20|23|
|20|20|20|
|20|21|22|
|13|14|30|

## Sample Output

```console
Isosceles
Equilateral
Scalene
Not A Triangle
```

## Explanation

Values in the tuple `(20,20,23)` form an Isosceles triangle, because (`A = B`).
Values in the tuple `(20,20,20)` form an Equilateral triangle, because (`A = B = C`) . Values in the tuple `(20,21,22)` form a Scalene triangle, because (`A != B != C`).
Values in the tuple `(13,14,30)` cannot form a triangle because the combined value of sides `A` and `B` is not larger than that of side `C`.

```SQL
SELECT CASE
          WHEN A + B <= C or A + C <= B or B + C <= A then "Not A Triangle"
          WHEN A = B and B = C then "Equilateral"
          WHEN A = B or A = C or B = C then "Isosceles"
          ELSE "Scalene"
       END AS triangle_sides
  FROM triangles;
```
