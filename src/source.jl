# This file includes the bit stream generator 

export BitGenerator, SymbolGenerator

"""
    $TYPEDEF

Bit stream generator 

# Fields 

    $TYPEDFIELDS
"""
struct BitGenerator 
    "Generated bits"
    bits::Vector{Bool}
    BitGenerator(nbits::Int) = new(rand(Bool, nbits))
end 


"""
    $TYPEDEF

Symbol generator 

# Fields
    $TYPEDFIELDS
"""
struct SymbolGenerator
    "Generated symbols"
    symbols::Vector{Int}
    SymbolGenerator(ns::Int, M::Int) = new(rand(1 : M, ns))
end 
