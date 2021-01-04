# This file includes channel objects. 

export AWGNChannel

"""
    $TYPEDEF

Additive white Gaussian noise channel. 

!!! note If `tsample` and `tsymbol` are `NaN`, then the channel operates in the vector channel mode. Otherwise, the
    channel operates in waveform channel mode. 

# Fields 

    $TYPEDFIELDS
"""
mutable struct AWGNChannel
    "Value of the noise mode(may be `SNR`, `EsNo`, `EbNo` in dB"
    esno::Float64 
    "Sampling period of the channel"
    tsample::Float64
    "Symbol duration if channel operates in waveform channel mode"
    tsymbol::Float64 
end 
AWGNChannel(esno=1) = AWGNChannel(esno, NaN, NaN) 

iswaveform(channel::AWGNChannel) = channel.tsample !== NaN && channel.tsymbol !== NaN 

(channel::AWGNChannel)(tx) = iswaveform(channel) ? wavecorrupt(channel, tx) : veccorrupt(channel, tx)

function veccorrupt(channel::AWGNChannel, tx)
    # `tx` is corrupted with complex additive white Gaussian noise with mean zero and variance `2N0`. The variance of
    # the noise determined by channel esno and signal enerygy per symbol 
    K = length(tx)          
    N = length(tx[1])       
    Es = sum(energy.(tx)) / K 
    σ = sqrt(Es / dbtoval(channel.esno)) 
    n = collect(eachrow(σ * randn(ComplexF64, K, N))) 
    tx + n
end

function wavecorrupt(channel::AWGNChannel, tx) 
    # `tx` is corrupted with complex additive white Gaussian noise with mean zero and variance `2N0`. The variance of
    # the noise determined by channel esno, signal enerygy per symbol and sampling period of the channel.  
    K = length(tx)
    l = length(tx[1])
    ts = channel.tsample
    fs  = 1 / ts 
    Es = sum(txi -> energy(txi, ts), tx) / K 
    σ = sqrt(Es * fs / dbtoval(channel.esno))
    n = collect(eachrow(σ * randn(ComplexF64, K, l)))
    tx + n
end
