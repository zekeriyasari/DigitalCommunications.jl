#= 
    A module for digital communications 
=# 
module DigitalCommunications

using Plots 
using QuadGK 
using SpecialFunctions
using DocStringExtensions
using LinearAlgebra
import Base: show 

include("utils.jl")
include("theoretical.jl")
include("source.jl")
include("coding.jl")
include("modulation/pulses.jl") 
include("modulation/schemes.jl")
include("modulation/vector_modulator.jl")
include("modulation/waveform_modulator.jl")
include("channel/vector_channel.jl")
include("channel/waveform_channel.jl")
include("detector/vector_detector.jl")
include("detector/waveform_detector.jl")

end # module 
