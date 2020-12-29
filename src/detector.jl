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
    "Coding method from bit stream to symbol stream"
    coding::CT
end
MLDetector(signals) = MLDetector(signals, GrayCoding(Int(log2(length(signals)))))

function (detector::MLDetector)(rx)
    Es = 1 / 2 * energy.(detector.signals)
    map(rx) do ri 
        argmax(map(s -> ri ⋅ s, detector.signals) - Es)
    end
    #= 
    Note: The output of the detector is the symbol stream, not the bit stream. 
    Thus, the code block below is commented. 
    =#
    # imap = invmap(detector.coding)
    # map(r) do ri 
    #     imap[argmax(map(s -> ri ⋅ s, ss) - 1 / 2 * norm.(ss).^2)]
    # end
end

