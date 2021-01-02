# This file illustrates calculation of energy spectral density and total enery of a rectangular pulse. 

using FFTW
using Plots; plotlyjs() 

# Define pulse 
T = 1 / 10 
p(t) = 0 ≤ t ≤ T ? 1 : 0 

# Construct the signal
fs = 1000
ts = 1 / fs 
l = 2^10
t = (0 : l - 1) * ts
x = p.(t)

# Compute fft 
xf = fft(x)
psd = abs.(xf).^2
ff = (0 : 1 / (l - 1) : 1) * fs

# Compute energies 
Δf = fs / (l - 1)
Δt = ts
Et = sum(abs.(x).^2) * Δt
Ef = sum(psd) * Δf / (fs^2)
@show Et, Ef

# Plots 
plt = plot(layout=2) 
plot!(t[1:500], x[1:500], subplot=1)
plot!(ff, psd, subplot=2)
display(plt)
