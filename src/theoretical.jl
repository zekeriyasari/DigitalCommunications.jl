# This file includes the theoretical functions of the ber performance cureves. 

using Plots 
using QuadGK 
using SpecialFunctions

export 
    Q, ebno,
    prob_symbol_error_vs_snr_per_bit_ask, 
    prob_symbol_error_vs_snr_per_bit_psk, 
    prob_symbol_error_vs_snr_per_bit_fsk, 
    prob_symbol_error_vs_snr_per_bit_qam,
    plot_symbol_error_vs_snr_per_bit 

#------------------------  Auxilary functions ---------------------------------------
"""
    $SIGNATURES

Converts `γ` from `dB` value to its real value.

# Example 
```julia 
julia> ebno(2)  # γ = 2 dB
1.5848931924611136
```
"""
ebno(γ) = 10^(γ / 10)

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
prob_symbol_error_vs_snr_per_bit_ask(γb, M) = 2 * (1 - 1 / M) * Q(sqrt(6log2(M) / (M^2 - 1) * γb))

"""
    $SIGNATURES

Returns the probability of symbol error for the snr per bit `γb` and constallation size `M` for PSK signalling 
"""
prob_symbol_error_vs_snr_per_bit_psk(γs, M) = 1 - quadgk(θ -> pθ(θ, γs), -π/M, π/M)[1]
integrand(υ, γs, θ) = υ * exp( -1 / 2 * (υ - sqrt(2 * γs) * cos(θ))^2 )
pθ(θ, γs) = 1 / (2π) * exp(-γs * sin(θ) * sin(θ)) * quadgk(υ -> integrand(υ, γs, θ), 0, Inf)[1]

"""
    $SIGNATURES

Returns the probability of symbol error for the snr per bit `γb` and constallation size `M` for FSK signalling 
"""
function prob_symbol_error_vs_snr_per_bit_fsk(γs, M)
    k = log2(M)
    pe = 1 / sqrt(2π) * quadgk(x -> (1 - (1  - Q(x))^(M - 1)) * exp(-1 / 2 * (x - sqrt(2 * γs))^2), -Inf, Inf)[1]
    pb = 2^(k -1) / (2^k - 1) * pe
end

"""
    $SIGNATURES

Returns the probability of symbol error for the snr per bit `γb` and constallation size `M` for QAM signalling 
"""
prob_symbol_error_vs_snr_per_bit_qam(γb, M) = 4 * (1 - 1 / sqrt(M)) * Q(sqrt(3log2(M) / (M - 1) * γb)) * 
    (1 - (1 - 1 / sqrt(M)) * Q(sqrt(3log2(M) / (M - 1) * γb)))

#------------------------ Plots ---------------------------------------
"""
    $SIGNATURES

Plots the probability of symbols error versus snr per bit for the signaling `scheme`. `snr_per_bit_range` is the snr per bit range and `krange` is the symbol size of the M-ary signalling where ``M=2^k``. 
"""
function plot_symbol_error_vs_snr_per_bit(;scheme="ASK", snr_per_bit_range=collect(-4 : 1 : 20), krange = 1 : 4, 
    vertical_lims=(10^-6, 10^-1))
    # Extract the ber function 
    schemes = ["ASK", "PSK", "QAM", "FSK"]
    scheme in schemes || throw(ArgumentError("Expected `$schemes`, got `$scheme` instead")) 
    @eval pe_vs_snr = $(Symbol("prob_symbol_error_vs_snr_per_bit_" * lowercase(scheme)))
    
    # Plot 
    plt = plot(xlabel="γb", ylabel="Pe", title="M-$(scheme)")
    for k in krange
        M = 2^k 
        γs = k * ebno.(snr_per_bit_range)
        plot!(snr_per_bit_range,  pe_vs_snr.(γs, M), yscale=:log10, label="M=$M")
    end 
    ylims!(vertical_lims[1], vertical_lims[2])
    plt
end

