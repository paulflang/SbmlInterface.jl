using SbmlSim
using Documenter

makedocs(;
    modules=[SbmlSim],
    authors="Paul F. Lang",
    repo="https://github.com/paulflang/SbmlSim.jl/blob/{commit}{path}#L{line}",
    sitename="SbmlSim.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://paulflang.github.io/SbmlSim.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/paulflang/SbmlSim.jl",
)
