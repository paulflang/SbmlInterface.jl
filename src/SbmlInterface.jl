module SbmlInterface

using ModelingToolkit
export ODESystem, ODEProblem
using OrdinaryDiffEq
export solve, FunctionMap, Euler, Heun, Ralston, Midpoint, RK4, ExplicitRK, OwrenZen3, OwrenZen4, OwrenZen5,
       BS3, BS5, RK46NL, DP5, Tsit5, DP8, Vern6, Vern7, Vern8, TanYam7, TsitPap8,
       Vern9, Feagin10, Feagin12, Feagin14, CompositeAlgorithm, Anas5, RKO65, FRK65, PFRK87, RKM

ENV["PYTHON"] = Sys.which("python")
#=using Pkg
Pkg.build("PyCall")=#
using PyCall

const libsbml = PyNULL()
function __init__()
    copy!(libsbml, pyimport("libsbml"))
end
# @pyimport libsbml

include("sbml2modelingtoolkit.jl")
# include("objectivefrompetab.jl")
# export sbml2modelingtoolkit
export simulatesbml
export sbml2odeproblem,sbml2odesystem
export getmodel,getodes,getparameters,getinitialconditions

end
