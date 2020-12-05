# This file includes to blocks used in a digital communication system.

export 
    Generator, 
    AbstractCoding, GrayCoding, invmap,
    AbstractScheme, ASK, PSK, QAM, FSK, PAM, 
    Modulator, scheme, alphabet, symbolsize, stream_to_symbols, modulate, signalset, constellation,
    AWGNChannel,
    AbstractDetector, AbstractCoherentDetector, AbstractNonCoherentDetector, MAPDetector,  MLDetector

#-------------------------  Stream Generator ------------------------------------
"""
    $TYPEDEF

Bit stream generator 

# Fields 

    $TYPEDFIELDS
"""
struct Generator 
    bits::Vector{Bool}
    Generator(nbits::Int) = new(rand(Bool, nbits))
end 

#------------------------- Stream Coding ------------------------------------

abstract type AbstractCoding end

""" 
    $TYPEDEF 

Gray coding. 

!!! note 
    In Gray coding just a single bit changes between adjacent symbols

# Fields

    $TYPEDFIELDS
"""
struct GrayCoding <: AbstractCoding 
    pairs::Dict
end 

show(io::IO, coding::GrayCoding) = print(io, "GrayCoding(M:$(length(coding.pairs)))")

"""
    GrayCoding(k)

Constructs a `GrayCoding` with symbol size `k`. 

# Example 
```julia 
julia> gc = GrayCoding(2) 
GrayCoding(Dict([0, 1] => 2,[1, 1] => 3,[0, 0] => 1,[1, 0] => 4))
```
"""
function GrayCoding(k::Int)
    m = 0 : 1 << k - 1
    codes = m .⊻ (m .>> 1)
    codes = reverse.(digits.(codes, base=2, pad=k))
    GrayCoding(Dict(zip(codes, m .+ 1)))
end

"""
    $SIGNATURES

Returns the inverse of the mapping. Inverse mapping maps the levels to bit chunks. 

# Example
```julia 
julia> gray = GrayCoding(3)
GrayCoding(Dict([0, 1, 1] => 3,[0, 0, 1] => 2,[1, 1, 0] => 5,[0, 0, 0] => 1,[1, 0, 0] => 8,[1, 0, 1] => 7,[0, 1, 0] => 4,[1, 1, 1] => 6))

julia> invmap(gray)
Dict{Int64,Array{Int64,1}} with 8 entries:
  7 => [1, 0, 1]
  4 => [0, 1, 0]
  2 => [0, 0, 1]
  3 => [0, 1, 1]
  5 => [1, 1, 0]
  8 => [1, 0, 0]
  6 => [1, 1, 1]
  1 => [0, 0, 0]
```
"""
invmap(coding::AbstractCoding) = Dict([(v, k) for (k, v) in coding.pairs])

#------------------------- Modulator ------------------------------------
"""
    $TYPEDEF

Abstract type for modulation schemes such as PAM, ASK, PSK, FSK, QAM, etc. 
"""
abstract type AbstractScheme end


for scheme in [:ASK, :PAM, :PSK, :QAM, :FSK]
    @eval begin 
        struct $(scheme){T} <: AbstractScheme 
            "Scheme symbol size"
            M::Int
            "Symbol alphabet"
            alphabet::T
        end
        $(scheme)(M::Int) = $(scheme)(M, getalphabet($scheme, M))
    end
end

show(io::IO, scheme::T) where T <: AbstractScheme = print(io, "$(scheme.M)-$(T.name)")

function getalphabet(scheme::Type{PAM}, M::Int)
    [[2m - 1 - M] for m in 1 : M]
    # collect(2 * (1 : M) .- 1 .- M)
end 
function getalphabet(scheme::Type{ASK}, M::Int)
    [[2m - 1 - M] for m in 1 : M]
    # collect(2 * (1 : M) .- 1 .- M)
end 
function getalphabet(scheme::Type{PSK}, M::Int) 
    map(1 : M) do m 
        θ = 2π / M *  (m - 1)
        [cos(θ), sin(θ)]
    end
end
function getalphabet(scheme::Type{QAM}, M::Int)
    M = Int(sqrt(M))
    vec([[i, j] for i in -(M - 1) : 2 : (M - 1), j in -(M - 1) : 2 : (M - 1)])
end

# TODO: Implement `getalphabet` method for FSK 
function getalphabet(scheme::Type{FSK}, M::Int) end 

