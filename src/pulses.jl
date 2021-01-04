# This file includes modulation pulses 

export RectangularPulse, RaisedCosinePulse, bandwidth

abstract type AbstractPulse end 

"""
    $TYPEDEF

RectangularPulse pulse shape of the form,
```math 
    p(t) = 
    \\begin{cases}
    A & 0 \\leq t \\leq T \\
    0 & othersie \\
    \\end{cases}
```
where ``A`` is the amplitude and ``T`` is the pulse duration.

# Fields 
    $TYPEDFIELDS
"""
struct RectangularPulse <: AbstractPulse
    "Amplitude"
    amplitude::Float64 
    "Period"
    duration::Float64 
end 
RectangularPulse() = RectangularPulse(1., 1.)

(pulse::RectangularPulse)(t) = 0 ≤ t ≤ pulse.duration ? pulse.amplitude : zero(Float64)

"""
    $TYPEDEF

Raised coise pulse shapse of the form, 
```math 
    p(t) = 
    \\begin{cases} 
    \\drac{A}{2}(1 - cos(w t) & 0 \\leq t \\leq T \\
    0 & othersie \\
    \\end{cases}
```

# Fields 
    $TYPEDFIELDS
"""
struct RaisedCosinePulse <: AbstractPulse
    amplitude::Float64 
    duration::Float64 
end 
RaisedCosinePulse() = RaisedCosinePulse(1., 1.)

(pulse::RaisedCosinePulse)(t) = 0 ≤ t ≤ pulse.duration ? pulse.amplitude/2 * (1 - cos(2π/pulse.duration * t)) : zero(Float64)

"""
    $SIGNATURES

Returns the energy of the pulse `pulse`

# Example 
```julia 

```
"""
energy(pulse::RectangularPulse) = (pulse.amplitude)^2 * pulse.duration
energy(pulse::RaisedCosinePulse) = (pulse.amplitude)^2 * 3 / 8

"""
    $SIGNATURES

Returns the effetive bandwidth of the `pulse` in units of Hz.
"""
bandwidth(pulse::Union{RectangularPulse, RaisedCosinePulse}) = 1 / pulse.duration
