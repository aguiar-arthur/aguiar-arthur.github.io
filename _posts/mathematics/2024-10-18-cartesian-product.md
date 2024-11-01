---
layout: post
title:  "Cartesian Product"
date:   2024-10-18 22:20:00
gategories: ["Mathematics"]
tags: ["Graphics"]
---

{% include mathjax.html %}

The **Cartesian product** is a mathematical operation that returns all possible pairs of elements from two or more sets. 
If you have two sets $$A$$ and $$B$$, their Cartesian product, denoted as $$A \times B$$, is the set of all ordered pairs $$(a, b)$$ where $$a \in A$$ and $$b \in B$$.

For example, if:

$$A = \{1, 2\}$$
$$B = \{a, b\}$$

Then their Cartesian product $$A \times B$$ would be:

$$A \times B = \{ (1, a), (1, b), (2, a), (2, b) \}$$

We can formally denote this as: 

$$A×B={(a,b) ∣ a∈A and b∈B}$$

The Cartesian product can be extended to more than two sets, and it's frequently used in areas like database queries 
(for joins) or in programming when dealing with combinations of multiple sets or lists.

### Cartesian Product in Geometry

We see cartesian product in **coordinate systems** and **higher-dimensional spaces**.

### 2D and 3D Cartesian Coordinate Systems

In geometry, the **Cartesian plane** (2D) and **Cartesian space** (3D) are direct applications of Cartesian products of sets of real numbers.

The **Cartesian plane** $$\mathbb{R}^2$$ is the product of two sets of real numbers:

$$\mathbb{R}2=\mathbb{R}×\mathbb{R}={(x,y) ∣ x∈\mathbb{R},y∈\mathbb{R}}$$

This gives us the familiar 2D grid where every point has an $$(x,y)$$-coordinate. Similarly, **3D space** $$\mathbb{R}^3$$ is the Cartesian product of three sets of real numbers:

$$\mathbb{R}3=\mathbb{R}×\mathbb{R}×\mathbb{R}={(x,y,z) ∣ x,y,z∈\mathbb{R}}$$

**I like graph theory, so I would like to highlight a little about this same topic but on graphs!** 

### Cartesian Product in Graph Theory

In **graph theory**, we use Cartesian product to get the **product graphs.** 
the product of two graphs $$G$$ and $$H$$ is a new graph denoted by $$G×H$$. 
The vertices of $$G×H$$ are all possible ordered pairs of vertices from $$G$$ and $$H$$, and there is an edge between two vertices $$(g1, h1)$$ and $$(g2, h2)$$ if and only if:

- $$g1​=g2$$ and $$h1$$ is adjacent to $$h2$$, or
- $$h1 = h2$$ and $$g1$$  is adjacent to $$g2$$

All of this is just to say that cartesian products are pretty useful in computer science, probably is near than you can imagine. 
Cross Join is a cartesian product of two tables! You can also see that this context is coupled to set theory, so, next time working with any colecition, pay attention in their relationship.

Thanks, bye!

## References:

- Halmos, P. R. *Naive Set Theory*. Springer, 1974.
- Apostol, T. M. *Mathematical Analysis*. Addison-Wesley, 1974