"""
    $SIGNATURES

Returns the symbols size of `scheme`.

# Example 
```julia 
julia> sch = PSK(4);

julia> symbolsize(sch)
2
```
"""
symbolsize(scheme::AbstractScheme) = Int(log2(scheme.M))

##### Scheme documentation. 

"""
    $TYPEDEF
Pulse Amplitude Modulation. The mapping rule is 
```math 
    s_m = A_m p(t) \\quad m = 1, \\ldots, M
```
"""
PAM

"""
    $TYPEDEF

Amplitude Shift Keying. The mapping rule is 
```math 
    s_m = A_m g(t) cos(w_c t)  \\quad m = 1, \\ldots, M
```
where ``A_m = 2m - 1 - M`` 
"""
ASK

"""
    $TYPEDEF

Phase Shift Keying. The mapping rule is 
```math 
    s_m = g(t) cos(w_c t - \\theta_m) \\quad m = 1, \\ldots, M
```
where ``\\theta_m = \\dfrac{2\\pi(m - 1)}{M}``.
"""
PSK 

"""
    $TYPEDEF


Frequency Shift Keying. The mapping rule is 
```math 
    s_m = A cos(w_c t + w_m t) \\quad m = 1, \\ldots, M
```
where ``w_m = m \\Delta f``
"""
FSK 

"""
    $TYPEDEF

# Fields 

    $TYPEDFIELDS

Quadrature Amplitude Modulation. The mapping rule is 
```math 
    s_m = A_{mi} g(t) cos(w_c t) - A_{mi} g(t) sin(w_c t) 
```
where the amplitudes ``A_{mi}, A_{mq} \\in \\{ \\pm 1, \\pm 3, \\ldots, \\pm (M - 1) \\}`` 
"""
QAM

"""
    $TYPEDEF

Baseband digital modulator.

# Fields 
    $TYPEDFIELDS
"""
struct Modulator{ST<:AbstractScheme, CT<:AbstractCoding}
    "Modulation scheme"
    scheme::ST
    "Coding to map stream to code words"
    coding::CT
end 
Modulator(scheme) = Modulator(scheme, GrayCoding(symbolsize(scheme)))

show(io::IO, modulator::Modulator)= print(io, "Modulator(scheme:$(modulator.scheme), coding:$(modulator.coding))")

""" 
    $SIGNATURES

Returns the signal set of the modulator

# Example 
```julia 
julia> modulator = Modulator(PSK(), 4)
Modulator{PSK,GrayCoding}(PSK(), 4, GrayCoding(Dict([0, 1] => 2,[1, 1] => 3,[0, 0] => 1,[1, 0] => 4)))

julia> signalset(modulator)
4-element Array{Array{Float64,1},1}:
 [1.0, 0.0]
 [6.123233995736766e-17, 1.0]
 [-1.0, 1.2246467991473532e-16]
 [-1.8369701987210297e-16, -1.0]
```
"""
function signalset(modulator::Modulator) 
    @warn "`signalset(modulator)` has been deprecated, use `alphabet(modulator)` instead."
    alphabet(modulator)
end

"""
    $SIGNATURES

Returns scheme of the modulation `modulator`. 
"""
scheme(modulator::Modulator{ST, CT}) where {ST, CT} = modulator.scheme

"""
    $SIGNATURES

Returns the symbols size of the modulator `modulator`.
"""
symbolsize(modulator::Modulator) = symbolsize(modulator.scheme)

"""
    $SIGNATURES

Returns the alphabet of the modulator `modulator`.

# Example
```julia 
julia> modulator = Modulator(PSK(4))
Modulator(scheme:4-PSK, coding:GrayCoding(M:4))

julia> alphabet(modulator)
4-element Array{Array{Float64,1},1}:
 [1.0, 0.0]
 [6.123233995736766e-17, 1.0]
 [-1.0, 1.2246467991473532e-16]
 [-1.8369701987210297e-16, -1.0]
```
"""
alphabet(modulator::Modulator) = modulator.scheme.alphabet


"""
    $SIGNATURES

Maps the bit stream into different levels according to the `coding` of the modulator `modulator`.

# Example 
```julia 
julia> modulator = Modulator(PSK(), 4)  # 4-PSK modulator 
Modulator{PSK,GrayCoding}(PSK(), 4, GrayCoding(Dict([0, 1] => 2,[1, 1] => 3,[0, 0] => 1,[1, 0] => 4)))

julia> bits = rand(Bool, 10)
10-element Array{Bool,1}:
 0
 0
 0
 1
 1
 0
 1
 0
 0
 0

julia> stream_to_symbols(modulator, bits)
5-element Array{Int64,1}:
 1
 2
 4
 4
 1
```
"""
function stream_to_symbols(modulator::Modulator, stream) 
    # Construct codewords
    codewords = collect(Iterators.partition(stream, symbolsize(modulator)))

    # Map codewords into symbols 
    alph = modulator.coding.pairs
    map(codewords) do codeword 
        alph[codeword]
    end
