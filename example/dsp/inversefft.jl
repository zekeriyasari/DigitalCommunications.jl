# This file illustrates the recovery of a real signal from its frequency domain. 

using Plots 
using FFTW

# Define Fourier transform 
fs = 100 
ts = 1 / 100 
l = 2^10
fv = 0 : fs / (l - 1) : fs
xv = sinc.(fv)
ff = 0 : fs / (2l - 1) : fs
xf = [xv; reverse(xv)]  

# Define inverse Fourier transform 
x = ifft(xf) * fs
t = (0 : 2l - 1) * ts 
 
# Plot the results
plt = plot(layout=2) 
plot!(ff, abs.(xf), subplot=1)
xlabel!("f [Hz]", subplot=1)
ylabel!("|X(f)|", subplot=1)
plot!(t, abs.(x), subplot=2)
xlabel!("t [s]", subplot=2)
ylabel!("x(t)", subplot=2)
display(plt) 
