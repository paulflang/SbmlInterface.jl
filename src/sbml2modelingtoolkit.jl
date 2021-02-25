#=`_set_julia_code` is adapted from Frank T. Bergman
Date: 2019
Availability: https://groups.google.com/forum/#!topic/sbml-discuss/inS4Lzp3Ri8 or
https://www.dropbox.com/s/2bfpiausejp0gd0/convert_reactions.py?dl=0
and based on the methods published by Sungho Shin et al. in "Scalable Nonlinear
Programming Framework for Parameter Estimation in Dynamic Biological System Models"
Date: 2019
Availability: https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1006828=#


@ModelingToolkit.parameters t
D = ModelingToolkit.Differential(t)
export D

function simulatesbml(sbmlfile::String,tspan;saveat::Real=1.,jac::Bool=true,solver=OrdinaryDiffEq.Tsit5())
    prob = sbml2odeproblem(sbmlfile,tspan,jac=jac)
    OrdinaryDiffEq.solve(prob,solver,saveat=saveat)
end

function sbml2odeproblem(sbmlfile::String,tspan;jac::Bool=true)
    model = SbmlInterface.getmodel(sbmlfile)
    p = getparameters(model)
    u0 = getinitialconditions(model)
    sys,u0,p = sbml2odesystem(sbmlfile)
    ModelingToolkit.ODEProblem(sys,u0,tspan,p)
end

function sbml2odesystem(sbmlfile::String)
    if !isfile(sbmlfile)
        throw(DomainError("`sbmlfile` is not a file"))
    elseif !(splitext(sbmlfile)[2] in (".xml", ".sbml"))
        throw(DomainError("`sbmlfile` must have `.xml` or `.sbml` ending"))
    end
    model = getmodel(sbmlfile)
    p = getparameters(model)
    u0 = getinitialconditions(model)
    sys = ModelingToolkit.ODESystem(getodes(model))
    sys,u0,p
end

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


function getodes(model)::Array
    assignments = []
    for a in model.getListOfRules()
        if (a.getMath().getName() == nothing) || (a.getMath().getName() == "piecewise")
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
                print("continuing...")
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
                print("continuing")
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
        if species[specie] != ""
            lhs = eval(Meta.parse("D($specie)"))
            rhs = ""
            for (coef, reaction_name) in species[specie]  # For every reaction
                reaction_formula = " $coef * ( $(reactions[reaction_name]) )"
                rhs = rhs*reaction_formula
            end
        rhs = eval(Meta.parse(rhs))
        eqn = ModelingToolkit.Equation(lhs, rhs)
        push!(eqs, lhs ~ rhs)
        end
    end
    eqs
end

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
        elseif var.isSetInitialAmount
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
