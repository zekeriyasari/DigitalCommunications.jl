using DigitalCommunications
using Documenter

makedocs(;
    modules=[DigitalCommunications],
    authors="Zekeriya Sarı",
    repo="https://github.com/zekeriyasari/DigitalCommunications.jl/blob/{commit}{path}#L{line}",
    sitename="DigitalCommunications.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://zekeriyasari.github.io/DigitalCommunications.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/zekeriyasari/DigitalCommunications.jl",
)
