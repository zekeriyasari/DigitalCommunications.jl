# This file includes examples of symbol transmissions 

using DigitalCommunications 

# Settings 
k = 2 
M = 2^k
nsymbols = 10
nbits = nsymbols * k 

# Blocks 
gen = Generator(nbits) 
for modulator in [
        VectorModulator(PAM(M)), 
        VectorModulator(ASK(M)), 
        VectorModulator(PSK(M)), 
        VectorModulator(QAM(M))
    ] 
    tx = gen.bits |> modulator 
    @show(tx)
end

