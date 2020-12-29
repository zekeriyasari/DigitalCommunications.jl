# This file includes to blocks used in a digital communication system.

export MAPDetector,  MLDetector

abstract type AbstractDetector end
abstract type AbstractCoherentDetector <: AbstractDetector end
abstract type AbstractNonCoherentDetector <: AbstractDetector end

"""
    $TYPEDEF

# Fields 

    $TYPEDFIELDS
"""
struct MAPDetector{ST} <: AbstractCoherentDetector
    "Basis signals of the detector"
    signals::ST
    "A priori probabilities of the message symbols"
    probs::Vector{Float64}
    "2 times the power spectral density of channel noise"
    N0::Float64
end 

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
end
MLDetector(signals) = MLDetector(signals, GrayCoding(Int(log2(length(signals)))))

function (detector::MLDetector)(rx)
    Es = 1 / 2 * energy.(detector.signals)
    map(rx) do ri 
        argmax(map(s -> ri ⋅ s, detector.signals) - Es)
    end
end

