# This file includes the simulation of a PSK modulation 

using DigitalCommunications

# Settings 
γb = 2 
k = 3
M = 2^k
l = 10 
nbits = k * l
σ = √(1 / (2 * ebno(γb)))

# Consruct communication system blocks 
gen = Generator(nbits)
modulator = Modulator(PSK(), M)
channel = AWGNChannel(0, σ)

# Run communciation system 
b = gen.bits 
s = b |> modulator 
r = s |> channel 

