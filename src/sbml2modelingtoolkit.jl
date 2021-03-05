# Several functions in this file are adapted from Frank T. Bergman
# Date: 2019
# Availability: https://groups.google.com/forum/#!topic/sbml-discuss/inS4Lzp3Ri8 or
# https://www.dropbox.com/s/2bfpiausejp0gd0/convert_reactions.py?dl=0
###################################################################################

@ModelingToolkit.parameters t
_Differential = ModelingToolkit.Differential(t)
export _Differential, t

"""
    simulatesbml(sbmlfile::String,tspan;saveat::Real=1.,jac::Bool=true,
                 solver=OrdinaryDiffEq.Tsit5())

Simulate model from SBML file and return an ODESolution.

# Arguments
- `sbmlfile::String`: path to SBML file.
- `tspan`: The solution u(t) will be computed for tspan[1] ≤ t ≤ tspan[2].
- `saveat::Real=1.`: time intervals of u(t) output.
- `jac::Bool=true`: Jacobian matrix.
- `solver=OrdinaryDiffEq.Tsit5()`: Integration algorithm.

# Example
```julia-repl
julia> sol = simulatesbml("mymodel.sbml",(0.0,1.0))
retcode: Success
Interpolation: 1st order linear
t: 2-element Array{Float64,1}:
 0.0
 1.0
u: 2-element Array{Array{Float64,1},1}:
 [0.0, 1.0]
 [0.4, 0.6]
```
"""
function simulatesbml(sbmlfile::String,tspan;saveat::Real=1.,jac::Bool=true,
                      solver=OrdinaryDiffEq.Tsit5())
    prob = sbml2odeproblem(sbmlfile,tspan,jac=jac)
    OrdinaryDiffEq.solve(prob,solver,saveat=saveat)
end

"""
    sbml2odeproblem(sbmlfile::String,tspan;jac::Bool=true)

Convert model from SBML file to an `ODEProblem` and return it.

# Arguments
- `sbmlfile::String`: path to SBML file.
- `tspan`: The solution u(t) will be computed for tspan[1] ≤ t ≤ tspan[2].
- `jac::Bool=true`: Jacobian matrix.

# Example
```julia-repl
julia> prob = sbml2odeproblem(SBML_FILE,(0.0,10.0))
ODEProblem with uType Array{Float64,1} and tType Float64. In-place: true
timespan: (0.0, 10.0)
u0: [0.0, 1.0]
```
"""
function sbml2odeproblem(sbmlfile::String,tspan;jac::Bool=true)
    model = SbmlInterface.getmodel(sbmlfile)
    p = getparameters(model)
    u0 = getinitialconditions(model)
    sys= sbml2odesystem(sbmlfile)
    ModelingToolkit.ODEProblem(sys, Pair[], tspan)
end

"""
    sbml2odesystem(sbmlfile::String; kwargs...)

Given an `sbmlfile` return an `ODESystem` with `default_u0` and `default_p` set.

# Example
```julia-repl
julia> sys = sbml2odesystem(SBML_FILE)
Model ##ODESystem#270 with 2 equations
States (2):
  B(t) [defaults to 0.0]
  A(t) [defaults to 1.0]
Parameters (3):
  k2 [defaults to 0.6]
  compartment [defaults to 1.0]
  k1 [defaults to 0.8]
```
"""
function sbml2odesystem(sbmlfile::String; kwargs...)
    if !isfile(sbmlfile)
        throw(DomainError("`sbmlfile` is not a file"))
    elseif !(splitext(sbmlfile)[2] in (".xml", ".sbml"))
        throw(DomainError("`sbmlfile` must have `.xml` or `.sbml` ending"))
    end
    model = getmodel(sbmlfile)
    p = getparameters(model)
    u0 = getinitialconditions(model)
    rxs = getreactions(model)
    rs  = ModelingToolkit.ReactionSystem(rxs, t, [item.first for item in u0], [item.first for item in p])
    odesys = convert(ModelingToolkit.ODESystem, rs)
    eqs = odesys.eqs
    sys = ModelingToolkit.ODESystem(eqs; default_p=p, default_u0=u0, kwargs...)
    sys
end

"""
    getmodel(sbmlfile::String)

Given an `sbmlfile` return a PyObject (libsbml.Model).

# Example
```julia-repl
julia> model = getmodel(SBML_FILE)
PyObject <Model conversion_reaction_0 "Conversion Reaction 0">
```
"""
function getmodel(sbmlfile::String)
    doc = libsbml.readSBMLFromFile(sbmlfile)
    if doc.getNumErrors(libsbml.LIBSBML_SEV_FATAL) == 1
            @warn("Encountered serious errors while reading file")
            @error(doc.getErrorLog().toString())
    end

    # clear errors
    doc.getErrorLog().clearLog()

    # perform conversions
    props = libsbml.ConversionProperties()
    props.addOption("promoteLocalParameters", true)

    if doc.convert(props) != libsbml.LIBSBML_OPERATION_SUCCESS
        @warn("The document could not be converted")
        @warn(doc.getErrorLog().toString())
    end

    props = libsbml.ConversionProperties()
    props.addOption("expandFunctionDefinitions", true)  # Todo: ask PEtab developers set this to `True` when creating `petab.problem.Problem()`

    if doc.convert(props) != libsbml.LIBSBML_OPERATION_SUCCESS
        @warn("The document could not be converted")
        @warn(doc.getErrorLog().toString())
    end

    mod = doc.getModel()
