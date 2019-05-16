module CMA_ES

using LinearAlgebra

export CMAES_evolution

mutable struct CMAES
    n::Int64
    λ::Int64
    μ::Int64

    x̄::Array{Float64, 1}

    σ::Float64
    ω::Array{Float64, 1}
    μω::Float64
    cσ::Float64
    cc::Float64
    c1::Float64
    cμ::Float64

    pσ::Array{Float64, 1}
    pc::Array{Float64, 1}

    C::Array{Float64, 2}

    CMAES(dim) = begin
        n = dim
        λ = 4 + trunc(Int, 3 * log(n))
        μ = trunc(Int, λ / 2)

        x̄ = rand(n)

        σ = 1
        ω = (-log.(1:μ) .+ log.(μ+0.5)) ./ (sum(-log.(1:μ) .+ log.(μ+0.5)))
        μω = 1 / sum(ω.^2)
        cσ = (μω + 2) / (n+μω+5)
        cc = 4/(n+4)
        c1 = 2/((n+1.3)^2+μω)
        cμ = min(1-c1, 2*(μω-2+1/μω)/((n+2)^2+μω))
        pσ = zeros(n)
        pc = zeros(n)
        C = Array{Float64, 2}(I, (n,n))
        new(n, λ, μ, x̄, σ, ω, μω, cσ, cc, c1, cμ, pσ, pc, C)
    end
end

mutable struct Population
    z::Array{Float64, 2}
    d::Array{Float64, 2}
    x::Array{Float64, 2}
    fit::Array{Float64, 1}
    Population(num, dim) = begin
        z = zeros(num, dim)
        d = zeros(num, dim)
        x = zeros(num, dim)
        fit = zeros(num)
        new(z, d, x, fit)
    end
end

function sample(es::CMAES)
    D, B = eigen(es.C)
    D, B = real(D), real(B)
    M = B * sqrt.(D)
    np = Population(es.λ, es.n)
    for i = 1:es.λ
        np.z[i, :] = randn(es.n)
        np.d[i, :] = M .* np.z[i, :]
        np.x[i, :] = es.x̄ + es.σ * np.d[i, :]
    end
    np
end

function selection(es::CMAES, np::Population, f)
    f(np)
    argx = sortperm(np.fit)
    argx[1:es.μ]
end

function update(es::CMAES, np::Population, argx)
    # update mean value
    es.x̄ += vec(es.σ .* sum(es.ω .* np.d[argx, :], dims=1))

    # update evolution path
    zz = vec(sum(es.ω .* np.z[argx, :], dims=1))
    c = sqrt(es.cσ * (2 - es.cσ) * es.μω)
    es.pσ -= es.cσ .* es.pσ
    es.pσ += c * zz

    dd = vec(sum(es.ω .* np.d[argx, :], dims=1))
    c = sqrt(es.cc * (2 - es.cc) * es.μω)
    es.pc -= es.cc * es.pc
    es.pc += c * dd

    es.C = Array{Float64, 2}(I, (es.n,es.n))
    # update Covariance matrix
    es.C = (1 - es.c1 - es.cμ) * es.C + es.c1 * es.pc * es.pc'
    part3 = zeros(es.n, es.n)
    for i in 1:es.μ
        es.C += es.cμ * es.ω[i] * np.d[argx[i], :] * np.d[argx[i], :]'
    end

    # update step size
    es.σ *= exp(es.cσ / 2 * (sum(es.pσ .^ 2) / es.n - 1))
end

function CMAES_evolution(f, dim::Int64, gen_max::Int64)
    es = CMAES(dim)
    opti_x = zeros(es.n)
    opti_f = 1e10
    for i in 1:gen_max
        np = sample(es)
        argx = selection(es, np, f)

        if opti_f > np.fit[argx[1]]
            opti_x, opti_f = np.x[argx[1]], np.fit[argx[1]]
        end
        println("gen: ", i, " fitness: ", opti_f)

        update(es, np, argx)
    end
    opti_x, opti_f
end

end  # modue EAFO
