# This file includes the bit stream generator 

export Generator

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
