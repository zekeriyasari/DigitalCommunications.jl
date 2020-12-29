# This file includes test set for modulator 

@testset "ModulatorTestset" begin

# Fields 
@test :scheme in fieldnames(BasebandModulator)
@test :Ep in fieldnames(BasebandModulator)

# Construction 
modulator = BasebandModulator(PSK(4), 10.)
modulator = BasebandModulator(ASK(4))
@test modulator.Ep == 1.

# Modulation 
M = 4
bits = [0, 0, 1, 1, 0, 1, 1, 0, 0, 1] 
coding = GrayCoding(M)
modulator = BasebandModulator(PSK(M))
tx = bits |> coding |> modulator
@test tx[1] ≈ [1, 0] / sqrt(2)
@test tx[2] ≈ [-1, 0] / sqrt(2)
@test tx[3] ≈ [0, 1] / sqrt(2)
@test tx[4] ≈ [0, -1] / sqrt(2)
@test tx[5] ≈ [0, 1] / sqrt(2)

end # testset 
