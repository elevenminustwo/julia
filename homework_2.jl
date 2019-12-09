using JuMP
using Cbc

m = Model(with_optimizer(Cbc.Optimizer, logLevel=0))

@variable(m, 0<=x[1:250]<=5000,Int)
@variable(m, y,Int)

@constraint(m, sum(x[i] for i in 1:250) <= 5000)
@constraint(m, flow[i in 1:249], x[i]>=x[i+1]+y+1)
@constraint(m, y>=0)
@constraint(m, y<=250)

@objective(m, Max,y)

status = JuMP.optimize!(m)
uniques = unique(round.(Int,Array{Float64}(value.(x'))))

d=[(i,count(x->x==i,round.(Int,Array{Float64}(value.(x'))))) for i in uniques]

println("Build ", round.(Int,Array{Float64}(value.(x'))))
println("Sum of x : ",sum(round.(Int,value.(x'))))
println("Unique elements of x : ", uniques)
println("Dictionary of unique elements :  ",d)
