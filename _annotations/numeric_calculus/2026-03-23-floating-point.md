---
layout: post
title:  "Numeric Calculus - Floating Point"
date:   2026-03-23 11:30:00
categories: ["Mathematics"]
tags: ["Numeric Calculus"]
---

<img width="600" src="{{ '/assets/images/annotations/numeric_calculus/2026-03-23-floating-point.jpeg' | relative_url }}" alt="Handwritten notes on floating-point representation (transcription below)">

<details markdown="1">
<summary>Transcription of the handwritten notes</summary>

**Floating point representation**

Standard way computers handle real numbers.

**The mathematical theorem**

A floating-point number is a sum of powers of 2. Any real number x can be approximated by

x = (−1)<sup>s</sup> × (1 + f) × 2<sup>e − B</sup>

Where:

- **s**: determines if the number is positive or negative.
- **f** (fraction/mantissa): binary representation to the precision, usually a fraction.
- **e**: the exponent, an unsigned integer that determines the magnitude.
- **B**: bias, a constant subtracted from the exponent so we can represent both very large and very small numbers.

</details>
