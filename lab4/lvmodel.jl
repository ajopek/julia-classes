using Gadfly
using DataFrames
using DifferentialEquations
using CSV

tspan = (0.0, 50.0) # Time span for solution  


# Lotka-Volterra model function
function lv(du, u, p, t) 
    du[1] = p[1] * u[1] - p[2] * u[1] * u[2]
    du[2] = p[4] * u[1] * u[2] - p[3] * u[2]
end   

function load_parameters(path :: String)
    parameters = CSV.read(path; header=true, delim = ',', types=fill(Float64, 6))
    return parameters
end    

function solve_and_generate_out(exp_id :: String, initialVals, p)
    
    # Create and solve the problem
    problem = ODEProblem(lv, initialVals, tspan, p)
    sol = solve(problem)

    # Create dataframe of problem 1 solution for predators and preys
    df1 = DataFrame(t=sol.t, x = map(x -> x[1], sol.u), y = map(x -> x[2], sol.u))
    df1[:exp_id] = exp_id

    CSV.write(exp_id * ".csv", df1)
end    

function solve_for_each(path :: String)
    params = load_parameters(path)
    id = 0
    for row in eachrow(params)
        p = [get(row[:A]), get(row[:B]), get(row[:C]), get(row[:D])]

        solve_and_generate_out("exp$id", [get(row[:initPrey]), get(row[:initPred])], p)

        id = id + 1
    end    
end    