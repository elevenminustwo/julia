
using JuMP, Clp


d = [40 60 75 25]                   # monthly demand for boats

m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:5] <= 40)       # boats produced with regular labor
@variable(m, y[1:5] >= 0)             # boats produced with overtime labor
@variable(m, h[1:5] >= 0)             # boats held in inventory
@variable(m, p[1:4] >= 0)             # c+
@variable(m, n[1:4] >= 0)             # c-
@variable(m, combine[1:4])            # c
@constraint(m, h[1] == 10)            # initial inventory value
@constraint(m, h[5] >= 10)            # min problem thus '==' equals '>='

@constraint(m, x[1]+y[1]==50)         # 50 boats pre-made
@constraint(m, flow3[i in 1:4],x[i+1]+y[i+1]-(x[i]+y[i])==combine[i]) # Capture change in product period to period
@constraint(m, flow2[i in 1:4], p[i]-n[i]==combine[i]) # (c+) - (c-) = c

@constraint(m, flow[i in 1:4], h[i]+x[i+1]+y[i+1]==d[i]+h[i+1]) # x and y shifted so we should use i+1 instead

@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(h) + 400*sum(p)+500*sum(n)) # minimize costs

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
println("c+ ",Array{Int}(value.(p')))
println("c- ",Array{Int}(value.(n')))
