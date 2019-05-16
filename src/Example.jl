using EvolutionaryPlus

## Evolutionary Algorithm
println("=====Evolutionary Algorithm=====")
function f1(pop::DE.Population)
    for i in 1:size(pop.x, 1)
        pop.fit[i] = sum(pop.x[i, j]^2 for j in 1:size(pop.x, 2))
    end
end

DE.DE_evolution(f1, 50, 50, 1000)


## Covariance Matrix Adaptation Evolution Strategy
println("=====Covariance Matrix Adaptation Evolution Strategy=====")
function f2(p::CMA_ES.Population)
    for i in 1:size(p.x, 1)
        p.fit[i] = sum((-1 + 2 * p.x[i, j])^2 for j in 1:size(p.x, 2))
    end
end


CMA_ES.CMAES_evolution(f2, 50, 1000)

## Surrogate Model using Gaussian Processes
println("=====Surrogate Model using Gaussian Processes=====")
f(x) = sin(x)

tr_x = Array(0:0.5:10)
tr_y = f.(tr_x)

σ_f, l, L, α = GPs.model_training(tr_x, tr_y)

pr_x = Array(0:0.2:10)
pr_y = Array{Float64}(undef, length(pr_x), 2)
for i in 1:length(pr_x)
    pr_y[i, 1], pr_y[i, 2] = GPs.predict(σ_f, l, L, α, tr_x, pr_x[i])
end
te_y = f.(pr_x)

RMSE = sum((te_y[i] - pr_y[i, 1])^2 for i in length(te_y))^(1/2)

println("RMSE: ", RMSE)
