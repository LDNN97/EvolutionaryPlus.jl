# Evolutionary Algorithm for optimization
module EAfO

# EAfO Abstract Type
abstract type EAfOAT end

abstract type DE <: EAfOAT end
abstract type CMAES <: EAfOAT end
abstract type MAES <: EAfOAT end
abstract type LMMAES <: EAfOAT end

export EAFO, DE, CMAES, MAES, LMMAES
export POP, evolution

using Random

mutable struct POP <: DE
    x::Array{Float64, 2}
    fit::Array{Float64, 1}
end

function evaluation(pop::EAfOAT)
    for i in 1:size(pop.x, 1)
        pop.fit[i] = sum(pop.x[i, j]^2 for j in 1:size(pop.x, 2))
    end
end

function sample(pop::DE)
    new_pop = POP(zeros(size(pop.x)), zeros(size(pop.fit)))
    cr, f, num, len = rand(), rand(), size(pop.x, 1), size(pop.x, 2)
    for i in 1:num
        ind = shuffle(Vector(1:num))[1:3]
        j = rand(1:len)
        for k in 1:len
            if rand() < cr || k == j
                new_pop.x[i, k] = pop.x[ind[1], k] +
                    f * (pop.x[ind[2], k] - pop.x[ind[3], k])
            else
                new_pop.x[i, k] = pop.x[i, k]
            end
        end
    end
    return new_pop
end

function selection(pop::DE, new_pop::DE)
    for i in 1:size(pop.x, 1)
        if new_pop.fit[i] <= pop.fit[i]
            pop.x[i, :] = new_pop.x[i, :]
            pop.fit[i] = new_pop.fit[i]
        end
    end
end

function pop_opti(pop::DE)
    index = argmin(pop.fit)
    return pop.x[index, :], pop.fit[index]
end

function evolution(gen::Int64, pops::Int64, dim::Int64, eval)
    pop = POP(rand(pops, dim), zeros(pops))
    eval(pop)
    println("start optimization:")
    println("gen: ", 0, " fitness: ", pop_opti(pop)[2])
    for i in 1:gen
        new_pop = sample(pop)
        eval(new_pop)
        selection(pop, new_pop)
        println("gen: ", i, " fitness: ", pop_opti(pop)[2])
    end
    return pop_opti(pop)[1]
end

# evolution(100, 50, 50, evaluation)

end  # modue EAFO
