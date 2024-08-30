---
layout: post
title:  "Big O is not difficult - Part 1"
date:   2024-08-29 23:00:00
categories: ["Computer Science"]
Tags: ["Algorithms", "Big O"]
---

{% include mathjax.html %}

In this series, I just want to cover the foundations of Big O notation. Nothing better to start from: 

# Asymptotic behavior

Asymptotic behavior in computer science and mathematics describes how a function behaves as its input grows towards infinity. 
Read this as a loop, and we use this to check if an algorithm is efficient. 

So, the goal here is to understand the behavior of an algorithm as the size of the input (denoted as $$n$$) gets bigger. 
Basically, "Is this shit slower when it gets bigger?”.

To check if it is efficient or performant, first of all we need to know the Growth Functions.

## Growth Functions

**Constant Growth**: 

A function that has constant growth, represented by: $$f(n) = c$$. For example, accessing and array by its index is $$O(1)$$.

**Logarithmic Growth**: 

A function that increases slower as $$n$$ gets bigger. represented by $$f(n) = log(n)$$. 

At least for me, this explain nothing if you don't know what is logarithms, so lets step back again. 

## Logarithms

This is a function that represent the exponent of power to which a base number must be raised to produce another number, like $$n^x=y$$. 

It is even easier in computer science, because we need to care almost only about powers of 2 or $$log_2$$! 

**Growth**

Logarithmic growth describes a type of growth that increases rapidly at first and then slows down over time, 
eventually approaching a constant rate as the values increase.

As $$x$$ increases, the rate of growth diminishes. For large values of $$x$$, additional increases in 
$$x$$ lead to smaller increases in $$f(x)$$. For example, increasing $$x$$ from 100 to 1000 produces 
the same amount of increase in a logarithmic function as increasing $$x$$from 10 to 100.

Thanks, bye!