end

"""
    getreactions(model)::Array

Create array of Reactions from a libsbml model.

# Example
```julia-repl
julia> rxs = getreactions(model)
2-element Array{ModelingToolkit.Reaction,1}:
 ModelingToolkit.Reaction{Any,Float64}(compartment*k1*A(t), SymbolicUtils.Term{Real}[A(t)],
                                       SymbolicUtils.Term{Real}[B(t)], [1.0], [1.0],
                                       Pair{Any,Float64}[B(t) => 1.0, A(t) => -1.0], true)
 ModelingToolkit.Reaction{Any,Float64}(compartment*k2*B(t), SymbolicUtils.Term{Real}[B(t)],
                                       SymbolicUtils.Term{Real}[A(t)], [1.0], [1.0],
                                       Pair{Any,Float64}[B(t) => -1.0, A(t) => 1.0], true)
```
"""
function getreactions(model)::Array
    assignments = []
    for a in model.getListOfRules()
        if (a.getMath().getName() == "piecewise") # || (a.getMath().getName() == nothing)
            @error("Assignment rules are not implemented.")
        end
        push!(assignments, a.getId() => a.getMath().getName())
    end

    getparameters(model)
    getinitialconditions(model)

    rxs = ModelingToolkit.Reaction[]
    # reactions = Dict()  # Dict of reaction => kinetic formula
    for i in 0:model.getNumReactions()-1
        reaction = model.getReaction(i)
        kineticlaw = reaction.getKineticLaw()
        kineticformula = kineticlaw.getFormula()
        kineticformula = eval(Meta.parse(replace(kineticformula, "pow"=>"^")))
        substrates = [eval(Meta.parse(substrate.getSpecies())) for substrate in reaction.getListOfReactants()]
        substoich = [substrate.getStoichiometry() for substrate in reaction.getListOfReactants()]
        products = [eval(Meta.parse(product.getSpecies())) for product in reaction.getListOfProducts()]
        prodstoich = [product.getStoichiometry() for product in reaction.getListOfProducts()]
        mtkreaction = ModelingToolkit.Reaction(kineticformula, substrates, products, substoich, prodstoich, only_use_rate=true)
        push!(rxs, mtkreaction)
    end
    rxs
end

"""
    getparameters(model)

Create array of parameters from a libsbml Model.

# Example
```julia-repl
julia> pars = getparameters(model)
3-element Array{Pair{Num,Float64},1}:
          k1 => 0.8
          k2 => 0.6
 compartment => 1.0
```
"""
function getparameters(model)
    parameters = Pair{ModelingToolkit.Num,Float64}[]
    for i in 0:model.getNumParameters()-1
        par = model.getParameter(i)
        parname = par.getId()
        parval = par.getValue()
        eval(Meta.parse("@ModelingToolkit.parameters $parname"))
        eval(Meta.parse("export $parname"))
        push!(parameters, eval(Meta.parse("$parname => $parval")))
    end
    for i in 0:model.getNumCompartments()-1
        comp = model.getCompartment(i)
        compname = comp.getId()
        compval = comp.getSize()
        eval(Meta.parse("@ModelingToolkit.parameters $compname"))
        eval(Meta.parse("export $compname"))
        push!(parameters, eval(Meta.parse("$compname => $compval")))
    end
    parameters
end

"""
    getinitialconditions(model)

Create array of initial conditions from a libsbml Model.

# Example
```julia-repl
julia> u0 = getinitialconditions(model)
2-element Array{Pair{Num,Float64},1}:
 A(t) => 1.0
 B(t) => 0.0
```
"""
function getinitialconditions(model)
    eval(Meta.parse("@ModelingToolkit.parameters t"))

    initialassignments = Dict()
    for var in model.getListOfInitialAssignments()
        varname = var.getId()
        varval = var.getMath().getName()
        if varval isa String
            varval = model.getParameter(varval).getValue()
        end
        initialassignments[varname] = varval
    end

    initialconditions = Pair{ModelingToolkit.Num,Float64}[]
    for i in 0:model.getNumSpecies()-1
        var = model.getSpecies(i)
        varname = var.getId()
        if var.isSetInitialConcentration()
            varval = var.getInitialConcentration()
        elseif var.isSetInitialAmount()
            varval = var.getInitialAmount()  
        else
            varval = initialassignments[varname]
        end
        eval(Meta.parse("@ModelingToolkit.variables $varname(t)"))
        eval(Meta.parse("export $varname"))
        push!(initialconditions, eval(Meta.parse("$varname => $varval")))
    end
    initialconditions
end
