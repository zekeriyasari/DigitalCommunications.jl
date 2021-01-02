# This file illustrates the calculation of power spectral density and 
# total average power of a sinusoidal signal. 

using FFTW 
using Plots 

# Construct the signal
f = 20
fs = 100 
l = 2^10
ts = 1 / fs 
t = (0 : l -1) * ts 
x = cos.(2π * f * t)

# Compute fft
xf = fft(x) * ts 
ff = 0 : fs / (l - 1) : fs 

# Compute power 
psd = abs.(xf).^2 / (l - 1) / ts 
Δf = fs / (l - 1) 
Pf = sum(psd) * Δf              # Average power calculated in time 
Pt = sum(abs.(x).^2) / (l - 1)  # Average power calculated in frequency
@show Pf, Pt

# Plots 
plt = plot(layout=1)
plot!(ff, psd, subplot=1)
xlabel!("Frequency [Hz]") 
ylabel!("Ψ(f)")
title!("Power Spectal Density")
display(plt)