# This file includes to blocks used in a digital communication system.

export Detector, isml 

"""
    $TYPEDEF

Baseband optimal detector. 

!!! note 
    If elements of `probs` are equal to each other, than detector detects symbols in the maximum likelihood (ML)
    mode. Otherwise, it detects in the maximum a posterior probabilities (MAP) mode.   

# Fields

    $TYPEDFIELDS
"""
struct Detector{T} 
    "Basis reference of the detector"
    refs::T
    "A priori probabilities of the message symbols"
    probs::Vector{Float64}
    "2 times the power spectral density of channel noise"
    N0::Float64
end
Detector(refs) = Detector(refs, fill(1 / length(refs), length(refs)), NaN)

"""
    $SIGNATURES

Returns true if `detector` is a maximum likelihood detector, i.e, a priori probabilities of its reference refs are
equal.
"""
isml(detector::Detector) = (probs = detector.probs; all(probs .≈ probs[1]))

(detector::Detector)(rx) = isml(detector) ? mldetect(detector, rx) : mapdetect(detector, rx) 

function mapdetect(detector::Detector, rx)
    Es = 1 / 2 * energy.(detector.refs)
    Pm = detector.N0 * log.(detector.probs)
    map(rx) do ri 
        argmax(map(s -> real(ri ⋅ s), detector.refs) - Es + Pm)
    end
end

function mldetect(detector::Detector, rx)
    Es = 1 / 2 * energy.(detector.refs)
    map(rx) do ri 
        argmax(map(s -> real(ri ⋅ s), detector.refs) - Es)
    end
end

