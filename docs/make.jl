using Documenter, EvolutionaryPlus

makedocs(;
    modules=[EvolutionaryPlus],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/LDNN97/EvolutionaryPlus.jl/blob/{commit}{path}#L{line}",
    sitename="EvolutionaryPlus.jl",
    authors="LDNN97",
    assets=[],
)

deploydocs(;
    repo="github.com/LDNN97/EvolutionaryPlus.jl",
)
