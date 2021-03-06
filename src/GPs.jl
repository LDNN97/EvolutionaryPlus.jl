# Surrogate Model with Gaussian Processes
module GPs

using ..DE

using LinearAlgebra

export model_training, predict

function kernel_trick(x1::Float64, x2::Float64,
                      σ_f::Float64, l::Float64)
    re = σ_f^2 * exp((x1 - x2)^2 / -2)
end

function K(x::Array{Float64}, σ_f::Float64, l::Float64)
    le = length(x)
    re = Array{Float64}(undef, le, le)
    for i=1:1:le
        for j=1:1:le
            re[i, j] = kernel_trick(x[i], x[j], σ_f, l)
        end
    end
    re
end

function K(x1::Array{Float64}, x2::Float64, σ_f::Float64, l::Float64)
    le = length(x1)
    re = Array{Float64}(undef, le, 1)
    for i=1:1:le
        re[i, 1] = kernel_trick(x1[i], x2, σ_f, l)
    end
    re
end

function K(x::Float64, σ_f::Float64, l::Float64)
    kernel_trick(x, x, σ_f, l)
end

function marginal_likelihood(tr_x::Array{Float64}, tr_y::Array{Float64},
                             σ_f::Float64, l::Float64, σ_n::Float64)
    A = K(tr_x, σ_f, l) + σ_n^2 * UniformScaling(length(tr_x))
    n = length(tr_x)
    -(-1/2 * tr_y' * inv(A) * tr_y - 1/2 * log(det(A)) - n/2 * log(2 * pi))
end

function model_training(tr_x::Array{Float64}, tr_y::Array{Float64})
    f(pop::DE.Population) = begin
        for i in 1:size(pop.x, 1)
            pop.fit[i] = marginal_likelihood(tr_x, tr_y,
                            pop.x[i, 1], pop.x[i, 2], pop.x[i, 3])
        end
    end

    σ_f, l, σ_n= DE_evolution(f, 10, 3, 50)[1]
    A = K(tr_x, σ_f, l) + σ_n * UniformScaling(length(tr_x))
    while !isposdef(A)
        σ_f, l, σ_n= DE_evolution(f, 10, 3, 50)[1]
        A = K(tr_x, σ_f, l) + σ_n * UniformScaling(length(tr_x))
    end

    L = cholesky(A)
    α = L.U\(L.L\tr_y)
    return σ_f, l, L, α
end

function predict(σ_f::Float64, l::Float64, L::Cholesky, α::Array{Float64},
                 tr_x::Array{Float64}, pr_x::Float64)
    k_s = K(tr_x, pr_x, σ_f, l)
    k_ss = K(pr_x, σ_f, l)
    mean = k_s' ⋅ α
    v = L\k_s
    vari = k_ss - v' ⋅ v
    return mean, vari
end

end  # modue SuM
