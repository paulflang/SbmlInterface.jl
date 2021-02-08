using SbmlInterface
using Documenter

makedocs(;
    modules=[SbmlInterface],
    authors="Paul F. Lang",
    repo="https://github.com/paulflang/SbmlInterface.jl/blob/{commit}{path}#L{line}",
    sitename="SbmlInterface.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://paulflang.github.io/SbmlInterface.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/paulflang/SbmlInterface.jl",
)
