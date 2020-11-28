# This file includes to blocks used in a digital communication system.

export 
    Generator, 
    AbstractCoding, GrayCoding, invmap,
    AbstractScheme, ASK, PSK, QAM, FSK, 
    Modulator, scheme, alphabet, symbolsize, mapstream, modulate, signalset,
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

"""
    $TYPEDEF

Pulse Amplitude Modulation. The mapping rule is 
```math 
    s_m = A_m p(t) \\quad m = 1, \\ldots, M
```
"""
struct PAM <: AbstractScheme end 

"""
    $TYPEDEF

Amplitude Shift Keying. The mapping rule is 
```math 
    s_m = A_m g(t) cos(w_c t)  \\quad m = 1, \\ldots, M
```
where ``A_m = 2m - 1 - M`` 
"""
struct ASK <: AbstractScheme end 

"""
    $TYPEDEF

Phase Shift Keying. The mapping rule is 
```math 
    s_m = g(t) cos(w_c t - \\theta_m) \\quad m = 1, \\ldots, M
```
where ``\\theta_m = \\dfrac{2\\pi(m - 1)}{M}``.
"""
struct PSK <: AbstractScheme end 

"""
    $TYPEDEF


Frequency Shift Keying. The mapping rule is 
```math 
    s_m = A cos(w_c t + w_m t) \\quad m = 1, \\lots, M
```
where ``w_m = m \\Delta f``
"""
struct FSK <: AbstractScheme end 

"""
    $TYPEDEF

Quadrature Amplitude Modulation. The mapping rule is 
```math 
    s_m = A_{mi} g(t) cos(w_c t) - A_{mi} g(t) sin(w_c t) 
```
where the amplitudes ``A_{mi}, A_{mq} \\in \\{ \\pm 1, \\pm 3, \\ldots, \\pm (M - 1) \\}`` 
"""
struct QAM <: AbstractScheme end 

"""
    $TYPEDEF

Baseband digital modulator.

# Fields 
    $TYPEDFIELDS
"""
struct Modulator{ST<:AbstractScheme, CT<:AbstractCoding}
    "Modulation scheme"
    scheme::ST
    "Constellation size"
    M::Int 
    "Coding to map stream to code words"
    coding::CT
end 
Modulator(scheme::ST, M::Int) where {ST} = Modulator(scheme, M, GrayCoding(Int(log2(M))))

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
signalset(modulator::Modulator) = 
    map(level -> modulate(modulator, level), modulator.coding.pairs |> values |> collect |> sort)

"""
    $SIGNATURES

Returns scheme of the modulation `modulator`. 
"""
scheme(modulator::Modulator{ST, CT}) where {ST, CT} = ST

"""
    $SIGNATURES

Returns the symbols size of the modulator `modulator`.
"""
symbolsize(modulator::Modulator) = Int(log2(modulator.M))

"""
    $SIGNATURES

Returns the alphabet of the modulator `modulator`.

# Example
```julia 
julia> modulator = Modulator(PSK(), 4)  # 4-PSK modulator 
Modulator{PSK,GrayCoding}(PSK(), 4, GrayCoding(Dict([0, 1] => 2,[1, 1] => 3,[0, 0] => 1,[1, 0] => 4)))

julia> alphabet(modulator)
Dict{Array{Int64,1},Int64} with 4 entries:
  [0, 1] => 2
  [1, 1] => 3
  [0, 0] => 1
  [1, 0] => 4
```
"""
alphabet(modulator::Modulator) = modulator.coding.pairs


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

julia> mapstream(modulator, bits)
5-element Array{Int64,1}:
 1
 2
 4
 4
 1
```
"""
function mapstream(modulator::Modulator, stream) 
    # Construct codewords
    k = symbolsize(modulator)
    codewords = collect(Iterators.partition(stream, k))

    # Map codewords into levels 
    alph = modulator.coding.pairs
    map(codewords) do codeword 
        alph[codeword]
    end
end 

# Modulator is callable. When called with a bit stream, 
# it modulates the bit stream into message symbols. 
function (modulator::Modulator)(stream) 
    levels = mapstream(modulator, stream)
    map(levels) do m 
        modulate(modulator, m)
    end
end

modulate(modulator::Modulator{ASK, CT}, m) where CT = [2m - 1 - modulator.M]
modulate(modulator::Modulator{PSK, CT}, m) where CT = (θ = 2π / modulator.M * (m - 1); [cos(θ), sin(θ)])


#------------------------- AWGN Vector Channel ------------------------------------

"""
    $TYPEDEF

Additive white Gaussian noise channel. 

# Fields 

    $TYPEDFIELDS
"""
struct AWGNChannel 
    "Mean"
    m::Float64 
    "Standard deviation"
    σ::Float64 
end 

# Channel is callable. When called with the message signal, 
# it corrupts the message signals by adding noise. 
function (channel::AWGNChannel)(s)
    N = length(s[1])
    K = length(s)
    # NOTE: Since the AWGN channe is in baseband, the variance of noise in the baseband is 4 times that of noise in the 
    # bandpass. So, we multiply 2 times channel standard deviation. 
    n = 2 * channel.σ  * [randn(N) for i in 1 : K] 
    s + n 
end


# ------------------------------------ Detector -------------------------------------------

abstract type AbstractDetector end
abstract type AbstractCoherentDetector <: AbstractDetector end
abstract type AbstractNonCoherentDetector <: AbstractDetector end

struct MAPDetector{ST, CT<:AbstractCoding} <: AbstractCoherentDetector
    signals::ST
    probs::Vector{Float64}
    N0::Float64
    coding::CT
end 
MAPDetector(signals, probs, N0) = MAPDetector(signals, probs, N0, GrayCoding(length(signals)))

function (detector::MAPDetector)(r) end 

struct MLDetector{ST, CT<:AbstractCoding} <: AbstractCoherentDetector
    signals::ST
    coding::CT
end
MLDetector(signals) = MLDetector(signals, GrayCoding(Int(log2(length(signals)))))

function (detector::MLDetector)(r)
    signals = detector.signals 
    imap = invmap(detector.coding)
    codewords = map(r) do rm 
        imap[
            argmax(
                real.(map(s -> dot(rm, s), signals)) - 1 / 2 * norm.(signals).^2
                )
            ]
    end
    codewords
    # vcat(codewords...)
end

