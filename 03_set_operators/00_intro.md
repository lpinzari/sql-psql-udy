# Introduction

In the previous lessons we introduced the notion of `relation` as a **table representing a set of tuples (rows)**.

So it makes sense to define for them the traditional set operators of **union**, **difference** and **intersection**. However we must be aware of the fact that a relation is not generically a set of tuples, but a set of `homogenous tuples`, that is, **tuples defined on the same attributes**. So, even if it were possible, in principle, to define these operators on any pair of relations, there is no sense, from the point of view of the relational model, in defining them with reference to relations on different attributes.

For example, the union of two relations `r1` and `r2` on different schemas would be a set of *heterogeneous tuples*, some defined on the attributes of r1 and the others on those of r2. This would be unsatisfactory, because a set of heterogeneous tuples is not a relation and, in order to combine the operators to form complex expressions, we want the results to be relations.

Therefore, in relational algebra, we allow applications of operators of union, intersection and difference only to pairs of relations defined on the same attributes.

- the `union` of two relations `r1(X)` and `r2(X)`, defined on the same set of attributes `X`, is expressed as `r1 ∪ r2` and is also a relation on `X` containing the **tuples that belong to** `r1` **or** to `r2`, or **to both**;

- the `difference` of `r1(X)` and `r2(X)` is expressed as `r1 − r2` and is a relation on `X` containing the **tuples that belong to** `r1` **and not to** `r2`;

- the `intersection` of `r1(X)` and `r2(X)` is expressed as `r1 ∩ r2` and is a relation on `X` containing the **tuples that belong to both** `r1` **and** `r2`.

In this lesson we introduce the main set operators in `SQL`.

- `UNION`
- `INTERSECT`
- `EXCEPT`

We have already used these operators in the definition of `INNER` and `OUTER` JOINS Queries introduced in the previous chapter of this course.

In this chapter we provide a more structured approach to these operators and illustrate how to use the set operators to the implementation of a `division` between Relations in a Database. It's worth noting that `DIVISION` between tables is not implemented in RDMS.
