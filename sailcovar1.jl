
using JuMP, Clp


d = [40 60 75 25 36]                   # monthly demand for boats

m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:5] <= 40)       # boats produced with regular labor
@variable(m, y[1:5] >= 0)             # boats produced with overtime labor
@variable(m, h[1:6] >= 0)             # boats held in inventory
@constraint(m, h[2] == 15)            # initially inventory Q2 has 10+40-35 = 15 boots
@constraint(m, h[6] >= 10)            # min problem thus can use '>=' instead '=='
@constraint(m, flow[i in 2:5], h[i]+x[i]+y[i]==d[i]+h[i+1])     # Q2-Q5=>i in 2:5
@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(h))         # minimize costs

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
println("Inventory: ", Array{Int}(value.(h')))
