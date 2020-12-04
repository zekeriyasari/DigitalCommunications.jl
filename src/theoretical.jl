# This file includes the theoretical functions of the ber performance cureves. 

export 
    Q, dbtosnr,
    berask, 
    berpsk, 
    berfsk, 
    berqam,
    plotber 

#------------------------  Auxilary functions ---------------------------------------
"""
    $SIGNATURES

Converts `γ` from `dB` value to its real value.

# Example 
```julia 
julia> dbtosnr(2)  # γ = 2 dB
1.5848931924611136
```
"""
dbtosnr(γ) = 10^(γ / 10)

""" 
    $SIGNATURES 

Q-function defined as. 
```math 
    Q(x) = \\int_{x}^{\\infty} exp(-\\dfrac{x^2}{2}) dx
```
"""
Q(x) = 1 / 2 * erfc(x / sqrt(2))

#------------------------  Performance functions ---------------------------------------

"""
    $SIGNATURES

Returns the probability of symbol error for the snr per bit `γb` and constallation size `M` for ASK and PAM signalling 
"""
berask(γb, M) = 2 * (1 - 1 / M) * Q(sqrt(6log2(M) / (M^2 - 1) * dbtosnr(γb)))

"""
    $SIGNATURES

Returns the probability of symbol error for the snr per bit `γb` and constallation size `M` for PSK signalling 
"""
berpsk(γs, M) = 1 - quadgk(θ -> pθ(θ, dbtosnr(γs)), -π/M, π/M)[1]
pθ(θ, γs) = 1 / (2π) * exp(-γs * sin(θ) * sin(θ)) * quadgk(υ -> integrand(υ, γs, θ), 0, Inf)[1]
integrand(υ, γs, θ) = υ * exp(-1 / 2 * (υ - sqrt(2 * γs) * cos(θ))^2)

"""
    $SIGNATURES

Returns the probability of symbol error for the snr per bit `γb` and constallation size `M` for FSK signalling 
"""
function berfsk(γs, M)
    k = log2(M)
    pe = 1 / sqrt(2π) * quadgk(x -> (1 - (1  - Q(x))^(M - 1)) * exp(-1/2 * (x - sqrt(2 * dbtosnr(γs)))^2), -Inf, Inf)[1]
    # # Return probability of symbol error, not probability of bits error
    # pb = 2^(k -1) / (2^k - 1) * pe
end

"""
    $SIGNATURES

Returns the probability of symbol error for the snr per bit `γb` and constallation size `M` for QAM signalling 
"""
function berqam(γb, M)
    qval = Q(√(3log2(M) / (M - 1) * dbtosnr(γb)))
    4 * (1 - 1 / √(M)) * qval * (1 - (1 - 1 / √(M)) * qval)
end

#------------------------ Plots ---------------------------------------
"""
    $SIGNATURES

Plots the probability of symbols error versus snr per bit for the signaling `scheme`. `snr_per_bit_range` is the snr per bit range and `krange` is the symbol size of the M-ary signalling where ``M=2^k``. 
"""
function plotber(;scheme="ASK", snr_per_bit_range=collect(-4 : 1 : 20), krange = 1 : 4, 
    pltkwargs...)
    # Extract the ber function 
    schemes = ["ASK", "PSK", "QAM", "FSK"]
    scheme in schemes || throw(ArgumentError("Expected `$schemes`, got `$scheme` instead")) 
    @eval pe_vs_snr = $(Symbol("ber" * lowercase(scheme)))
    
    # Plot 
    plt = plot(xlabel="γb", ylabel="Pe", title="M-$(scheme)", pltkwargs...)
    for k in krange
        M = 2^k 
        γs = k * dbtosnr.(snr_per_bit_range)
        plot!(snr_per_bit_range,  pe_vs_snr.(γs, M), yscale=:log10, label="M=$M")
    end 
    plt
end

