module SbmlInterface

using ModelingToolkit
export ModelingToolkit

ENV["PYTHON"] = Sys.which("python")
using PyCall

const libsbml = PyNULL()
function __init__()
    copy!(libsbml, pyimport("libsbml"))
end
# @pyimport libsbml

include("sbml2modelingtoolkit.jl")
# include("objectivefrompetab.jl")
# export sbml2modelingtoolkit

end
