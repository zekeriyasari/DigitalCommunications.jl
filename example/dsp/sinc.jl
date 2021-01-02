using Plots; plotlyjs()  
using FFTW 

# Construct a signal 
f = 1
fs = 5
ts = 1 / fs 
l = 2^10 + 1
t = (-(l - 1) ÷ 2 : (l - 1) ÷ 2) * ts 
x = sinc.(f * t) 

# Construct the frequency spectrum 
xf = fft(x)
ff = (0 : 1 / (l - 1) : 1) * fs 

# Signal energy 
Δt = ts 
Δf = fs / (l - 1)
Et = sum(abs.(x).^2) * Δt 
Ef = sum(abs.(xf).^2) * Δf / (fs^2)
@show Et, Ef

# Plots 
plt = plot(layout=2) 
plot!(t, x, subplot=1) 
plot!(ff, abs.(xf), subplot=2) 
display(plt) 
