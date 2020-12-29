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
        BasebandModulator(PAM(M)), 
        BasebandModulator(ASK(M)), 
        BasebandModulator(PSK(M)), 
        BasebandModulator(QAM(M))
    ] 
    tx = gen.bits |> modulator 
    @show(tx)
end

