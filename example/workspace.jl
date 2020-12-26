# Workspace file ... 


T =  1 
ts = 0.001 
t = 0 : ts : T 
g = 1 .- cos.(2π * t)
Eg = sum(g.^2) * ts 
plot(t, g, ylims=(0, 2))
