# This file illustrates calculation of power spectral density and total average power of an white Gaussian noise. 

using FFTW 
using Plots 
using DSP 
using Statistics

# Construct noise signal 
N0 = 50.
fs = 100
ts = 1 / fs 
ln = 2^10
tn = (0 : ln - 1) * ts 
n = sqrt(N0 / 2 * fs) * randn(ln) 

# Compute autocorrelation function. 
Rn = xcorr(n, n) / (ln - 1)
τ = (-ln + 1 : ln - 1) * ts 
lr = length(Rn) 

# Fourier tranform of autocorrelation function
xrf = fft(Rn) * ts
psdr = abs.(xrf) 
ffr = (0 : 1 / (lr - 1) : 1) * fs
Δfr = fs / (lr - 1) 
Pfr = sum(psdr[1 : end - 1]) * Δfr

# Compute power spectral density 
xfn = fft(n) * ts
psdn = abs.(xfn).^2 / (ln - 1) / ts 
ffn = (0 : 1 / (ln - 1) : 1) * fs

# Compute powers 
Pt = sum(n[1 : ln - 1].^2) / (ln - 1)
Δf = fs / (ln - 1)
Pfn = sum(psdn[1 : end - 1]) * Δf

# Compare all the powers and variance
@show  Pfr, Pt, Pfn, var(n)

# Plots 
plt = plot(layout=4)
plot!(tn, n, subplot=1)
plot!(τ, Rn, subplot=2)
plot!(ffn, psdn, subplot=3)
plot!(ffr, psdr, subplot=4)
display(plt) 