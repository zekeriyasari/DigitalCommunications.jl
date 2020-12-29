# This file includes the testset for modulation pulses 

@testset "PulseTestset" begin
    # Fields 
    for type in [Rectangular, RaisedCosine]
        @test :amplitude in fieldnames(type) 
        @test :duration in fieldnames(type) 
    end 

    # Defaults
    pulse = Rectangular() 
    @test pulse.amplitude ≈ 1. 
    @test pulse.duration  ≈ 1. 
    pulse = RaisedCosine() 
    @test pulse.amplitude ≈ 1. 
    @test pulse.duration  ≈ 1. 

    # Energy 
    pulse = Rectangular(2., 4.) 
    @test energy(pulse) ≈ 16. 
    pulse = RaisedCosine(2., 4.) 
    @test energy(pulse) ≈ 4. * 3 / 
    
    # Waveforms 
    pulse = Rectangular(4., 1.) 
    @test pulse(-1) ≈ 0.
    @test pulse(2.) ≈ 0.
    @test pulse(1/2) ≈ pulse.amplitude

    pulse = RaisedCosine(4., 1.) 
    @test pulse(-1.) ≈ 0.
    @test pulse(1/2) ≈ pulse.amplitude / 2 * (1 - cos(2π / pulse.duration * 1/2))
    @test pulse(2.) ≈ 0.
end # Test set. 