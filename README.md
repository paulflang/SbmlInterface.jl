# SbmlInterface

<!---[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://paulflang.github.io/SbmlInterface.jl/stable)--->
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://paulflang.github.io/SbmlInterface.jl/dev)
[![Build Status](https://github.com/paulflang/SbmlInterface.jl/workflows/CI/badge.svg)](https://github.com/paulflang/SbmlInterface.jl/actions)
[![Coverage](https://codecov.io/gh/paulflang/SbmlInterface.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/paulflang/SbmlInterface.jl)

SbmlInterface.jl is a lightweight tool to import models specified in the Systems Biology Markup Language (SBML) into Julia. More specifically, SbmlInterface.jl uses the Python libsbml library to extract ordinary differential equations, initial conditions and parameter values from SBML files. Events and constraints and several other SBML components are not yet supported. There are several ways to specify the same model in SBML and SbmlInterface. Please help us improving SbmlInterface.jl by creating a GitHub issue if you experience errors when converting your SBML model to Julia.

## Installation
SbmlInterface.jl is not yet available on the Julia package managing system. To install SbmlInterface please first clone this repository:
  ```
  $ git clone https://github.com/paulflang/SbmlInterface.jl.git
  ```
As SbmlInterface.jl relies on the Python libsbml library, please make sure your version of Julia can communicate with a Python environment were libsbml is installed. Please follow the [PyCall installation instructions](https://github.com/JuliaPy/PyCall.jl) or:
* create a Python virtual environment in the SbmlInterface.jl directory and activate it:
  ```
  $ cd SbmlInterface.jl/
  $ python3 -m venv venv
  $ source venv/bin/activate
  ```
* install python-libsbml to the python environment:
  ```
  $ pip install python-libsbml
  ```
* start the Julia REPL:
  ```
  $ julia
  ```
* and activate the Julia virtual environment:
  ```julia
  julia> ]
  (v1.5) pkg> activate .
  ```
When `using SbmlInterface` Julia will be able to communicate with the python virtual environment where you have installed libsbml.


## Tutorial
SBML models can be simulated with the following steps:
  ```julia
    using SbmlInterface

    model = getmodel("mymodel.sbml")
    p = getparameters(model)
    u0 = getinitialconditions(model)
    rxs = getreactions(model)
    rs  = ReactionSystem(rxs, t, [item.first for item in u0], [item.first for item in p])
    odesys = convert(ODESystem, rs)
    prob = ODEProblem(odesys,u0,(0.0,10.0),p)
    sol = solve(prob,Tsit5())
  ```
If you want to create an `ODESystem`, `ODEProblem` or solution `Array` directly from an SBML file use `sbml2odesystem("mymodel.sbml")`, `sbml2odeproblem("mymodel.sbml",(tstart,tend))` and `simulatesbml("mymodel.sbml",(tstart,tend))`, respectively.


## License
The package is released under the [MIT license](https://github.com/paulflang/SbmlInterface.jl/blob/main/LICENSE).


## Development team
This package was developed by [Paul F. Lang](https://www.linkedin.com/in/paul-lang-7b54a81a3/) at the University of Oxford, UK and [Anand Jain](https://github.com/anandijain) at the University of Chicago, USA.


## Questions and comments
Please contact [Paul F. Lang](mailto:paul.lang@wolfson.ox.ac.uk) or [Anand Jain](mailto:anandj@uchicago.edu) with any questions or comments.
