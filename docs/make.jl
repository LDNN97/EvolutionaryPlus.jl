using Documenter, EvolutionaryPlus

makedocs(;
    modules=[EvolutionaryPlus],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "Manual" => Any[
            "manual/start.md",
            "manual/example.md",
        ],
        "Algorithm" => Any[
            "algorithm/DE.md",
            "algorithm/CMAES.md",
            "algorithm/GPs.md",
        ],
        "Library" => Any[
            "lib/public.md",
            "lib/internal.md",
        ],
        "contributing.md",
    ],
    repo="https://github.com/LDNN97/EvolutionaryPlus.jl/blob/{commit}{path}#L{line}",
    sitename="EvolutionaryPlus.jl",
    authors="LDNN97",
)

deploydocs(;
    repo="github.com/LDNN97/EvolutionaryPlus.jl",
)
