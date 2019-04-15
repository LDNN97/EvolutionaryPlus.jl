using EvolutionaryPlus
using Test

@testset "EvolutionaryPlus.jl" begin
    # Write your own tests here.
    f(x) = sin(x)

    tr_x = Array(0:0.5:100)
    tr_y = f.(tr_x)

    σ_f, l, L, α = model_training(tr_x, tr_y)

    pr_x = Array(0:0.2:100)
    pr_y = Array{Float64}(undef, length(pr_x), 2)
    for i in 1:length(pr_x)
        pr_y[i, 1], pr_y[i, 2] = predict(σ_f, l, L, α, tr_x, pr_x[i])
    end

    @test abs(pr_y[1, 1] - tr_y[1]) < 1

end
