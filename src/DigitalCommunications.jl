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
include("schemes.jl")
include("modulator.jl")
include("channel.jl")
include("detector.jl")

end # module 
