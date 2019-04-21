module EvolutionaryPlus

include("EAfO.jl")
using .EAfO
export evolution

include("SuMwGPs.jl")
using .SuMwGPs
export model_training, predict

end # module