end 

# Modulation...
(modulator::Modulator)(stream) = alphabet(modulator)[stream_to_symbols(modulator, stream)]

"""
    $SIGNATURES 

Plots the constellation diagram of the `modulator`.
"""
function constellation(modulator::Modulator{ST, CT}) where {ST, CT} 
    s = alphabet(modulator) 
    if ST <: ASK || ST <: PAM
        ymax = 1
        plt = scatter(vcat(s...), zeros(length(s)), ylims=(-ymax, ymax))
        foreach(item -> annotate!(item[2][1],  0.1, item[1]), enumerate(s)) 
    elseif ST <: PSK || ST <: QAM
        ymax = maximum(norm.(s)) * 1.25
        plt = scatter(getindex.(s, 1), getindex.(s, 2), marker=:circle, ylims=(-ymax, ymax))
        foreach(item -> annotate!(item[2][1] * 0.9, item[2][2] * 0.9, item[1]), enumerate(s)) 
    else 
        error("Unknown modulation scheme. Expected `PAM, PSK, QAM, FSK`, got $ST instead.")
    end
    plt
end

#------------------------- AWGN Vector Channel ------------------------------------

"""
    $TYPEDEF

Additive white Gaussian noise channel. `AWGNChannel` is defined by its `snr`. `snr = Eb / No` where `Eb` is the energy per bit and `No/2` is the power spectral density of the channel noise.  

# Fields 

    $TYPEDFIELDS
"""
mutable struct AWGNChannel 
    "Channel SNR(Signal-to-Noise ratio)"
    snr::Float64 
end 

function (channel::AWGNChannel)(s::AbstractVector{T}) where T <: Union{<:Real, AbstractVector{<:Real}}
    N = length(s[1])
    K = length(s)
    ϵx = sum(norm.(s).^2) / length(s)  # Message signal energy
    # Note: The input `s` is a scalar (in case of PAM/ASK) or vector(in case of PSK, QAM, FSK) real signal,  
    # the power spectral density of the noise is `No/2` and channel snr is defined as `snr = Es/No/2`
    # where `Es` is the energy per symbol.  
    σ = √(ϵx / dbtosnr(channel.snr) / 2)
    n = σ * collect(eachrow(randn(K, N)))
    s + n 
end


# ------------------------------------ Detector -------------------------------------------

""" 
    $TYPEDEF

Abstract type of detectors.
"""
abstract type AbstractDetector end

"""
    $TYPEDEF

Abstract type for cohorent detectors.
""" 
abstract type AbstractCoherentDetector <: AbstractDetector end

"""
    abstract type non-coherent detectors. 
"""
abstract type AbstractNonCoherentDetector <: AbstractDetector end

"""
    $TYPEDEF

# Fields 

    $TYPEDFIELDS
"""
struct MAPDetector{ST, CT<:AbstractCoding} <: AbstractCoherentDetector
    "Basis signals of the detector"
    signals::ST
    "A priori probabilities of the message symbols"
    probs::Vector{Float64}
    "2 times the power spectral density of channel noise"
    N0::Float64
    "Symbol coding"
    coding::CT
end 
MAPDetector(signals, probs, N0) = MAPDetector(signals, probs, N0, GrayCoding(length(signals)))

# TODO: Implement `MAPDetector` call methods.
function (detector::MAPDetector)(r) end 

"""
    $TYPEDEF

# Fields

    $TYPEDFIELDS
"""
struct MLDetector{ST, CT<:AbstractCoding} <: AbstractCoherentDetector
    "Basis signals of the detector"
    signals::ST
    "Symbol encoding"
    coding::CT
end
MLDetector(signals) = MLDetector(signals, GrayCoding(Int(log2(length(signals)))))

function (detector::MLDetector)(r)
    ss = detector.signals 
    map(r) do ri 
        argmax(map(s -> ri ⋅ s, ss) - 1 / 2 * norm.(ss).^2)
    end
    # imap = invmap(detector.coding)
    # map(r) do ri 
    #     imap[argmax(map(s -> ri ⋅ s, ss) - 1 / 2 * norm.(ss).^2)]
    # end
end

