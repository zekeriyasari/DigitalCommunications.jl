# This file includes utilities

export Q, dbtoval, valtodb

"""
    $SIGNATURES

Converts `γ` from `dB` value to its real value.

# Example 
```julia 
julia> dbtoval(2)  # γ = 2 dB
1.5848931924611136
```
"""
dbtoval(γ) = 10^(γ / 10)


"""
    $SIGNATURES

Converts `val` tı dB scale. 
"""
valtodb(val) = 10 * log10(val)

""" 
    $SIGNATURES 

Q-function defined as. 
```math 
    Q(x) = \\int_{x}^{\\infty} exp(-\\dfrac{x^2}{2}) dx
```
"""
Q(x) = 1 / 2 * erfc(x / sqrt(2))


