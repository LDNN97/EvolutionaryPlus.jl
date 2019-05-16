module DE

using Random

export DE_evolution

"""
population type defination for Differential Evolutionary Algorithm
"""
mutable struct Population
    x::Array{Float64, 2}
    fit::Array{Float64, 1}
end


"""
    sample(pop::Population)

sample a new population with mutation and recombination in DE
"""
function sample(pop::Population)
    new_pop = Population(zeros(size(pop.x)), zeros(size(pop.fit)))
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


"""
    selection(pop::Population, new_pop::Population)

choose a better individual between 'parent' and 'child'
"""
function selection(pop::Population, new_pop::Population)
    for i in 1:size(pop.x, 1)
        if new_pop.fit[i] <= pop.fit[i]
            pop.x[i, :] = new_pop.x[i, :]
            pop.fit[i] = new_pop.fit[i]
        end
    end
end

"""
    pop_opti(pop::Population)

return the best individual from a population
"""
function pop_opti(pop::Population)
    index = argmin(pop.fit)
    return pop.x[index, :], pop.fit[index]
end


"""
    evolution(eval, pops::Int64, dim::Int64, gen::Int64)

Optimization for function 'eval' uses algorithm 'ea'.

# Argument

- 'pops': population size
- 'dim': dimension of the problem
- 'gen': max generation number
"""
function DE_evolution(f, pops::Int64, dim::Int64, gen::Int64)
    pop = Population(rand(pops, dim), zeros(pops))
    f(pop)
    println("start optimization:")
    println("gen: ", 0, " fitness: ", pop_opti(pop)[2])
    for i in 1:gen
        new_pop = sample(pop)
        f(new_pop)
        selection(pop, new_pop)
        println("gen: ", i, " fitness: ", pop_opti(pop)[2])
    end
    return pop_opti(pop)[1], pop_opti(pop)[2]
end

end  # module DE
