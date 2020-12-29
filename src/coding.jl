# This file includes coding methods to map bit streams into symbol streams 

export GrayCoding, invmap

abstract type AbstractCoding end

""" 
    $TYPEDEF 

Gray coding. 

# Fields
    $TYPEDFIELDS

# Example
```julia 
julia> gc = GrayCoding(2) 
GrayCoding(Dict([0, 1] => 2,[1, 1] => 3,[0, 0] => 1,[1, 0] => 4))
```
"""
struct GrayCoding <: AbstractCoding 
    pairs::Dict{Vector{Int}, Int}
    function GrayCoding(M::Int)
        ispow2(M) || throw(ArgumentError("Expected `M` to be a power of 2, got $M instead"))
        k = Int(log2(M))
        m = 0 : 1 << k - 1
        codes = m .⊻ (m .>> 1)
        codes = reverse.(digits.(codes, base=2, pad=k))
        new(Dict(zip(codes, m .+ 1)))
    end
end 

show(io::IO, coding::GrayCoding) = print(io, "GrayCoding(M:$(length(coding.pairs)))")

# When a GrayCoding object is called, it maps its input bit stream to coressponding symbol stream.
function (coding::GrayCoding)(stream)
    codewords = collect(Iterators.partition(stream, Int(log2(constelsize(coding)))))
    alph = coding.pairs
    map(codewords) do codeword 
        alph[codeword]
    end
end 

"""
    $SIGNATURES 

Returns constellation size of the coding.
"""
constelsize(coding::GrayCoding) = length(coding.pairs)

"""
    $SIGNATURES

Returns the inverse of the mapping. Inverse mapping maps the levels to bit chunks. 

# Example
```julia 
julia> gray = GrayCoding(3)
GrayCoding(Dict([0, 1, 1] => 3,[0, 0, 1] => 2,[1, 1, 0] => 5,[0, 0, 0] => 1,[1, 0, 0] => 8,[1, 0, 1] => 7,[0, 1, 0] => 4,[1, 1, 1] => 6))

julia> invmap(gray)
Dict{Int64,Array{Int64,1}} with 8 entries:
  7 => [1, 0, 1]
  4 => [0, 1, 0]
  2 => [0, 0, 1]
  3 => [0, 1, 1]
  5 => [1, 1, 0]
  8 => [1, 0, 0]
  6 => [1, 1, 1]
  1 => [0, 0, 0]
```
"""
invmap(coding::AbstractCoding) = Dict([(v, k) for (k, v) in coding.pairs])
