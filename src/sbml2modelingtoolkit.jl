#=function sbml2odeproblem(sbmlfile::String, tspan::Array{Real}=0:1:100, jac::Bool=true)::ODEProblem
    sys, ic, p = model2odesystem(sbml_file)
    prob(tspan) = ODEProblem(sys, ic, tspan, p, jac=jac)
end


function sbml2odesystem(sbmlfile::String)::Tuple{ODESystem, Array{Pair}, Array{Pair}}
    isfile(sbml_file) || throw(DomainError("`sbml_file` is not a file"))
        Error
    elseif not splitext(sbml_file)[2] in (".xml", ".sbml")
        Error
    end
    model = getmodel(sbmlfile)
    p = getparameters(model)
    ic = getinitialconditions(model)
    ODESystem(getodes(model), p, ic)
end=#

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


#=function getodes(model)::Array
    assignments = []
    for a in model.getListOfRules()
        if (a.getMath().getName() == nothing) || (a.getMath().getName() == "piecewise")
            @error("Assignment rules are not implemented.")
        end
        push!(assignments, a.getId() => a.getMath().getName())
    end

    reactions = []  # list of reaction => kinetic formula pairs in JuMP format
    for i in 0:model.getNumReactions()-1
        reaction = model.getReaction(i)
        kinetics = reaction.getKineticLaw()
        kinetic_components = kinetics.getFormula()
        push!(reactions, reaction.getId() => kinetic_components)  # jump_formula
    end

    species = Dict()  # dict of species and stoichiometry-reactionId tuple they are involved in
    for i in 0:mod.getNumSpecies()-1
        specie = mod.getSpecies(i)
        if (specie.getBoundaryCondition() == true) || (specie.getId() in species)
            continue
        end
        species[specie.getId()] = []
    end

    function createspecies(speciename::String)
        # :($speciename = ModelingToolkit.Variable(Symbol($speciename)))

        expr = "$speciename = Num(ModelingToolkit.Variable(:$speciename))"
        println(expr)
        return Meta.parse(expr)
    end

    for i in 0:mod.getNumReactions()-1
        reaction = mod.getReaction(i)
        kinetics = reaction.getKineticLaw()
        for j in 0:reaction.getNumReactants()-1
            ref = reaction.getReactant(j)
            specie = mod.getSpecies(ref.getSpecies())
            products = [r.getSpecies() for r in reaction.getListOfProducts()]
            if specie.getBoundaryCondition() == true
                print("continuing...")
                continue
            end
            stoich = -ref.getStoichiometry()

            if specie.getName() in products
                stoich_p = reaction.getProduct(specie.getId()).getStoichiometry()
                stoich = stoich_p + stoich
            end
            if stoich < 0
                stoich = String(stoich)
            elseif stoich > 0
                stoich = "+"*String(stoich)
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
                print("continuing")
                continue
            end
            push!(species[specie.getId()], ("+"*String(ref.getStoichiometry()), reaction.getId()))
        end
    end


    @parameters t
    D = Differential(t)
    createparameters(model)
    createvariables(model)

    eqs = []

    # Write ODEs
    for specie in species  # For every species
        if species[specie] != ""
            lhs = Meta.parse("D($specie)")
            rhs = ""
            for (coef, reaction_name) in species[specie]  # For every reaction
                reaction_formula = " $coef * ( $(reactions[reaction_name]) )"
                rhs = rhs*reaction_formula
            end
        rhs = Meta.parse(rhs)
        eqn = ModelingToolkit.Equation(lhs, rhs)
        push!(eqs, eqn)
        end
    end
    eqs
end=#


#=function getparameters(model)
    parameters = Dict()
    for i in 0:model.getNumParameters()-1
        par = model.getParameter(i)
        println(par)
        s = Symbol(par.getId())
        println(s)
        @parameters :s
        println(typeof(s)) 
        parameters[par.getId()] = par.getValue())
    end
    parameters
end=#


function createparameters(model)
    for i in 0:model.getNumParameters()-1
        parname = model.getParameter(i).getId()
        eval(Meta.parse("@ModelingToolkit.parameters $parname"))
        eval(Meta.parse("export $parname"))
    end
end

#=function createparameterst(model)
    for i in 0:model.getNumParameters()-1
        parname = model.getParameter(i).getId()
        println("@parameters $parname")
        println(Meta.parse("@parameters $parname"))
        eval(Meta.parse("@ModelingToolkit.parameters $parname"))
        eval(Meta.parse("export $parname"))
        println("yo")
    end
end=#


#=function createvariables(model)
    @parameters t
    for i in 0:mod.getNumSpecies()-1
        specie = mod.getSpecies(i)
        if (specie.getBoundaryCondition() == true) || (specie.getId() in species)
            continue
        end
        speciename = specie.getId()
        eval(Meta.parse("@variables $(speciename)(t)"))
    end
end


function getparameternames()

end

function getparametervalues()::Array

end

function getinitialconditions(model)
    initial_assignments = []
    for a in model.getListOfInitialAssignments()
        push!(initial_assignments, a.getId()] => a.getMath().getName())
    end
    initial_assignments
end

function getvariablenames()

end

function getinitialconditionvalues(sbml_model)::Array

end
=#