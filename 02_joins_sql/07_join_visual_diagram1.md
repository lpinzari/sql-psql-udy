## Positional representation of a CROSS JOIN

The previous section determined a general sorting criterion to uniquely represent any instance table and overcome the ambiguity to interpret the result of an `INNER JOIN` between tables in a cartesian Plane.

The sorting criterion must respect an ascending strict order relation on the primary key values in the parent table and a foreign-primary keys combination in the child table.

The sorted table is a bijection between the Natural numbers and the values in the selected column keys that uniquely identifies each record in a table. The set of Natural numbers, `N`, is a total ordered set and, therefore, there is a correspondence between the Cartesian Product `N x N` and the `CROSS JOIN` operator.

Following the positional notation introduced in the previous section we define the following Cartesian product of Natural integers:

![equation cartesian](./images/eq22.png)

The corresponding positional notation for relation `A` and `B` is:

![equation relation](./images/eq23.png)


In this notation **H<sub>B</sub>** and **H<sub>A</sub>** are the column headings in tables `B` and `A`.

It follows that the `CROSS JOIN` operator is defined as follow:

![equation cross product](./images/eq24cross.png)

In this notation, the set of columns in the `CROSS JOIN` table, **H**, is the Union of the column headings in relation `B` and  `A`, indicated as **H<sub>B</sub>** and **H<sub>A</sub>**.

For each ordered tuple `(i,j)`,in the Cartesian Plane, there is a corresponding `CROSS JOIN` tuple **t<sub>ij</sub>** defined on the column headings **H**.

The tuple's components consists of the projection on the subset columns **H<sub>B</sub>** and **H<sub>A</sub>** of the `CROSS JOIN` tuple. The projections return the attributes values in relation `B` and `A`.

The simplicity of this notation is better illustrated with an example:

![cross prod example](./images/eq25.png)

In this example, the two relations `A` and `B` have three rows and two columns. The resulting `CROSS JOIN` table will have four columns and 9 rows, `3 x 3`.

For instance, the `CROSS JOIN` of the example tables, `A` and `B` is:

![cross prod example output](./images/eq26.png)

The picture below shows the `CROSS PRODUCT` in the Cartesian Plane.

![graph](./images/41_cross.png)

You may have noticed that an element in the Cartesian Product is a combination of the child and parent tables records, where the first and second elements are the rows in position `i` and `j`.

- `(i,j)`
- **i**: row in position i in the child table
- **j**: row in position j in the parent table

![conditions ands](./images/eq27.png)

A tuple in the `CROSS JOIN` is a combination of Logic AND's conditions in relations B and A.

In a Relational database the columns order is not relevant and, therefore, the `CROSS JOIN` of two tables can be generalized to any columns permutation.

## Non Positional representation of a CROSS JOIN

In the previous section we illustrated the positional representation of the `CROSS JOIN` operator in the Cartesian Plane. The positional indices establish a correspondence between the Cartesian Product **N<sub>p</sub>** **X** **N<sub>q</sub>** and the `CROSS JOIN` tuples.

The Relational Model, however, is represented as a non positional tabular form. Hence, the operators between Relations must be defined only in terms of set operators and columns identifiers.

Following the non-positional notation introduced in the previous lesson, we define the `CROSS JOIN` of two tables `B` and `A` as follow:

![conditions non pos](./images/eq28.png)

A tuple in the `CROSS JOIN` is a combination of Logic AND's conditions in relation `B` and `A`, likewise the positional notation. In this notation, however, the definition of a tuple is based on an unordered pair of tuples as indicated in the last logic condition wrapped in curly braces.

This notation is better illustrated with an example:

![example non positional](./images/eq29.png)

The `CROSS JOIN` resulting table is given below:

![example non positional2](./images/eq30.png)

The first set of unordered couples of `B` and `A` elements.

![example non positional](./images/eq31.png)

The second set of unordered couples.

![example non positional](./images/eq32.png)

The last set of unordered couples.

The non-positional representation of the `CROSS JOIN` is given below.

![cross non positional](./images/cross.png)
