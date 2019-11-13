
using JuMP, Clp


d = [0 40 60 75 25]                   # monthly demand for boats

m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:5] <= 40)       # boats produced with regular labor
@variable(m, y[1:5] >= 0)             # boats produced with overtime labor
@variable(m, hp[1:5] >= 0)             # boats held in inventory
@variable(m, hn[1:5] >= 0)
@variable(m, p[1:4] >= 0)
@variable(m, n[1:4] >= 0)
@variable(m, hcombine[1:5])
@variable(m, combine[1:4])
@constraint(m, hp[5] >= 10)
@constraint(m, hn[5] <= 0)

@constraint(m, x[1]+y[1]==50)
@constraint(m, hp[1]-hn[1]==10)

@constraint(m,flow3[i in 1:4],x[i+1]+y[i+1]-(x[i]+y[i])==combine[i])
@constraint(m, flow2[i in 1:4], p[i]-n[i]==combine[i])
@constraint(m, flow4[i in 1:5], hp[i]-hn[i]==hcombine[i])

@constraint(m, flow[i in 1:4], hcombine[i]+x[i+1]+y[i+1]==d[i+1]+hcombine[i+1])     # conservation of boats x[i+1]+y[i+1]-x[i]+y[i]==p[i+1]-n[i+1]

@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(hp) + 400*sum(p)+500*sum(n) + 100*sum(hn))         # minimize costs

optimize!(m)

if termination_status(m) == MOI.OPTIMAL
    optimal_solution = value.(x)
    optimal_objective = objective_value(m)
elseif termination_status(m) == MOI.TIME_LIMIT && has_values(m)
    suboptimal_solution = value.(x)
    suboptimal_objective = objective_value(m)
else
    error("The model was not solved correctly.")
end


println("Build ", Array{Int}(value.(x')), " using regular labor")
println("Build ", Array{Int}(value.(y')), " using overtime labor")
println("Inventory: ", Array{Int}(value.(hcombine')))
println("h+ ",Array{Int}(value.(hp')))
println("h- ",Array{Int}(value.(hn')))
println("c+ ",Array{Int}(value.(p')))
println("c- ",Array{Int}(value.(n')))
