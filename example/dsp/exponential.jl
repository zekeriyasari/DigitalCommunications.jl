# This file illustrates the calculation of energy spectral density and 
# total energy of a complex exponential pulse. 

using FFTW 
using Plots 

# Construct the signal
f = 20
fs = 100 
l = 2^10
ts = 1 / fs 
t = (0 : l -1) * ts 
x = exp.(1im * 2π * f * t)

# Compute fft
xf = fft(x) * ts 
ff = 0 : fs / (l - 1) : fs 

# Compute energy 
esd = abs.(xf).^2
Δf = fs / (l - 1) 
Ef = sum(esd) * Δf              # Energy calculated in time 
Et = sum(abs.(x).^2) * ts       # Energy calculated in frequency
@show Ef, Et

# Plots 
plt = plot(layout=1)
plot!(ff, esd, subplot=1)
xlabel!("Frequency [Hz]") 
ylabel!("Ψ(f)")
title!("Energy Spectal Density")
display(plt)