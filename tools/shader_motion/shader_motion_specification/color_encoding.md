# Overview

This section discusses how to encode a bounded real number into RGB colors.

All RGB colors are assumed to be sRGB with gamma correction, with each component in [0,1].

We assume the real number is normalized in [0,1] without loss of generality.

Then the encoding is simply a function from [0,1] to [0,1]ⁿ, where n is 3 times the number of colors.

We require the function to be continuous to avoid jitter from quantization.

As a result, the goal is to **find a continuous curve in n-dimensional cube**.

# Theory

The encoding curve should behave like a space-filling curve to maximize coding efficiency.

We choose **base-3 Gray curve** to be the encoding curve,
after experimenting with other bases like 2,4 and other curves like Hilbert curve.

A *base-3 Gray curve* is obtained by connecting adjacent points in base-3 Gray code.
For example when n=2, Gray code is a function from {0, .., 8} to {0,1,2}².

```
0 -> 00, 1 -> 01, 2 -> 02
3 -> 12, 4 -> 11, 5 -> 10
6 -> 20, 7 -> 21, 8 -> 22
```

After scaling the domain and range into [0,1] and [0,1]² and linear interpolation,
it becomes a continuous function from [0,1] to [0,1]².

# Practice

The frame layout section needs to encode a real number between ±1 into two RGB colors.
Here is the encoding algorithm:

1. Apply the function `x ↦ (x+1)/2` to normalize the input number from [-1,+1] to [0,1].
2. Apply the encoding curve with n=6 to get 6 numbers in [0,1].
3. Interpret the 6 numbers as two RGB colors in the order of GRBGRB.

Note the order GRB is chosen to maximize coding efficiency,
because H.264 encodes in YCrCb space where G-axis is the longest.

There is no specification of the decoding algorithm,
other than it being the left inverse of the encoding algorithm.
However, custom implementation is strongly recommended to decode
by finding the nearest curve point.

# Integral & fraction parts

TBD