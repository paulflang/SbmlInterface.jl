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
* create a Python virtual environment and activate it:
  ```
  $ python -m venv venv
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
* activate the Julia virtual environment:
  ```julia
  julia> ]
  (v1.5) pkg> activate .
  ```
* install PyCall.jl into the Julia virtual environment:
  ```julia
  (SbmlInterface) pkg> add PyCall
  (SbmlInterface) pkg> build PyCall
  ```
* and add SbmlInterface.jl:
  ```julia
  (SbmlInterface) pkg> dev .
  ```

## Tutorial
SBML models can be simulated with the following 6 steps:
  ```julia
    julia> using SbmlInterface

    julia> model = getmodel('mymodel.sbml')
    julia> p = getparameters(model)
    julia> u0 = getinitialconditions(model)
    julia> eqs = getodes(model)
    julia> sys = ODESystem(eqs)
    julia> prob = ODEProblem(sys,u0,(0.0,10.0),p)
    julia> sol = solve(prob,Tsit5())
  ```
If you want to create an `ODESystem`, `ODEProblem` or solution `Array` directly from an SBML file use `sbml2odesystem('mymodel.sbml')`, `sbml2odeproblem('mymodel.sbml',(tstart,tend))` and `simulatesbml('mymodel.sbml',(tstart,tend))`, respectively.


## License
The package is released under the [MIT license](https://github.com/paulflang/SbmlInterface.jl/blob/main/LICENSE).


## Development team
This package was developed by [Paul F. Lang](https://www.linkedin.com/in/paul-lang-7b54a81a3/) at the University of Oxford, UK.


## Questions and comments
Please contact [Paul F. Lang](mailto:paul.lang@wolfson.ox.ac.uk) with any questions or comments.