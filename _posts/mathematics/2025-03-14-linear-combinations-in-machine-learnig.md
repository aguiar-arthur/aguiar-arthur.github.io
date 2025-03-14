---
layout: post
title:  "Linear combinations in machine learning"
date:   2025-03-14 09:00:00
categories: ["Mathematics"]
---

{% include mathjax.html %}

Linear combination is as process of combining a set of vectors using scalar (a real number ℝ or a complex number ℂ) multiplication and addition.

### First of all, what are vectors

 vectors are mathematical objects that represent quantities with both magnitude (size) and direction. In a linear combination, vectors are the "building blocks" that are scaled (multiplied by scalars) and added together to create new vectors.

For example, consider two vectors in 2D space:

$$e_ 1=\begin{bmatrix}
1 \\
0 
\end{bmatrix},
e_2=\begin{bmatrix}
0 \\
1 \\
\end{bmatrix}$$

Any vector (in this example 2D) can be written as a linear combination of $$e_1$$ and $$e_2$$:

$$V=xe_1 + ye_2 = \begin{bmatrix}
x \\
y \\
\end{bmatrix}$$

In ML we often see vectors in word embbedings in NLP, they represent words in a high-dimensional space.

In this examples I'll be using vectors aside Real numbers ℝ, so I can say that vector recive the ℝ properties, we can use **Association**:

- **for any $$u,v,w ∈V, (u+v)+w=u+(v+w)$$**

and **Commutativity**:

- **for any $$u,v ∈V, u+v=v+u$$**

also is possible to **sum** and **multiply**(usig scalars) them.

**Definition of a Linear Combination**  

Given a set of vectors $$v_1, v_2, \dots, v_n$$ and scalars $$c_1, c_2, \dots, c_n$$ (which are real or complex numbers), a **linear combination** of these vectors is an expression of the form:  

$$
w = c_1 v_1 + c_2 v_2 + \dots + c_n v_n
$$

where:  
- $$v_1, v_2, \dots, v_n$$ are the given vectors.  
- $$c_1, c_2, ..., c_n $$ are the scalars (coefficients).  
- $$w$$ is the resulting vector, which is the linear combination of the given vectors.  

#### The linear combination involves two operations:
- **Scalar multiplication:** Each vector is multiplied by a scalar.
- **Addition:** The results of the scalar multiplications are added together.

As you can see, we are very close to the linear regresion, and it's that what, we want. Beffore that lets check how to grab the scalars ($$c_n$$)

### Getting the scalars

To determine the coefficients in a model like **linear regression**, we solve for the parameters (weights and biases) that minimize the error between the model's predictions and the actual data. In this context, the coefficients are the weights $$c_1, c_2, \dots, c_n$$ and the bias $$c_0$$, which appear in the equation:

$$
y = c_1 x_1 + c_2 x_2 + \dots + c_n x_n + c_0
$$

For a **simple linear regression** model:

$$
y = c_1 x + c_0
$$

the coefficients **$$c_1$$ (slope)** and **$$c_0$$ (bias)** can be calculated using the following formulas:

#### Coefficient $$c_1$$ (Slope):  

$$
c_1 = \frac{ n \sum (x_i y_i) - \sum x_i \sum y_i }{ n \sum x_i^2 - (\sum x_i)^2 }
$$

#### Coefficient $$c_0$$ (Bias):  

$$
c_0 = \frac{ \sum y_i - c_1 \sum x_i }{ n }
$$

where:  

- $$n$$ is the number of data points.  
- $$x_i$$ are the input values.  
- $$y_i$$ are the output values.  

[Getting the scalars example](https://github.com/aguiar-arthur/linear-algebra-notebooks/blob/main/calculating_coefficients.nb)

#### **Role of the Bias $$(c_0)$$**  

The **bias** $$c_0$$ represents the baseline value of $$y$$ when all input variables are zero. It shifts the regression line up or down to better fit the data.  

#### **Role of the Slope $$(c_1)$$**  

The **slope** $$c_1$$ represents the rate of change of the output $$y$$ with respect to the input $$x$$. It indicates how much $$y$$ changes when $$x$$ increases by 1 unit.  

### **Slope and Bias in Machine Learning?**  

#### **Prediction**  
The **slope** and **bias** define the relationship between inputs and outputs, allowing the model to make predictions for new data.  

#### **Interpretability**  
- The **slope** $$c_1$$ tells you how much the output $$y$$ changes with respect to each input variable, providing insights into the importance of each feature.  
- The **bias** $$c_0$$ provides a baseline value, helping you understand the model’s behavior when all inputs are zero.  

#### **Flexibility**  
By adjusting the **slope** and **bias**, the model can fit a wide range of data patterns, from simple linear relationships to more complex ones (in the case of **multiple linear regression**).  

Let's finish with an example, applying everything I talked here (a little bit more, just to make the model better)

[Predicting numbers](https://github.com/aguiar-arthur/linear-algebra-notebooks/blob/main/machine_learning/predicting_numbers.nb)

Thanks, bye!

## References

- BOLDRINI, *R. ÁLgebra Linear. 3. ed.*, Harbra, 1984.