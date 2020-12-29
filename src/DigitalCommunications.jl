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
include("modulation/baseband.jl")
include("modulation/bandpass.jl")
# include("channel.jl")
# include("detector.jl")

end # module 
