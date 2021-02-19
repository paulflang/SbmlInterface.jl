#=model = libsbml.model
par = ["a", "b"]
model.parameters = par
@test getparameters(model) == par
@test=#

FIXTURES = joinpath(@__DIR__, "fixtures")
SBML_FILE = joinpath(FIXTURES, "_model.xml")

@test SbmlInterface.getmodel(SBML_FILE) != 1
@test_nowarn SbmlInterface.getmodel(SBML_FILE)

@test begin
    model = SbmlInterface.getmodel(SBML_FILE)
    SbmlInterface.createparameters(model)
    isa(k1, ModelingToolkit.Num)
    1 == 2
end

#=@testset "sbml2odesystem.jl" begin
    sys, p, ic = sbml2odesystem(SBML_FILE)
#=    @test sys = b
    @test p = d
    @test ic = e=#
end=#



# @test SbmlInterface.getparameters(model) != 1
 

