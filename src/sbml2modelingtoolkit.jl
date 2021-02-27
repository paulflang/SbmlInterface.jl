# Several functions in this file are adapted from Frank T. Bergman
# Date: 2019
# Availability: https://groups.google.com/forum/#!topic/sbml-discuss/inS4Lzp3Ri8 or
# https://www.dropbox.com/s/2bfpiausejp0gd0/convert_reactions.py?dl=0
###################################################################################

@ModelingToolkit.parameters t
_Differential = ModelingToolkit.Differential(t)
export _Differential

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
    sys,u0,p = sbml2odesystem(sbmlfile)
    ModelingToolkit.ODEProblem(sys,u0,tspan,p)
end

"""
    sbml2odesystem(sbmlfile::String)

Given an `sbmlfile` return a tuple of `ODESystem`, `u0` and `p`.

# Example
```julia-repl
julia> sys,u0,p = sbml2odesystem(SBML_FILE)
(Model ##ODESystem#268 with 2 equations
States (2):
  B(t)
  A(t)
Parameters (3):
  k1
  k2
  compartment,
Pair{Num,Float64}[A(t) => 1.0, B(t) => 0.0],
Pair{Num,Float64}[k1 => 0.8, k2 => 0.6, compartment => 1.0])
```
"""
function sbml2odesystem(sbmlfile::String)
    if !isfile(sbmlfile)
        throw(DomainError("`sbmlfile` is not a file"))
    elseif !(splitext(sbmlfile)[2] in (".xml", ".sbml"))
        throw(DomainError("`sbmlfile` must have `.xml` or `.sbml` ending"))
    end
    model = getmodel(sbmlfile)
    p = getparameters(model)
    u0 = getinitialconditions(model)
    eqs = getodes(model)
    sys = ModelingToolkit.ODESystem(eqs)
    sys,u0,p
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
    getodes(model)::Array

Create array of ODEs from a libsbml Model.

# Example
```julia-repl
julia> model = getodes(SBML_FILE)
2-element Array{Equation,1}:
 Differential(t)(B(t)) ~ compartment*k1*A(t) - (compartment*k2*(B(t)))
 Differential(t)(A(t)) ~ compartment*k2*B(t) - (compartment*k1*(A(t)))
```
"""
function getodes(model)::Array
    assignments = []
    for a in model.getListOfRules()
        if (a.getMath().getName() == "piecewise") # || (a.getMath().getName() == nothing)
            @error("Assignment rules are not implemented.")
        end
        push!(assignments, a.getId() => a.getMath().getName())
    end

    reactions = Dict()  # Dict of reaction => kinetic formula
    for i in 0:model.getNumReactions()-1
        reaction = model.getReaction(i)
        kinetics = reaction.getKineticLaw()
        kinetic_components = kinetics.getFormula()
        reactions[reaction.getId()] = kinetic_components
    end

    species = Dict()  # Dict of species and stoichiometry-reactionId tuple they are involved in
    for i in 0:model.getNumSpecies()-1
        specie = model.getSpecies(i)
        if (specie.getBoundaryCondition() == true) || (specie.getId() in keys(species))
            continue
        end
        species[specie.getId()] = []
    end

    for i in 0:model.getNumReactions()-1
        reaction = model.getReaction(i)
        kinetics = reaction.getKineticLaw()
        for j in 0:reaction.getNumReactants()-1
            ref = reaction.getReactant(j)
            specie = model.getSpecies(ref.getSpecies())
            products = [r.getSpecies() for r in reaction.getListOfProducts()]
            if specie.getBoundaryCondition() == true
                println("continuing...")
                continue
            end
            stoich = -ref.getStoichiometry()

            if specie.getName() in products
                stoich_p = reaction.getProduct(specie.getId()).getStoichiometry()
                stoich = stoich_p + stoich
            end
            if stoich < 0
                stoich = string(stoich)
            elseif stoich > 0
                stoich = "+"*string(stoich)
            else
                stoich = ""
            end
            if stoich != ""
                push!(species[specie.getId()], (stoich, reaction.getId()))
            end
        end

        for j in 0:reaction.getNumProducts()-1
            ref = reaction.getProduct(j)
            specie = model.getSpecies(ref.getSpecies())
            reactants = [r.getSpecies() for r in reaction.getListOfReactants()]
            if (specie.getBoundaryCondition() == true) || (specie.getName() in reactants)
                println("continuing")
                continue
            end
            push!(species[specie.getId()], ("+"*string(ref.getStoichiometry()), reaction.getId()))
        end
    end

    getparameters(model)
    getinitialconditions(model)

    # Write ODEs
    eqs = ModelingToolkit.Equation[]
    for specie in keys(species)  # For every species
        if species[specie] != nothing
            lhs = eval(Meta.parse("_Differential($specie)"))
            rhs = "0"
            for (coef, reaction_name) in species[specie]  # For every reaction
                reactionformula = " $coef * ( $(reactions[reaction_name]) )"
                reactionformula = replace(reactionformula, "pow"=>"^")
                rhs = rhs*reactionformula
            end
        rhs = eval(Meta.parse(rhs))
        eqn = ModelingToolkit.Equation(lhs, rhs)  # Todo: kick this line out
        push!(eqs, lhs ~ rhs)
        end
    end
    eqs
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
