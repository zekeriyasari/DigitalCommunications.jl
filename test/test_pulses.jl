# This file includes the testset for modulation pulses 

@testset "PulseTestset" begin
    # Fields 
    for type in [RectangularPulse, RaisedCosinePulse]
        @test :amplitude in fieldnames(type) 
        @test :duration in fieldnames(type) 
    end 

    # Defaults
    pulse = RectangularPulse() 
    @test pulse.amplitude ≈ 1. 
    @test pulse.duration  ≈ 1. 
    pulse = RaisedCosinePulse() 
    @test pulse.amplitude ≈ 1. 
    @test pulse.duration  ≈ 1. 

    # Energy 
    pulse = RectangularPulse(2., 4.) 
    @test energy(pulse) ≈ 16. 
    pulse = RaisedCosinePulse(2., 4.) 
    @test energy(pulse) ≈ 4. * 3 / 
    
    # Waveforms 
    pulse = RectangularPulse(4., 1.) 
    @test pulse(-1) ≈ 0.
    @test pulse(2.) ≈ 0.
    @test pulse(1/2) ≈ pulse.amplitude

    pulse = RaisedCosinePulse(4., 1.) 
    @test pulse(-1.) ≈ 0.
    @test pulse(1/2) ≈ pulse.amplitude / 2 * (1 - cos(2π / pulse.duration * 1/2))
    @test pulse(2.) ≈ 0.
end # Test set. 