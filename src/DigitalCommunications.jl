#= 
    A module for digital communications 
=# 
module DigitalCommunications

using Plots 
using QuadGK 
using SpecialFunctions
using DocStringExtensions
using LinearAlgebra

include("theoretical.jl")
include("blocks.jl")

end # module 
